import 'dart:convert';
import 'dart:math';

import 'package:cosmic_companion/core/auth/auth_provider.dart';
import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/core/auth/secure_storage.dart';
import 'package:cosmic_companion/core/error/failures.dart';
import 'package:cosmic_companion/data/models/local_profile.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

// Klucze SecureStorage
abstract final class _Keys {
  static const profile = 'local_profile';
  static const pinHash = 'pin_hash';
  static const pinSalt = 'pin_salt';
  static const failedAttempts = 'pin_failed_attempts';
  static const lockoutUntil = 'pin_lockout_until';
}

const _pbkdfIterations = 100000;
const _maxAttempts = 5;
const _lockoutSeconds = 30;

// Słabe PINy odrzucane przy tworzeniu profilu
const _weakPins = {
  '0000', '1111', '2222', '3333', '4444', '5555',
  '6666', '7777', '8888', '9999', '1234', '4321',
  '123456', '654321', '000000', '111111', '123123',
};

// Top-level dla compute() — PBKDF2-HMAC-SHA256
Uint8List _pbkdf2Work(({String password, Uint8List salt}) input) {
  const keyLen = 32;
  final passwordBytes = utf8.encode(input.password);
  final hmac = Hmac(sha256, passwordBytes);

  final blockInput = Uint8List(input.salt.length + 4)
    ..setAll(0, input.salt)
    ..[input.salt.length + 3] = 1;

  var u = Uint8List.fromList(hmac.convert(blockInput).bytes);
  final result = Uint8List.fromList(u);

  for (var i = 1; i < _pbkdfIterations; i++) {
    u = Uint8List.fromList(hmac.convert(u).bytes);
    for (var j = 0; j < keyLen; j++) {
      result[j] ^= u[j];
    }
  }
  return result;
}

class LocalAuthProvider extends StateNotifier<AuthState>
    implements AuthProvider {
  LocalAuthProvider(this._storage)
      : super(const AuthState.unauthenticated());

  final SecureStorage _storage;
  final _localAuth = LocalAuthentication();
  final _uuid = const Uuid();

  Future<void> initialize() async {
    final profileJson = await _storage.read(_Keys.profile);
    if (profileJson == null) {
      state = const AuthState.unauthenticated();
      return;
    }
    final profile = LocalProfile.fromJson(
      jsonDecode(profileJson) as Map<String, dynamic>,
    );
    state = AuthState.locked(user: profile);
  }

  @override
  Stream<AuthState> authStateChanges() => stream;

  @override
  Future<AuthState> currentState() async => state;

  @override
  Future<LocalProfile?> currentUser() async => switch (state) {
        Authenticated(:final user) => user,
        Locked(:final user) => user,
        Unauthenticated() => null,
      };

  @override
  Future<LocalProfile> createProfile({
    required String nick,
    required String pin,
    required bool biometricEnabled,
  }) async {
    _validatePin(pin);

    final salt = _randomSalt();
    final hash = await compute(_pbkdf2Work, (password: pin, salt: salt));

    final profile = LocalProfile(
      id: _uuid.v4(),
      nick: nick.trim(),
      biometricEnabled: biometricEnabled,
      createdAt: DateTime.now().toUtc(),
    );

    await Future.wait([
      _storage.write(_Keys.profile, jsonEncode(profile.toJson())),
      _storage.write(_Keys.pinHash, _toHex(hash)),
      _storage.write(_Keys.pinSalt, _toHex(salt)),
    ]);

    state = AuthState.authenticated(user: profile);
    return profile;
  }

  @override
  Future<void> unlockWithPin(String pin) async {
    await _checkLockout();

    final storedHash = await _storage.read(_Keys.pinHash);
    final storedSalt = await _storage.read(_Keys.pinSalt);
    if (storedHash == null || storedSalt == null) {
      throw const AuthFailure('Brak zapisanego PINu');
    }

    final salt = _fromHex(storedSalt);
    final hash = await compute(_pbkdf2Work, (password: pin, salt: salt));

    if (_toHex(hash) != storedHash) {
      await _incrementFailedAttempts();
      throw const AuthFailure('Nieprawidłowy PIN');
    }

    await _resetFailedAttempts();
    final profile = await _requireProfile();
    state = AuthState.authenticated(user: profile);
  }

  @override
  Future<void> unlockWithBiometric() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    if (!canCheck) throw const AuthFailure('Biometria niedostępna');

    final authenticated = await _localAuth.authenticate(
      localizedReason: 'Odblokuj Cosmic Companion',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (!authenticated) throw const AuthFailure('Biometria nieudana');

    await _resetFailedAttempts();
    final profile = await _requireProfile();
    state = AuthState.authenticated(user: profile);
  }

  @override
  Future<void> lock() async {
    final profile = await _requireProfile();
    state = AuthState.locked(user: profile);
  }

  @override
  Future<void> signOut() async {
    state = const AuthState.unauthenticated();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  void _validatePin(String pin) {
    if (pin.length < 4 || pin.length > 6) {
      throw const AuthFailure('PIN musi mieć 4–6 cyfr');
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw const AuthFailure('PIN może zawierać tylko cyfry');
    }
    if (_weakPins.contains(pin)) {
      throw const AuthFailure('PIN jest zbyt prosty');
    }
  }

  Future<void> _checkLockout() async {
    final lockoutStr = await _storage.read(_Keys.lockoutUntil);
    if (lockoutStr == null) return;
    final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(
      int.parse(lockoutStr),
    );
    if (DateTime.now().isBefore(lockoutUntil)) {
      final remaining = lockoutUntil.difference(DateTime.now()).inSeconds;
      throw AuthFailure('Konto zablokowane. Spróbuj za ${remaining}s.');
    }
  }

  Future<void> _incrementFailedAttempts() async {
    final current = int.tryParse(
          await _storage.read(_Keys.failedAttempts) ?? '0',
        ) ??
        0;
    final next = current + 1;
    await _storage.write(_Keys.failedAttempts, next.toString());
    if (next >= _maxAttempts) {
      final lockoutUntil =
          DateTime.now().add(const Duration(seconds: _lockoutSeconds));
      await _storage.write(
        _Keys.lockoutUntil,
        lockoutUntil.millisecondsSinceEpoch.toString(),
      );
    }
  }

  Future<void> _resetFailedAttempts() async {
    await Future.wait([
      _storage.delete(_Keys.failedAttempts),
      _storage.delete(_Keys.lockoutUntil),
    ]);
  }

  Future<LocalProfile> _requireProfile() async {
    final json = await _storage.read(_Keys.profile);
    if (json == null) throw const AuthFailure('Brak profilu');
    return LocalProfile.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  Uint8List _randomSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );
  }

  String _toHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  Uint8List _fromHex(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}
