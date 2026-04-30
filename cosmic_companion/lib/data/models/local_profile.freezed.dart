// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LocalProfile _$LocalProfileFromJson(Map<String, dynamic> json) {
  return _LocalProfile.fromJson(json);
}

/// @nodoc
mixin _$LocalProfile {
  String get id => throw _privateConstructorUsedError;
  String get nick => throw _privateConstructorUsedError;
  bool get biometricEnabled => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LocalProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalProfileCopyWith<LocalProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalProfileCopyWith<$Res> {
  factory $LocalProfileCopyWith(
    LocalProfile value,
    $Res Function(LocalProfile) then,
  ) = _$LocalProfileCopyWithImpl<$Res, LocalProfile>;
  @useResult
  $Res call({
    String id,
    String nick,
    bool biometricEnabled,
    DateTime createdAt,
  });
}

/// @nodoc
class _$LocalProfileCopyWithImpl<$Res, $Val extends LocalProfile>
    implements $LocalProfileCopyWith<$Res> {
  _$LocalProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nick = null,
    Object? biometricEnabled = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            nick:
                null == nick
                    ? _value.nick
                    : nick // ignore: cast_nullable_to_non_nullable
                        as String,
            biometricEnabled:
                null == biometricEnabled
                    ? _value.biometricEnabled
                    : biometricEnabled // ignore: cast_nullable_to_non_nullable
                        as bool,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocalProfileImplCopyWith<$Res>
    implements $LocalProfileCopyWith<$Res> {
  factory _$$LocalProfileImplCopyWith(
    _$LocalProfileImpl value,
    $Res Function(_$LocalProfileImpl) then,
  ) = __$$LocalProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nick,
    bool biometricEnabled,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LocalProfileImplCopyWithImpl<$Res>
    extends _$LocalProfileCopyWithImpl<$Res, _$LocalProfileImpl>
    implements _$$LocalProfileImplCopyWith<$Res> {
  __$$LocalProfileImplCopyWithImpl(
    _$LocalProfileImpl _value,
    $Res Function(_$LocalProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nick = null,
    Object? biometricEnabled = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LocalProfileImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        nick:
            null == nick
                ? _value.nick
                : nick // ignore: cast_nullable_to_non_nullable
                    as String,
        biometricEnabled:
            null == biometricEnabled
                ? _value.biometricEnabled
                : biometricEnabled // ignore: cast_nullable_to_non_nullable
                    as bool,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalProfileImpl implements _LocalProfile {
  const _$LocalProfileImpl({
    required this.id,
    required this.nick,
    required this.biometricEnabled,
    required this.createdAt,
  });

  factory _$LocalProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String nick;
  @override
  final bool biometricEnabled;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LocalProfile(id: $id, nick: $nick, biometricEnabled: $biometricEnabled, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nick, nick) || other.nick == nick) &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                other.biometricEnabled == biometricEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nick, biometricEnabled, createdAt);

  /// Create a copy of LocalProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalProfileImplCopyWith<_$LocalProfileImpl> get copyWith =>
      __$$LocalProfileImplCopyWithImpl<_$LocalProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalProfileImplToJson(this);
  }
}

abstract class _LocalProfile implements LocalProfile {
  const factory _LocalProfile({
    required final String id,
    required final String nick,
    required final bool biometricEnabled,
    required final DateTime createdAt,
  }) = _$LocalProfileImpl;

  factory _LocalProfile.fromJson(Map<String, dynamic> json) =
      _$LocalProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get nick;
  @override
  bool get biometricEnabled;
  @override
  DateTime get createdAt;

  /// Create a copy of LocalProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalProfileImplCopyWith<_$LocalProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
