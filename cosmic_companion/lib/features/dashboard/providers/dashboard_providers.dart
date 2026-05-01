import 'package:cosmic_companion/core/astronomy/celestial_calculator.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

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
