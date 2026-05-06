import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dso/domain/dso_catalog.dart';
import 'package:cosmic_companion/features/dso/domain/dso_visibility.dart';
import 'package:cosmic_companion/features/map/domain/bortle_classifier.dart';
import 'package:cosmic_companion/features/weather/domain/weather_data.dart';
import 'package:cosmic_companion/features/weather/services/weather_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

const _classifier = BortleClassifier();

/// Bortle level at the user's current GPS location.
final bortleLevelProvider = FutureProvider.autoDispose<BortleLevel>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  return _classifier.estimate(location.latitude, location.longitude);
});

/// Location selected by the user by tapping the map. Null = nothing selected.
final selectedPlannerLocationProvider = StateProvider<LatLng?>((ref) => null);

/// Bortle level at the planner (tapped) location.
final plannerBortleProvider = FutureProvider.autoDispose<BortleLevel?>((ref) async {
  final loc = ref.watch(selectedPlannerLocationProvider);
  if (loc == null) return null;
  return _classifier.estimate(loc.latitude, loc.longitude);
});

/// Weather forecast at the planner (tapped) location. Null while loading or on error.
final plannerWeatherProvider =
    FutureProvider.autoDispose<WeatherForecast?>((ref) async {
  final loc = ref.watch(selectedPlannerLocationProvider);
  if (loc == null) return null;
  return const WeatherService().fetchForecast(loc.latitude, loc.longitude);
});

/// DSO visibility tonight at the planner location, sorted descending by score.
/// Cloud cover from the planner weather is included in the score.
final plannerDsoProvider =
    FutureProvider.autoDispose<List<DsoVisibilityResult>?>((ref) async {
  final loc = ref.watch(selectedPlannerLocationProvider);
  if (loc == null) return null;

  final bortle = await ref.watch(plannerBortleProvider.future);
  if (bortle == null) return null;

  final moonPhase = await ref.watch(moonPhaseProvider.future);
  final moonBody = await ref.watch(moonBodyProvider.future);
  final weather = await ref.watch(plannerWeatherProvider.future);
  final cloudCover = weather?.tonightCloudCoverPct ?? 0;

  final now = DateTime.now().toUtc();
  final midnight = DateTime.utc(now.year, now.month, now.day);

  return DsoCatalog.all
      .map(
        (dso) => DsoVisibility.compute(
          dso,
          midnight,
          loc.latitude,
          loc.longitude,
          moonPhase.illuminationPercent,
          moonBody.rightAscension,
          moonBody.declination,
          bortle.value,
          cloudCover,
        ),
      )
      .where((r) => r.isVisible)
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));
});
