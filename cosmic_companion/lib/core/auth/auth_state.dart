import 'package:cosmic_companion/data/models/local_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.authenticated({required LocalProfile user}) =
      Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.locked({required LocalProfile user}) = Locked;
}
