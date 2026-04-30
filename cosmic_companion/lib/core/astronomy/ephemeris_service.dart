import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:sweph/sweph.dart';

abstract final class EphemerisService {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Sweph.init(epheAssets: Sweph.bundledEpheAssets);
    _initialized = true;
  }

  /// Pozycja w układzie ekliptycznym (lon, lat, dist, speedInLon…).
  static CoordinatesWithSpeed calcEcliptic(HeavenlyBody body, double jd) =>
      Sweph.swe_calc_ut(
        jd,
        body,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED,
      );

  /// Pozycja w układzie równikowym (RA h, Dec °).
  static CoordinatesWithSpeed calcEquatorial(HeavenlyBody body, double jd) =>
      Sweph.swe_calc_ut(
        jd,
        body,
        SwephFlag.SEFLG_SWIEPH |
            SwephFlag.SEFLG_EQUATORIAL |
            SwephFlag.SEFLG_SPEED,
      );

  /// Azymut i wysokość nad horyzontem dla obserwatora.
  /// GeoPosition: longitude first (wymagane przez SwissEph).
  static AzimuthAltitudeInfo calcHorizontal(
    double jd,
    GeoLocation location,
    CoordinatesWithSpeed eclipticCoords,
  ) =>
      Sweph.swe_azalt(
        jd,
        AzAltMode.SE_ECL2HOR,
        GeoPosition(
          location.longitude,
          location.latitude,
          location.elevationMeters,
        ),
        1013.25, // standardowe ciśnienie [mbar]
        15,      // standardowa temperatura [°C]
        Coordinates(
          eclipticCoords.longitude,
          eclipticCoords.latitude,
          eclipticCoords.distance,
        ),
      );

  /// Dane fenomenologiczne: [phaseAngle, illumination, elongation, discDiam, magnitude].
  static List<double> calcPhenomena(HeavenlyBody body, double jd) =>
      Sweph.swe_pheno_ut(jd, body, SwephFlag.SEFLG_SWIEPH);

  static HeavenlyBody toSwephBody(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => HeavenlyBody.SE_SUN,
        CelestialBodyId.moon => HeavenlyBody.SE_MOON,
        CelestialBodyId.mercury => HeavenlyBody.SE_MERCURY,
        CelestialBodyId.venus => HeavenlyBody.SE_VENUS,
        CelestialBodyId.mars => HeavenlyBody.SE_MARS,
        CelestialBodyId.jupiter => HeavenlyBody.SE_JUPITER,
        CelestialBodyId.saturn => HeavenlyBody.SE_SATURN,
        CelestialBodyId.uranus => HeavenlyBody.SE_URANUS,
        CelestialBodyId.neptune => HeavenlyBody.SE_NEPTUNE,
        CelestialBodyId.pluto => HeavenlyBody.SE_PLUTO,
        CelestialBodyId.northNode => HeavenlyBody.SE_TRUE_NODE,
        CelestialBodyId.southNode => HeavenlyBody.SE_TRUE_NODE,
        CelestialBodyId.chiron => HeavenlyBody.SE_CHIRON,
        CelestialBodyId.lilith => HeavenlyBody.SE_MEAN_APOG,
      };
}
