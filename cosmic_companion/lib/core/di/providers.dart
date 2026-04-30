import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/core/auth/local_auth_provider.dart';
import 'package:cosmic_companion/core/auth/secure_storage.dart';
import 'package:cosmic_companion/core/privacy/data_purger.dart';
import 'package:cosmic_companion/core/privacy/pii_filter.dart';
import 'package:cosmic_companion/core/privacy/telemetry_consent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

final secureStorageProvider = Provider<SecureStorage>(
  (ref) => SecureStorage(ref.watch(flutterSecureStorageProvider)),
);

final piiFilterProvider = Provider<PiiFilter>((ref) => PiiFilter());

final telemetryConsentProvider = Provider<TelemetryConsent>(
  (ref) => TelemetryConsent(ref.watch(flutterSecureStorageProvider)),
);

final dataPurgerProvider = Provider<DataPurger>(
  (ref) => DataPurger(ref.watch(flutterSecureStorageProvider)),
);

// MVP: LocalAuthProvider. Swap na SupabaseAuthProvider = zmiana 1 linii tutaj.
final localAuthProvider =
    StateNotifierProvider<LocalAuthProvider, AuthState>((ref) {
  return LocalAuthProvider(ref.watch(secureStorageProvider))..initialize();
});

final authStateProvider = Provider<AuthState>(
  (ref) => ref.watch(localAuthProvider),
);
