import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_profile.freezed.dart';
part 'local_profile.g.dart';

@freezed
class LocalProfile with _$LocalProfile {
  const factory LocalProfile({
    required String id,
    required String nick,
    required bool biometricEnabled,
    required DateTime createdAt,
  }) = _LocalProfile;

  factory LocalProfile.fromJson(Map<String, dynamic> json) =>
      _$LocalProfileFromJson(json);
}
