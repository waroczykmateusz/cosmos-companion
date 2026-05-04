// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'celestial_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeoLocationImpl _$$GeoLocationImplFromJson(Map<String, dynamic> json) =>
    _$GeoLocationImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      elevationMeters: (json['elevationMeters'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$GeoLocationImplToJson(_$GeoLocationImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'elevationMeters': instance.elevationMeters,
    };

_$AspectImpl _$$AspectImplFromJson(Map<String, dynamic> json) => _$AspectImpl(
  target: $enumDecode(_$CelestialBodyIdEnumMap, json['target']),
  type: $enumDecode(_$AspectTypeEnumMap, json['type']),
  orb: (json['orb'] as num).toDouble(),
  isApplying: json['isApplying'] as bool,
);

Map<String, dynamic> _$$AspectImplToJson(_$AspectImpl instance) =>
    <String, dynamic>{
      'target': _$CelestialBodyIdEnumMap[instance.target]!,
      'type': _$AspectTypeEnumMap[instance.type]!,
      'orb': instance.orb,
      'isApplying': instance.isApplying,
    };

const _$CelestialBodyIdEnumMap = {
  CelestialBodyId.sun: 'sun',
  CelestialBodyId.moon: 'moon',
  CelestialBodyId.mercury: 'mercury',
  CelestialBodyId.venus: 'venus',
  CelestialBodyId.mars: 'mars',
  CelestialBodyId.jupiter: 'jupiter',
  CelestialBodyId.saturn: 'saturn',
  CelestialBodyId.uranus: 'uranus',
  CelestialBodyId.neptune: 'neptune',
  CelestialBodyId.pluto: 'pluto',
  CelestialBodyId.northNode: 'northNode',
  CelestialBodyId.southNode: 'southNode',
  CelestialBodyId.chiron: 'chiron',
  CelestialBodyId.lilith: 'lilith',
};

const _$AspectTypeEnumMap = {
  AspectType.conjunction: 'conjunction',
  AspectType.sextile: 'sextile',
  AspectType.square: 'square',
  AspectType.trine: 'trine',
  AspectType.opposition: 'opposition',
};

_$CelestialBodyImpl _$$CelestialBodyImplFromJson(Map<String, dynamic> json) =>
    _$CelestialBodyImpl(
      id: $enumDecode(_$CelestialBodyIdEnumMap, json['id']),
      displayName: json['displayName'] as String,
      epoch: DateTime.parse(json['epoch'] as String),
      observerLocation: GeoLocation.fromJson(
        json['observerLocation'] as Map<String, dynamic>,
      ),
      rightAscension: (json['rightAscension'] as num).toDouble(),
      declination: (json['declination'] as num).toDouble(),
      distanceAU: (json['distanceAU'] as num).toDouble(),
      apparentMagnitude: (json['apparentMagnitude'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      azimuth: (json['azimuth'] as num).toDouble(),
      isAboveHorizon: json['isAboveHorizon'] as bool,
      eclipticLongitude: (json['eclipticLongitude'] as num).toDouble(),
      eclipticLatitude: (json['eclipticLatitude'] as num).toDouble(),
      zodiacSign: $enumDecode(_$ZodiacSignEnumMap, json['zodiacSign']),
      signDegree: (json['signDegree'] as num).toDouble(),
      house: $enumDecodeNullable(_$AstrologicalHouseEnumMap, json['house']),
      isRetrograde: json['isRetrograde'] as bool,
      riseTime:
          json['riseTime'] == null
              ? null
              : DateTime.parse(json['riseTime'] as String),
      transitTime:
          json['transitTime'] == null
              ? null
              : DateTime.parse(json['transitTime'] as String),
      setTime:
          json['setTime'] == null
              ? null
              : DateTime.parse(json['setTime'] as String),
      aspects:
          (json['aspects'] as List<dynamic>?)
              ?.map((e) => Aspect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CelestialBodyImplToJson(_$CelestialBodyImpl instance) =>
    <String, dynamic>{
      'id': _$CelestialBodyIdEnumMap[instance.id]!,
      'displayName': instance.displayName,
      'epoch': instance.epoch.toIso8601String(),
      'observerLocation': instance.observerLocation,
      'rightAscension': instance.rightAscension,
      'declination': instance.declination,
      'distanceAU': instance.distanceAU,
      'apparentMagnitude': instance.apparentMagnitude,
      'altitude': instance.altitude,
      'azimuth': instance.azimuth,
      'isAboveHorizon': instance.isAboveHorizon,
      'eclipticLongitude': instance.eclipticLongitude,
      'eclipticLatitude': instance.eclipticLatitude,
      'zodiacSign': _$ZodiacSignEnumMap[instance.zodiacSign]!,
      'signDegree': instance.signDegree,
      'house': _$AstrologicalHouseEnumMap[instance.house],
      'isRetrograde': instance.isRetrograde,
      'riseTime': instance.riseTime?.toIso8601String(),
      'transitTime': instance.transitTime?.toIso8601String(),
      'setTime': instance.setTime?.toIso8601String(),
      'aspects': instance.aspects,
    };

const _$ZodiacSignEnumMap = {
  ZodiacSign.aries: 'aries',
  ZodiacSign.taurus: 'taurus',
  ZodiacSign.gemini: 'gemini',
  ZodiacSign.cancer: 'cancer',
  ZodiacSign.leo: 'leo',
  ZodiacSign.virgo: 'virgo',
  ZodiacSign.libra: 'libra',
  ZodiacSign.scorpio: 'scorpio',
  ZodiacSign.sagittarius: 'sagittarius',
  ZodiacSign.capricorn: 'capricorn',
  ZodiacSign.aquarius: 'aquarius',
  ZodiacSign.pisces: 'pisces',
};

const _$AstrologicalHouseEnumMap = {
  AstrologicalHouse.first: 'first',
  AstrologicalHouse.second: 'second',
  AstrologicalHouse.third: 'third',
  AstrologicalHouse.fourth: 'fourth',
  AstrologicalHouse.fifth: 'fifth',
  AstrologicalHouse.sixth: 'sixth',
  AstrologicalHouse.seventh: 'seventh',
  AstrologicalHouse.eighth: 'eighth',
  AstrologicalHouse.ninth: 'ninth',
  AstrologicalHouse.tenth: 'tenth',
  AstrologicalHouse.eleventh: 'eleventh',
  AstrologicalHouse.twelfth: 'twelfth',
};
