// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'celestial_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) {
  return _GeoLocation.fromJson(json);
}

/// @nodoc
mixin _$GeoLocation {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  double get elevationMeters => throw _privateConstructorUsedError;

  /// Serializes this GeoLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeoLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeoLocationCopyWith<GeoLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoLocationCopyWith<$Res> {
  factory $GeoLocationCopyWith(
    GeoLocation value,
    $Res Function(GeoLocation) then,
  ) = _$GeoLocationCopyWithImpl<$Res, GeoLocation>;
  @useResult
  $Res call({double latitude, double longitude, double elevationMeters});
}

/// @nodoc
class _$GeoLocationCopyWithImpl<$Res, $Val extends GeoLocation>
    implements $GeoLocationCopyWith<$Res> {
  _$GeoLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeoLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? elevationMeters = null,
  }) {
    return _then(
      _value.copyWith(
            latitude:
                null == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double,
            longitude:
                null == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double,
            elevationMeters:
                null == elevationMeters
                    ? _value.elevationMeters
                    : elevationMeters // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GeoLocationImplCopyWith<$Res>
    implements $GeoLocationCopyWith<$Res> {
  factory _$$GeoLocationImplCopyWith(
    _$GeoLocationImpl value,
    $Res Function(_$GeoLocationImpl) then,
  ) = __$$GeoLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude, double elevationMeters});
}

/// @nodoc
class __$$GeoLocationImplCopyWithImpl<$Res>
    extends _$GeoLocationCopyWithImpl<$Res, _$GeoLocationImpl>
    implements _$$GeoLocationImplCopyWith<$Res> {
  __$$GeoLocationImplCopyWithImpl(
    _$GeoLocationImpl _value,
    $Res Function(_$GeoLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GeoLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? elevationMeters = null,
  }) {
    return _then(
      _$GeoLocationImpl(
        latitude:
            null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double,
        longitude:
            null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double,
        elevationMeters:
            null == elevationMeters
                ? _value.elevationMeters
                : elevationMeters // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GeoLocationImpl implements _GeoLocation {
  const _$GeoLocationImpl({
    required this.latitude,
    required this.longitude,
    this.elevationMeters = 0.0,
  });

  factory _$GeoLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeoLocationImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  @JsonKey()
  final double elevationMeters;

  @override
  String toString() {
    return 'GeoLocation(latitude: $latitude, longitude: $longitude, elevationMeters: $elevationMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeoLocationImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.elevationMeters, elevationMeters) ||
                other.elevationMeters == elevationMeters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, latitude, longitude, elevationMeters);

  /// Create a copy of GeoLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeoLocationImplCopyWith<_$GeoLocationImpl> get copyWith =>
      __$$GeoLocationImplCopyWithImpl<_$GeoLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeoLocationImplToJson(this);
  }
}

abstract class _GeoLocation implements GeoLocation {
  const factory _GeoLocation({
    required final double latitude,
    required final double longitude,
    final double elevationMeters,
  }) = _$GeoLocationImpl;

  factory _GeoLocation.fromJson(Map<String, dynamic> json) =
      _$GeoLocationImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  double get elevationMeters;

  /// Create a copy of GeoLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeoLocationImplCopyWith<_$GeoLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Aspect _$AspectFromJson(Map<String, dynamic> json) {
  return _Aspect.fromJson(json);
}

/// @nodoc
mixin _$Aspect {
  CelestialBodyId get target => throw _privateConstructorUsedError;
  AspectType get type => throw _privateConstructorUsedError;
  double get orb => throw _privateConstructorUsedError;
  bool get isApplying => throw _privateConstructorUsedError;

  /// Serializes this Aspect to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AspectCopyWith<Aspect> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AspectCopyWith<$Res> {
  factory $AspectCopyWith(Aspect value, $Res Function(Aspect) then) =
      _$AspectCopyWithImpl<$Res, Aspect>;
  @useResult
  $Res call({
    CelestialBodyId target,
    AspectType type,
    double orb,
    bool isApplying,
  });
}

/// @nodoc
class _$AspectCopyWithImpl<$Res, $Val extends Aspect>
    implements $AspectCopyWith<$Res> {
  _$AspectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? target = null,
    Object? type = null,
    Object? orb = null,
    Object? isApplying = null,
  }) {
    return _then(
      _value.copyWith(
            target:
                null == target
                    ? _value.target
                    : target // ignore: cast_nullable_to_non_nullable
                        as CelestialBodyId,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as AspectType,
            orb:
                null == orb
                    ? _value.orb
                    : orb // ignore: cast_nullable_to_non_nullable
                        as double,
            isApplying:
                null == isApplying
                    ? _value.isApplying
                    : isApplying // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AspectImplCopyWith<$Res> implements $AspectCopyWith<$Res> {
  factory _$$AspectImplCopyWith(
    _$AspectImpl value,
    $Res Function(_$AspectImpl) then,
  ) = __$$AspectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CelestialBodyId target,
    AspectType type,
    double orb,
    bool isApplying,
  });
}

/// @nodoc
class __$$AspectImplCopyWithImpl<$Res>
    extends _$AspectCopyWithImpl<$Res, _$AspectImpl>
    implements _$$AspectImplCopyWith<$Res> {
  __$$AspectImplCopyWithImpl(
    _$AspectImpl _value,
    $Res Function(_$AspectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? target = null,
    Object? type = null,
    Object? orb = null,
    Object? isApplying = null,
  }) {
    return _then(
      _$AspectImpl(
        target:
            null == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                    as CelestialBodyId,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as AspectType,
        orb:
            null == orb
                ? _value.orb
                : orb // ignore: cast_nullable_to_non_nullable
                    as double,
        isApplying:
            null == isApplying
                ? _value.isApplying
                : isApplying // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AspectImpl implements _Aspect {
  const _$AspectImpl({
    required this.target,
    required this.type,
    required this.orb,
    required this.isApplying,
  });

  factory _$AspectImpl.fromJson(Map<String, dynamic> json) =>
      _$$AspectImplFromJson(json);

  @override
  final CelestialBodyId target;
  @override
  final AspectType type;
  @override
  final double orb;
  @override
  final bool isApplying;

  @override
  String toString() {
    return 'Aspect(target: $target, type: $type, orb: $orb, isApplying: $isApplying)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AspectImpl &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.orb, orb) || other.orb == orb) &&
            (identical(other.isApplying, isApplying) ||
                other.isApplying == isApplying));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, target, type, orb, isApplying);

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AspectImplCopyWith<_$AspectImpl> get copyWith =>
      __$$AspectImplCopyWithImpl<_$AspectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AspectImplToJson(this);
  }
}

abstract class _Aspect implements Aspect {
  const factory _Aspect({
    required final CelestialBodyId target,
    required final AspectType type,
    required final double orb,
    required final bool isApplying,
  }) = _$AspectImpl;

  factory _Aspect.fromJson(Map<String, dynamic> json) = _$AspectImpl.fromJson;

  @override
  CelestialBodyId get target;
  @override
  AspectType get type;
  @override
  double get orb;
  @override
  bool get isApplying;

  /// Create a copy of Aspect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AspectImplCopyWith<_$AspectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CelestialBody _$CelestialBodyFromJson(Map<String, dynamic> json) {
  return _CelestialBody.fromJson(json);
}

/// @nodoc
mixin _$CelestialBody {
  // Identyfikacja i kontekst
  CelestialBodyId get id => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  DateTime get epoch => throw _privateConstructorUsedError;
  GeoLocation get observerLocation =>
      throw _privateConstructorUsedError; // === ASTRONOMIA (równikowy układ J2000) ===
  double get rightAscension => throw _privateConstructorUsedError;
  double get declination => throw _privateConstructorUsedError;
  double get distanceAU => throw _privateConstructorUsedError;
  double get apparentMagnitude => throw _privateConstructorUsedError;
  double get altitude => throw _privateConstructorUsedError;
  double get azimuth => throw _privateConstructorUsedError;
  bool get isAboveHorizon =>
      throw _privateConstructorUsedError; // === ASTROLOGIA (układ ekliptyczny, geocentryczny) ===
  double get eclipticLongitude => throw _privateConstructorUsedError;
  double get eclipticLatitude => throw _privateConstructorUsedError;
  ZodiacSign get zodiacSign => throw _privateConstructorUsedError;
  double get signDegree => throw _privateConstructorUsedError;
  AstrologicalHouse? get house => throw _privateConstructorUsedError;
  bool get isRetrograde =>
      throw _privateConstructorUsedError; // Opcjonalne — null gdy brak efemeryd lub nie obliczono
  DateTime? get riseTime => throw _privateConstructorUsedError;
  DateTime? get transitTime => throw _privateConstructorUsedError;
  DateTime? get setTime => throw _privateConstructorUsedError;
  List<Aspect> get aspects => throw _privateConstructorUsedError;

  /// Serializes this CelestialBody to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CelestialBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CelestialBodyCopyWith<CelestialBody> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CelestialBodyCopyWith<$Res> {
  factory $CelestialBodyCopyWith(
    CelestialBody value,
    $Res Function(CelestialBody) then,
  ) = _$CelestialBodyCopyWithImpl<$Res, CelestialBody>;
  @useResult
  $Res call({
    CelestialBodyId id,
    String displayName,
    DateTime epoch,
    GeoLocation observerLocation,
    double rightAscension,
    double declination,
    double distanceAU,
    double apparentMagnitude,
    double altitude,
    double azimuth,
    bool isAboveHorizon,
    double eclipticLongitude,
    double eclipticLatitude,
    ZodiacSign zodiacSign,
    double signDegree,
    AstrologicalHouse? house,
    bool isRetrograde,
    DateTime? riseTime,
    DateTime? transitTime,
    DateTime? setTime,
    List<Aspect> aspects,
  });

  $GeoLocationCopyWith<$Res> get observerLocation;
}

/// @nodoc
class _$CelestialBodyCopyWithImpl<$Res, $Val extends CelestialBody>
    implements $CelestialBodyCopyWith<$Res> {
  _$CelestialBodyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CelestialBody
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? epoch = null,
    Object? observerLocation = null,
    Object? rightAscension = null,
    Object? declination = null,
    Object? distanceAU = null,
    Object? apparentMagnitude = null,
    Object? altitude = null,
    Object? azimuth = null,
    Object? isAboveHorizon = null,
    Object? eclipticLongitude = null,
    Object? eclipticLatitude = null,
    Object? zodiacSign = null,
    Object? signDegree = null,
    Object? house = freezed,
    Object? isRetrograde = null,
    Object? riseTime = freezed,
    Object? transitTime = freezed,
    Object? setTime = freezed,
    Object? aspects = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as CelestialBodyId,
            displayName:
                null == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String,
            epoch:
                null == epoch
                    ? _value.epoch
                    : epoch // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            observerLocation:
                null == observerLocation
                    ? _value.observerLocation
                    : observerLocation // ignore: cast_nullable_to_non_nullable
                        as GeoLocation,
            rightAscension:
                null == rightAscension
                    ? _value.rightAscension
                    : rightAscension // ignore: cast_nullable_to_non_nullable
                        as double,
            declination:
                null == declination
                    ? _value.declination
                    : declination // ignore: cast_nullable_to_non_nullable
                        as double,
            distanceAU:
                null == distanceAU
                    ? _value.distanceAU
                    : distanceAU // ignore: cast_nullable_to_non_nullable
                        as double,
            apparentMagnitude:
                null == apparentMagnitude
                    ? _value.apparentMagnitude
                    : apparentMagnitude // ignore: cast_nullable_to_non_nullable
                        as double,
            altitude:
                null == altitude
                    ? _value.altitude
                    : altitude // ignore: cast_nullable_to_non_nullable
                        as double,
            azimuth:
                null == azimuth
                    ? _value.azimuth
                    : azimuth // ignore: cast_nullable_to_non_nullable
                        as double,
            isAboveHorizon:
                null == isAboveHorizon
                    ? _value.isAboveHorizon
                    : isAboveHorizon // ignore: cast_nullable_to_non_nullable
                        as bool,
            eclipticLongitude:
                null == eclipticLongitude
                    ? _value.eclipticLongitude
                    : eclipticLongitude // ignore: cast_nullable_to_non_nullable
                        as double,
            eclipticLatitude:
                null == eclipticLatitude
                    ? _value.eclipticLatitude
                    : eclipticLatitude // ignore: cast_nullable_to_non_nullable
                        as double,
            zodiacSign:
                null == zodiacSign
                    ? _value.zodiacSign
                    : zodiacSign // ignore: cast_nullable_to_non_nullable
                        as ZodiacSign,
            signDegree:
                null == signDegree
                    ? _value.signDegree
                    : signDegree // ignore: cast_nullable_to_non_nullable
                        as double,
            house:
                freezed == house
                    ? _value.house
                    : house // ignore: cast_nullable_to_non_nullable
                        as AstrologicalHouse?,
            isRetrograde:
                null == isRetrograde
                    ? _value.isRetrograde
                    : isRetrograde // ignore: cast_nullable_to_non_nullable
                        as bool,
            riseTime:
                freezed == riseTime
                    ? _value.riseTime
                    : riseTime // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            transitTime:
                freezed == transitTime
                    ? _value.transitTime
                    : transitTime // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            setTime:
                freezed == setTime
                    ? _value.setTime
                    : setTime // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            aspects:
                null == aspects
                    ? _value.aspects
                    : aspects // ignore: cast_nullable_to_non_nullable
                        as List<Aspect>,
          )
          as $Val,
    );
  }

  /// Create a copy of CelestialBody
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeoLocationCopyWith<$Res> get observerLocation {
    return $GeoLocationCopyWith<$Res>(_value.observerLocation, (value) {
      return _then(_value.copyWith(observerLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CelestialBodyImplCopyWith<$Res>
    implements $CelestialBodyCopyWith<$Res> {
  factory _$$CelestialBodyImplCopyWith(
    _$CelestialBodyImpl value,
    $Res Function(_$CelestialBodyImpl) then,
  ) = __$$CelestialBodyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CelestialBodyId id,
    String displayName,
    DateTime epoch,
    GeoLocation observerLocation,
    double rightAscension,
    double declination,
    double distanceAU,
    double apparentMagnitude,
    double altitude,
    double azimuth,
    bool isAboveHorizon,
    double eclipticLongitude,
    double eclipticLatitude,
    ZodiacSign zodiacSign,
    double signDegree,
    AstrologicalHouse? house,
    bool isRetrograde,
    DateTime? riseTime,
    DateTime? transitTime,
    DateTime? setTime,
    List<Aspect> aspects,
  });

  @override
  $GeoLocationCopyWith<$Res> get observerLocation;
}

/// @nodoc
class __$$CelestialBodyImplCopyWithImpl<$Res>
    extends _$CelestialBodyCopyWithImpl<$Res, _$CelestialBodyImpl>
    implements _$$CelestialBodyImplCopyWith<$Res> {
  __$$CelestialBodyImplCopyWithImpl(
    _$CelestialBodyImpl _value,
    $Res Function(_$CelestialBodyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CelestialBody
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? epoch = null,
    Object? observerLocation = null,
    Object? rightAscension = null,
    Object? declination = null,
    Object? distanceAU = null,
    Object? apparentMagnitude = null,
    Object? altitude = null,
    Object? azimuth = null,
    Object? isAboveHorizon = null,
    Object? eclipticLongitude = null,
    Object? eclipticLatitude = null,
    Object? zodiacSign = null,
    Object? signDegree = null,
    Object? house = freezed,
    Object? isRetrograde = null,
    Object? riseTime = freezed,
    Object? transitTime = freezed,
    Object? setTime = freezed,
    Object? aspects = null,
  }) {
    return _then(
      _$CelestialBodyImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as CelestialBodyId,
        displayName:
            null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String,
        epoch:
            null == epoch
                ? _value.epoch
                : epoch // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        observerLocation:
            null == observerLocation
                ? _value.observerLocation
                : observerLocation // ignore: cast_nullable_to_non_nullable
                    as GeoLocation,
        rightAscension:
            null == rightAscension
                ? _value.rightAscension
                : rightAscension // ignore: cast_nullable_to_non_nullable
                    as double,
        declination:
            null == declination
                ? _value.declination
                : declination // ignore: cast_nullable_to_non_nullable
                    as double,
        distanceAU:
            null == distanceAU
                ? _value.distanceAU
                : distanceAU // ignore: cast_nullable_to_non_nullable
                    as double,
        apparentMagnitude:
            null == apparentMagnitude
                ? _value.apparentMagnitude
                : apparentMagnitude // ignore: cast_nullable_to_non_nullable
                    as double,
        altitude:
            null == altitude
                ? _value.altitude
                : altitude // ignore: cast_nullable_to_non_nullable
                    as double,
        azimuth:
            null == azimuth
                ? _value.azimuth
                : azimuth // ignore: cast_nullable_to_non_nullable
                    as double,
        isAboveHorizon:
            null == isAboveHorizon
                ? _value.isAboveHorizon
                : isAboveHorizon // ignore: cast_nullable_to_non_nullable
                    as bool,
        eclipticLongitude:
            null == eclipticLongitude
                ? _value.eclipticLongitude
                : eclipticLongitude // ignore: cast_nullable_to_non_nullable
                    as double,
        eclipticLatitude:
            null == eclipticLatitude
                ? _value.eclipticLatitude
                : eclipticLatitude // ignore: cast_nullable_to_non_nullable
                    as double,
        zodiacSign:
            null == zodiacSign
                ? _value.zodiacSign
                : zodiacSign // ignore: cast_nullable_to_non_nullable
                    as ZodiacSign,
        signDegree:
            null == signDegree
                ? _value.signDegree
                : signDegree // ignore: cast_nullable_to_non_nullable
                    as double,
        house:
            freezed == house
                ? _value.house
                : house // ignore: cast_nullable_to_non_nullable
                    as AstrologicalHouse?,
        isRetrograde:
            null == isRetrograde
                ? _value.isRetrograde
                : isRetrograde // ignore: cast_nullable_to_non_nullable
                    as bool,
        riseTime:
            freezed == riseTime
                ? _value.riseTime
                : riseTime // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        transitTime:
            freezed == transitTime
                ? _value.transitTime
                : transitTime // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        setTime:
            freezed == setTime
                ? _value.setTime
                : setTime // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        aspects:
            null == aspects
                ? _value._aspects
                : aspects // ignore: cast_nullable_to_non_nullable
                    as List<Aspect>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CelestialBodyImpl implements _CelestialBody {
  const _$CelestialBodyImpl({
    required this.id,
    required this.displayName,
    required this.epoch,
    required this.observerLocation,
    required this.rightAscension,
    required this.declination,
    required this.distanceAU,
    required this.apparentMagnitude,
    required this.altitude,
    required this.azimuth,
    required this.isAboveHorizon,
    required this.eclipticLongitude,
    required this.eclipticLatitude,
    required this.zodiacSign,
    required this.signDegree,
    required this.house,
    required this.isRetrograde,
    this.riseTime,
    this.transitTime,
    this.setTime,
    final List<Aspect> aspects = const [],
  }) : _aspects = aspects;

  factory _$CelestialBodyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CelestialBodyImplFromJson(json);

  // Identyfikacja i kontekst
  @override
  final CelestialBodyId id;
  @override
  final String displayName;
  @override
  final DateTime epoch;
  @override
  final GeoLocation observerLocation;
  // === ASTRONOMIA (równikowy układ J2000) ===
  @override
  final double rightAscension;
  @override
  final double declination;
  @override
  final double distanceAU;
  @override
  final double apparentMagnitude;
  @override
  final double altitude;
  @override
  final double azimuth;
  @override
  final bool isAboveHorizon;
  // === ASTROLOGIA (układ ekliptyczny, geocentryczny) ===
  @override
  final double eclipticLongitude;
  @override
  final double eclipticLatitude;
  @override
  final ZodiacSign zodiacSign;
  @override
  final double signDegree;
  @override
  final AstrologicalHouse? house;
  @override
  final bool isRetrograde;
  // Opcjonalne — null gdy brak efemeryd lub nie obliczono
  @override
  final DateTime? riseTime;
  @override
  final DateTime? transitTime;
  @override
  final DateTime? setTime;
  final List<Aspect> _aspects;
  @override
  @JsonKey()
  List<Aspect> get aspects {
    if (_aspects is EqualUnmodifiableListView) return _aspects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_aspects);
  }

  @override
  String toString() {
    return 'CelestialBody(id: $id, displayName: $displayName, epoch: $epoch, observerLocation: $observerLocation, rightAscension: $rightAscension, declination: $declination, distanceAU: $distanceAU, apparentMagnitude: $apparentMagnitude, altitude: $altitude, azimuth: $azimuth, isAboveHorizon: $isAboveHorizon, eclipticLongitude: $eclipticLongitude, eclipticLatitude: $eclipticLatitude, zodiacSign: $zodiacSign, signDegree: $signDegree, house: $house, isRetrograde: $isRetrograde, riseTime: $riseTime, transitTime: $transitTime, setTime: $setTime, aspects: $aspects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CelestialBodyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.epoch, epoch) || other.epoch == epoch) &&
            (identical(other.observerLocation, observerLocation) ||
                other.observerLocation == observerLocation) &&
            (identical(other.rightAscension, rightAscension) ||
                other.rightAscension == rightAscension) &&
            (identical(other.declination, declination) ||
                other.declination == declination) &&
            (identical(other.distanceAU, distanceAU) ||
                other.distanceAU == distanceAU) &&
            (identical(other.apparentMagnitude, apparentMagnitude) ||
                other.apparentMagnitude == apparentMagnitude) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.azimuth, azimuth) || other.azimuth == azimuth) &&
            (identical(other.isAboveHorizon, isAboveHorizon) ||
                other.isAboveHorizon == isAboveHorizon) &&
            (identical(other.eclipticLongitude, eclipticLongitude) ||
                other.eclipticLongitude == eclipticLongitude) &&
            (identical(other.eclipticLatitude, eclipticLatitude) ||
                other.eclipticLatitude == eclipticLatitude) &&
            (identical(other.zodiacSign, zodiacSign) ||
                other.zodiacSign == zodiacSign) &&
            (identical(other.signDegree, signDegree) ||
                other.signDegree == signDegree) &&
            (identical(other.house, house) || other.house == house) &&
            (identical(other.isRetrograde, isRetrograde) ||
                other.isRetrograde == isRetrograde) &&
            (identical(other.riseTime, riseTime) ||
                other.riseTime == riseTime) &&
            (identical(other.transitTime, transitTime) ||
                other.transitTime == transitTime) &&
            (identical(other.setTime, setTime) || other.setTime == setTime) &&
            const DeepCollectionEquality().equals(other._aspects, _aspects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    displayName,
    epoch,
    observerLocation,
    rightAscension,
    declination,
    distanceAU,
    apparentMagnitude,
    altitude,
    azimuth,
    isAboveHorizon,
    eclipticLongitude,
    eclipticLatitude,
    zodiacSign,
    signDegree,
    house,
    isRetrograde,
    riseTime,
    transitTime,
    setTime,
    const DeepCollectionEquality().hash(_aspects),
  ]);

  /// Create a copy of CelestialBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CelestialBodyImplCopyWith<_$CelestialBodyImpl> get copyWith =>
      __$$CelestialBodyImplCopyWithImpl<_$CelestialBodyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CelestialBodyImplToJson(this);
  }
}

abstract class _CelestialBody implements CelestialBody {
  const factory _CelestialBody({
    required final CelestialBodyId id,
    required final String displayName,
    required final DateTime epoch,
    required final GeoLocation observerLocation,
    required final double rightAscension,
    required final double declination,
    required final double distanceAU,
    required final double apparentMagnitude,
    required final double altitude,
    required final double azimuth,
    required final bool isAboveHorizon,
    required final double eclipticLongitude,
    required final double eclipticLatitude,
    required final ZodiacSign zodiacSign,
    required final double signDegree,
    required final AstrologicalHouse? house,
    required final bool isRetrograde,
    final DateTime? riseTime,
    final DateTime? transitTime,
    final DateTime? setTime,
    final List<Aspect> aspects,
  }) = _$CelestialBodyImpl;

  factory _CelestialBody.fromJson(Map<String, dynamic> json) =
      _$CelestialBodyImpl.fromJson;

  // Identyfikacja i kontekst
  @override
  CelestialBodyId get id;
  @override
  String get displayName;
  @override
  DateTime get epoch;
  @override
  GeoLocation get observerLocation; // === ASTRONOMIA (równikowy układ J2000) ===
  @override
  double get rightAscension;
  @override
  double get declination;
  @override
  double get distanceAU;
  @override
  double get apparentMagnitude;
  @override
  double get altitude;
  @override
  double get azimuth;
  @override
  bool get isAboveHorizon; // === ASTROLOGIA (układ ekliptyczny, geocentryczny) ===
  @override
  double get eclipticLongitude;
  @override
  double get eclipticLatitude;
  @override
  ZodiacSign get zodiacSign;
  @override
  double get signDegree;
  @override
  AstrologicalHouse? get house;
  @override
  bool get isRetrograde; // Opcjonalne — null gdy brak efemeryd lub nie obliczono
  @override
  DateTime? get riseTime;
  @override
  DateTime? get transitTime;
  @override
  DateTime? get setTime;
  @override
  List<Aspect> get aspects;

  /// Create a copy of CelestialBody
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CelestialBodyImplCopyWith<_$CelestialBodyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
