import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/data/models/local_profile.dart';

abstract interface class AuthProvider {
  Stream<AuthState> authStateChanges();
  Future<AuthState> currentState();
  Future<LocalProfile> createProfile({
    required String nick,
    required String pin,
    required bool biometricEnabled,
  });
  Future<void> unlockWithPin(String pin);
  Future<void> unlockWithBiometric();
  Future<void> lock();
  Future<void> signOut();
  Future<LocalProfile?> currentUser();
}
