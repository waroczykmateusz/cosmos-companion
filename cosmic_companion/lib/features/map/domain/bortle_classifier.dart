import 'package:flutter/material.dart';

/// Nine-level Bortle dark-sky scale (1 = best, 9 = worst).
enum BortleLevel {
  one(1, 'Idealne ciemne niebo', Color(0xFF0D1B2A)),
  two(2, 'Doskonałe ciemne niebo', Color(0xFF1A2E44)),
  three(3, 'Wiejskie niebo', Color(0xFF1F4068)),
  four(4, 'Wiejsko-podmiejskie', Color(0xFF1B6CA8)),
  five(5, 'Podmiejskie', Color(0xFF2E8B57)),
  six(6, 'Jasne podmiejskie', Color(0xFFDAA520)),
  seven(7, 'Podmiejskie/miejskie', Color(0xFFFF8C00)),
  eight(8, 'Miejskie', Color(0xFFFF4500)),
  nine(9, 'Centrum miasta', Color(0xFFDC143C));

  const BortleLevel(this.value, this.description, this.color);

  final int value;
  final String description;
  final Color color;

  static BortleLevel fromValue(int v) =>
      BortleLevel.values.firstWhere((b) => b.value == v.clamp(1, 9));
}

/// Estimates Bortle level from location.
///
/// MVP: deterministic mock. Real implementation would sample the VIIRS
/// light-pollution tile pixel at the observer's coordinates.
class BortleClassifier {
  const BortleClassifier();

  BortleLevel estimate(double latitude, double longitude) {
    // Simple deterministic mock based on coordinates.
    // Replace with actual tile-sampling when light-pollution overlay is wired.
    final hash = (latitude.abs() * 1000 + longitude.abs() * 100).toInt();
    return BortleLevel.fromValue((hash % 9) + 1);
  }
}
