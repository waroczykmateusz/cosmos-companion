/// Hourly weather snapshot from Open-Meteo.
class HourlyWeather {
  const HourlyWeather({
    required this.time,
    required this.cloudCoverPct,
    required this.precipitationProbabilityPct,
    required this.windSpeedKmh,
  });

  final DateTime time;
  final int cloudCoverPct;
  final int precipitationProbabilityPct;
  final double windSpeedKmh;
}

/// 7-day hourly forecast from Open-Meteo (168 hourly entries, local time).
class WeatherForecast {
  const WeatherForecast({required this.hourly});

  final List<HourlyWeather> hourly;

  /// Average cloud cover (0–100 %) during tonight's dark hours (21–05 local).
  int get tonightCloudCoverPct => _nightAvg(0);

  /// Average precipitation probability (0–100 %) tonight.
  int get tonightPrecipPct {
    final slice = _slice(0);
    if (slice.isEmpty) return 0;
    return (slice
                .map((h) => h.precipitationProbabilityPct)
                .reduce((a, b) => a + b) /
            slice.length)
        .round();
  }

  /// Night cloud cover for each of the next 7 days (index 0 = tonight).
  List<int> get weekNightCloudCoverPct =>
      List.generate(7, _nightAvg, growable: false);

  /// Hourly entries for tonight: 21:00–05:00 (next day) in local time.
  List<HourlyWeather> get tonightHourly {
    if (hourly.isEmpty) return const [];
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 21);
    final end = DateTime(now.year, now.month, now.day + 1, 5);
    return hourly
        .where((h) => !h.time.isBefore(start) && h.time.isBefore(end))
        .toList();
  }

  List<HourlyWeather> _slice(int dayIndex) {
    final start = dayIndex * 24 + 21;
    final end = (dayIndex * 24 + 29).clamp(0, hourly.length); // 05:00 next day
    if (start >= hourly.length) return const [];
    return hourly.sublist(start, end);
  }

  int _nightAvg(int dayIndex) {
    final slice = _slice(dayIndex);
    if (slice.isEmpty) return 50;
    return (slice.map((h) => h.cloudCoverPct).reduce((a, b) => a + b) /
            slice.length)
        .round();
  }
}
