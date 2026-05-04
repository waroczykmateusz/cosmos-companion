import 'package:freezed_annotation/freezed_annotation.dart';

part 'celestial_body.freezed.dart';
part 'celestial_body.g.dart';

@freezed
class GeoLocation with _$GeoLocation {
  const factory GeoLocation({
    required double latitude,
    required double longitude,
    @Default(0.0) double elevationMeters,
  }) = _GeoLocation;

  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationFromJson(json);
}

@freezed
class Aspect with _$Aspect {
  const factory Aspect({
    required CelestialBodyId target,
    required AspectType type,
    required double orb,
    required bool isApplying,
  }) = _Aspect;

  factory Aspect.fromJson(Map<String, dynamic> json) =>
      _$AspectFromJson(json);
}

@freezed
class CelestialBody with _$CelestialBody {
  const factory CelestialBody({
    // Identyfikacja i kontekst
    required CelestialBodyId id,
    required String displayName,
    required DateTime epoch,
    required GeoLocation observerLocation,

    // === ASTRONOMIA (równikowy układ J2000) ===
    required double rightAscension,
    required double declination,
    required double distanceAU,
    required double apparentMagnitude,
    required double altitude,
    required double azimuth,
    required bool isAboveHorizon,

    // === ASTROLOGIA (układ ekliptyczny, geocentryczny) ===
    required double eclipticLongitude,
    required double eclipticLatitude,
    required ZodiacSign zodiacSign,
    required double signDegree,
    required AstrologicalHouse? house,
    required bool isRetrograde,

    // Opcjonalne — null gdy brak efemeryd lub nie obliczono
    DateTime? riseTime,
    DateTime? transitTime,
    DateTime? setTime,
    @Default([]) List<Aspect> aspects,
  }) = _CelestialBody;

  factory CelestialBody.fromJson(Map<String, dynamic> json) =>
      _$CelestialBodyFromJson(json);
}

// ── Enums ─────────────────────────────────────────────────────────────────

enum CelestialBodyId {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
  northNode,
  southNode,
  chiron,
  lilith,
}

enum ZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces;

  /// Każdy znak zajmuje 30°: Baran 0–30°, Byk 30–60°, …
  static ZodiacSign fromEclipticLongitude(double lon) {
    final normalized = lon % 360;
    return ZodiacSign.values[normalized ~/ 30];
  }
}

enum AstrologicalHouse {
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
  eighth,
  ninth,
  tenth,
  eleventh,
  twelfth,
}

enum AspectType { conjunction, sextile, square, trine, opposition }
