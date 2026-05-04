import 'dart:convert';

import 'package:cosmic_companion/features/weather/domain/weather_data.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  const WeatherService();

  Future<WeatherForecast?> fetchForecast(double lat, double lon) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': lat.toStringAsFixed(4),
        'longitude': lon.toStringAsFixed(4),
        'hourly':
            'cloud_cover,precipitation_probability,wind_speed_10m',
        'forecast_days': '7',
        'timezone': 'auto',
        'wind_speed_unit': 'kmh',
      });

      final response =
          await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final hourly = body['hourly'] as Map<String, dynamic>;

      final times = (hourly['time'] as List).cast<String>();
      final clouds = (hourly['cloud_cover'] as List)
          .map((e) => (e as num?)?.toInt() ?? 0)
          .toList();
      final precip = (hourly['precipitation_probability'] as List)
          .map((e) => (e as num?)?.toInt() ?? 0)
          .toList();
      final wind = (hourly['wind_speed_10m'] as List)
          .map((e) => (e as num?)?.toDouble() ?? 0.0)
          .toList();

      final entries = List.generate(
        times.length,
        (i) => HourlyWeather(
          time: DateTime.parse(times[i]),
          cloudCoverPct: clouds[i],
          precipitationProbabilityPct: precip[i],
          windSpeedKmh: wind[i],
        ),
      );

      return WeatherForecast(hourly: entries);
    } on Object {
      return null;
    }
  }
}
