// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalProfileImpl _$$LocalProfileImplFromJson(Map<String, dynamic> json) =>
    _$LocalProfileImpl(
      id: json['id'] as String,
      nick: json['nick'] as String,
      biometricEnabled: json['biometricEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LocalProfileImplToJson(_$LocalProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nick': instance.nick,
      'biometricEnabled': instance.biometricEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
    };
