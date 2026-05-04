import 'dart:math';

import 'package:cosmic_companion/core/astronomy/ephemeris_service.dart';
import 'package:cosmic_companion/core/utils/time.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:sweph/sweph.dart';

class CelestialCalculator {
  Future<CelestialBody> computeBody(
    CelestialBodyId id,
    DateTime utc,
    GeoLocation location,
  ) async {
    await EphemerisService.ensureInitialized();

    final jd = TimeUtils.toJulianDay(utc);
    final swephBody = EphemerisService.toSwephBody(id);

    final ecl = EphemerisService.calcEcliptic(swephBody, jd);
    final eq = EphemerisService.calcEquatorial(swephBody, jd);
    final hor = EphemerisService.calcHorizontal(jd, location, ecl);
    final pheno = EphemerisService.calcPhenomena(swephBody, jd);

    final zodiac = ZodiacSign.fromEclipticLongitude(ecl.longitude);
    final signDeg = ecl.longitude % 30;

    // RA z SwissEph SEFLG_EQUATORIAL jest w stopniach → konwersja do godzin
    final raHours = eq.longitude / 15.0;

    final today = DateTime.utc(utc.year, utc.month, utc.day);
    final midnightJD = TimeUtils.toJulianDay(today);
    final rst =
        EphemerisService.calcRiseSetTransitJD(swephBody, midnightJD, location);

    DateTime? jdToDateTime(double? jd) =>
        jd != null ? TimeUtils.fromJulianDay(jd) : null;

    return CelestialBody(
      id: id,
      displayName: _displayName(id),
      epoch: utc,
      observerLocation: location,
      rightAscension: raHours,
      declination: eq.latitude,
      distanceAU: ecl.distance,
      apparentMagnitude: pheno.length > 4 ? pheno[4] : 0,
      altitude: hor.apparentAltitude,
      azimuth: hor.azimuth,
      isAboveHorizon: hor.apparentAltitude > 0,
      eclipticLongitude: ecl.longitude,
      eclipticLatitude: ecl.latitude,
      zodiacSign: zodiac,
      signDegree: signDeg,
      house: null,
      isRetrograde: ecl.speedInLongitude < 0,
      riseTime: jdToDateTime(rst.riseJD),
      transitTime: jdToDateTime(rst.transitJD),
      setTime: jdToDateTime(rst.setJD),
    );
  }

  Future<MoonPhase> computeMoonPhase(DateTime utc) async {
    await EphemerisService.ensureInitialized();

    final jd = TimeUtils.toJulianDay(utc);
    final moonEcl = EphemerisService.calcEcliptic(HeavenlyBody.SE_MOON, jd);
    final sunEcl = EphemerisService.calcEcliptic(HeavenlyBody.SE_SUN, jd);

    final phaseAngle = (moonEcl.longitude - sunEcl.longitude) % 360;
    // Illumination z fazy kątowej: (1 - cos(angle)) / 2 * 100
    final illumination =
        (1 - cos(phaseAngle * pi / 180)) / 2 * 100;

    return MoonPhase(
      name: MoonPhaseName.fromAngle(phaseAngle),
      illuminationPercent: illumination,
      phaseAngle: phaseAngle,
      epoch: utc,
    );
  }

  static String _displayName(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => 'Słońce',
        CelestialBodyId.moon => 'Księżyc',
        CelestialBodyId.mercury => 'Merkury',
        CelestialBodyId.venus => 'Wenus',
        CelestialBodyId.mars => 'Mars',
        CelestialBodyId.jupiter => 'Jowisz',
        CelestialBodyId.saturn => 'Saturn',
        CelestialBodyId.uranus => 'Uran',
        CelestialBodyId.neptune => 'Neptun',
        CelestialBodyId.pluto => 'Pluton',
        CelestialBodyId.northNode => 'Węzeł Północny',
        CelestialBodyId.southNode => 'Węzeł Południowy',
        CelestialBodyId.chiron => 'Chiron',
        CelestialBodyId.lilith => 'Lilith',
      };
}
