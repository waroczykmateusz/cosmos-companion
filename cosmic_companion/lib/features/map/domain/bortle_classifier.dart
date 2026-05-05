import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Estimates Bortle level by sampling the NASA VIIRS Black Marble tile
/// at the observer's exact coordinates.
///
/// Results are cached in memory and in SharedPreferences (TTL 30 days).
/// Falls back to the last known cached value, or Bortle 5 if no cache exists.
class BortleClassifier {
  const BortleClassifier();

  static final Map<String, BortleLevel> _memCache = {};
  static const _ttl = Duration(days: 30);

  static String _cacheKey(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  Future<BortleLevel> estimate(double lat, double lon) async {
    final key = _cacheKey(lat, lon);

    if (_memCache.containsKey(key)) return _memCache[key]!;

    final prefs = await SharedPreferences.getInstance();
    final cachedValue = prefs.getInt('bortle_v_$key');
    final cachedTs = prefs.getInt('bortle_ts_$key');

    if (cachedValue != null && cachedTs != null) {
      final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
      if (age < _ttl.inMilliseconds) {
        final level = BortleLevel.fromValue(cachedValue);
        _memCache[key] = level;
        return level;
      }
    }

    try {
      final level = await _sampleViirsTile(lat, lon);
      _memCache[key] = level;
      await prefs.setInt('bortle_v_$key', level.value);
      await prefs.setInt('bortle_ts_$key', DateTime.now().millisecondsSinceEpoch);
      return level;
    } on Exception catch (_) {
      // Stale cache is better than pseudorandom; neutral Bortle 5 as last resort.
      if (cachedValue != null) return BortleLevel.fromValue(cachedValue);
      return BortleLevel.five;
    }
  }

  Future<BortleLevel> _sampleViirsTile(double lat, double lon) async {
    const z = 8;
    const n = 256; // 2^8 tiles per axis

    final tileX = ((lon + 180.0) / 360.0 * n).floor().clamp(0, n - 1);
    final latRad = lat * pi / 180.0;
    final mercY = (1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0;
    final tileY = (mercY * n).floor().clamp(0, n - 1);

    final pixX = (((lon + 180.0) / 360.0 * n - tileX) * 256).floor().clamp(0, 255);
    final pixY = ((mercY * n - tileY) * 256).floor().clamp(0, 255);

    const base = 'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best'
        '/VIIRS_Black_Marble/default/2016-01-01'
        '/GoogleMapsCompatible_Level8';
    final url = '$base/$z/$tileY/$tileX.png';

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'com.waroczyk.cosmic_companion');
      final response = await request.close();
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

      final chunks = <int>[];
      await for (final chunk in response) {
        chunks.addAll(chunk);
      }
      final bytes = Uint8List.fromList(chunks);

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData();
      if (byteData == null) throw Exception('No pixel data');

      final offset = (pixY * image.width + pixX) * 4;
      final r = byteData.getUint8(offset);
      final g = byteData.getUint8(offset + 1);
      final b = byteData.getUint8(offset + 2);
      final lum = (r * 0.299 + g * 0.587 + b * 0.114).round();
      return BortleLevel.fromValue(_luminanceToBortle(lum));
    } finally {
      client.close();
    }
  }

  static int _luminanceToBortle(int lum) {
    if (lum < 10) return 1;
    if (lum < 25) return 2;
    if (lum < 50) return 3;
    if (lum < 80) return 4;
    if (lum < 110) return 5;
    if (lum < 145) return 6;
    if (lum < 180) return 7;
    if (lum < 215) return 8;
    return 9;
  }
}
