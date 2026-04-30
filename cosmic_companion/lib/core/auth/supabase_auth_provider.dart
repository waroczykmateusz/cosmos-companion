import 'package:cosmic_companion/core/auth/auth_provider.dart';
import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/data/models/local_profile.dart';

// Stub — sygnatury identyczne z LocalAuthProvider.
// Swap: zmień 1 linię w providers.dart (authProviderInstance).
final class SupabaseAuthProvider implements AuthProvider {
  const SupabaseAuthProvider();

  @override
  Stream<AuthState> authStateChanges() => throw UnimplementedError();

  @override
  Future<AuthState> currentState() => throw UnimplementedError();

  @override
  Future<LocalProfile> createProfile({
    required String nick,
    required String pin,
    required bool biometricEnabled,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> unlockWithPin(String pin) => throw UnimplementedError();

  @override
  Future<void> unlockWithBiometric() => throw UnimplementedError();

  @override
  Future<void> lock() => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<LocalProfile?> currentUser() => throw UnimplementedError();
}
