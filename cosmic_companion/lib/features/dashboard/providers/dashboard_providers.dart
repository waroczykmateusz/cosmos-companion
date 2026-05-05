import 'package:cosmic_companion/core/astronomy/celestial_calculator.dart';
import 'package:cosmic_companion/core/astronomy/ephemeris_service.dart';
import 'package:cosmic_companion/core/utils/time.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sweph/sweph.dart';

// Fallback when GPS is unavailable (Warsaw).
const _defaultLocation = GeoLocation(latitude: 52.23, longitude: 21.01);

final _calculator = CelestialCalculator();

/// Current device location; falls back to Warsaw on permission denial or error.
final currentLocationProvider = FutureProvider<GeoLocation>((ref) async {
  try {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return _defaultLocation;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.medium),
    );
    return GeoLocation(latitude: pos.latitude, longitude: pos.longitude);
  } on Object catch (_) {
    return _defaultLocation;
  }
});

final moonPhaseProvider = FutureProvider.autoDispose<MoonPhase>((ref) {
  return _calculator.computeMoonPhase(DateTime.now().toUtc());
});

final moonBodyProvider =
    FutureProvider.autoDispose<CelestialBody>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  return _calculator.computeBody(
    CelestialBodyId.moon,
    DateTime.now().toUtc(),
    location,
  );
});

/// Generic provider for any celestial body position — keyed by [CelestialBodyId].
final planetBodyProvider = FutureProvider.autoDispose
    .family<CelestialBody, CelestialBodyId>((ref, id) async {
  final location = await ref.watch(currentLocationProvider.future);
  return _calculator.computeBody(id, DateTime.now().toUtc(), location);
});

const _wheelBodyIds = [
  CelestialBodyId.sun,
  CelestialBodyId.moon,
  CelestialBodyId.mercury,
  CelestialBodyId.venus,
  CelestialBodyId.mars,
  CelestialBodyId.jupiter,
  CelestialBodyId.saturn,
  CelestialBodyId.uranus,
  CelestialBodyId.neptune,
  CelestialBodyId.pluto,
];

final horoscopeWheelProvider =
    FutureProvider.autoDispose<List<CelestialBody>>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  final now = DateTime.now().toUtc();
  return Future.wait(
    _wheelBodyIds.map((id) => _calculator.computeBody(id, now, location)),
  );
});

enum SeeingRating { excellent, good, fair, poor, bad }

/// Mock seeing indicator — deterministic per day-of-year, not real.
final mockSeeingProvider = Provider<SeeingRating>((ref) {
  final doy = DateTime.now()
      .difference(DateTime(DateTime.now().year))
      .inDays;
  return SeeingRating.values[doy % SeeingRating.values.length];
});

/// Astronomical twilight end = moment sun reaches -18° altitude after sunset.
final astroTwilightProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  await EphemerisService.ensureInitialized();
  final location = await ref.watch(currentLocationProvider.future);
  final today = DateTime.now().toUtc();
  final midnightJD = TimeUtils.toJulianDay(
      DateTime.utc(today.year, today.month, today.day));
  final rst = EphemerisService.calcRiseSetTransitJD(
      HeavenlyBody.SE_SUN, midnightJD, location);
  if (rst.setJD == null) return null;
  // Search up to 4 hours after sunset for sun to reach -18°
  return _findSunAltCrossing(rst.setJD!, rst.setJD! + 4 / 24, -18, location);
});

/// Astronomical dawn start = moment sun reaches -18° altitude before sunrise.
final astroDawnProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  await EphemerisService.ensureInitialized();
  final location = await ref.watch(currentLocationProvider.future);
  final today = DateTime.now().toUtc();
  final midnightJD = TimeUtils.toJulianDay(
      DateTime.utc(today.year, today.month, today.day));
  final rst = EphemerisService.calcRiseSetTransitJD(
      HeavenlyBody.SE_SUN, midnightJD, location);
  if (rst.riseJD == null) return null;
  // Search up to 4 hours before sunrise for sun to reach -18°
  return _findSunAltCrossing(rst.riseJD! - 4.0 / 24.0, rst.riseJD!, -18, location);
});

double _sunAltAtJD(double jd, GeoLocation location) {
  final ecl = EphemerisService.calcEcliptic(HeavenlyBody.SE_SUN, jd);
  final hor = EphemerisService.calcHorizontal(jd, location, ecl);
  return hor.apparentAltitude;
}

/// Bisection search for when the sun crosses [targetAlt] between [jdA] and [jdB].
/// Returns null if no crossing exists in the interval.
DateTime? _findSunAltCrossing(
    double jdA, double jdB, double targetAlt, GeoLocation location) {
  var altA = _sunAltAtJD(jdA, location);
  var altB = _sunAltAtJD(jdB, location);
  if ((altA - targetAlt).sign == (altB - targetAlt).sign) return null;

  var lo = jdA;
  var hi = jdB;
  var altLo = altA;

  for (var i = 0; i < 35; i++) {
    final mid = (lo + hi) / 2;
    final altMid = _sunAltAtJD(mid, location);
    if ((hi - lo) < 1.0 / 86400.0) break; // < 1 second
    if ((altMid - targetAlt).sign == (altLo - targetAlt).sign) {
      lo = mid;
      altLo = altMid;
    } else {
      hi = mid;
    }
  }

  return TimeUtils.fromJulianDay((lo + hi) / 2);
}
