import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/weather/domain/weather_data.dart';
import 'package:cosmic_companion/features/weather/services/weather_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full 7-day forecast from Open-Meteo. Null on error or no connectivity.
final weatherForecastProvider =
    FutureProvider.autoDispose<WeatherForecast?>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  return const WeatherService()
      .fetchForecast(location.latitude, location.longitude);
});

/// Tonight's cloud cover 0–100 %. Null while loading or on network error.
final cloudCoverProvider = Provider.autoDispose<int?>((ref) =>
    ref.watch(weatherForecastProvider).valueOrNull?.tonightCloudCoverPct);

/// 7-day list of night cloud cover (index 0 = tonight). Empty while loading.
final weekCloudCoverProvider = Provider.autoDispose<List<int>>((ref) =>
    ref.watch(weatherForecastProvider).valueOrNull?.weekNightCloudCoverPct ??
    const []);

/// Seeing derived from real cloud cover; falls back to mock when unavailable.
final weatherSeeingProvider = Provider.autoDispose<SeeingRating>((ref) {
  final cloud = ref.watch(cloudCoverProvider);
  if (cloud == null) return ref.watch(mockSeeingProvider);
  if (cloud < 10) return SeeingRating.excellent;
  if (cloud < 30) return SeeingRating.good;
  if (cloud < 60) return SeeingRating.fair;
  if (cloud < 85) return SeeingRating.poor;
  return SeeingRating.bad;
});
