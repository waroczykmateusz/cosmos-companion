import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

/// Estimates Bortle level by sampling the NASA VIIRS Black Marble tile
/// at the observer's exact coordinates.
///
/// Falls back to a coordinate hash when the network is unavailable.
class BortleClassifier {
  const BortleClassifier();

  Future<BortleLevel> estimate(double lat, double lon) async {
    try {
      return await _sampleViirsTile(lat, lon);
    } on Exception catch (_) {
      return _fallback(lat, lon);
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

    // GIBS WMTS URL: {z}/{y}/{x} (TileMatrix/TileRow/TileCol)
    const base = 'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best'
        '/VIIRS_Black_Marble/default/2016-01-01'
        '/GoogleMapsCompatible_Level8';
    final url = '$base/$z/$tileY/$tileX.png';

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'com.waroczyk.cosmic_companion');
      final response = await request.close();
      if (response.statusCode != 200) return _fallback(lat, lon);

      final chunks = <int>[];
      await for (final chunk in response) {
        chunks.addAll(chunk);
      }
      final bytes = Uint8List.fromList(chunks);

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData();
      if (byteData == null) return _fallback(lat, lon);

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

  static BortleLevel _fallback(double lat, double lon) {
    final hash = (lat.abs() * 1000 + lon.abs() * 100).toInt();
    return BortleLevel.fromValue((hash % 9) + 1);
  }
}
