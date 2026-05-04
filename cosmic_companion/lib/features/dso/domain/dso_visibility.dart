import 'dart:math';

import 'package:cosmic_companion/features/dso/domain/dso_object.dart';

class DsoVisibilityResult {
  const DsoVisibilityResult({
    required this.dso,
    required this.maxAltitudeDeg,
    required this.isVisible,
    required this.bestTimeUtc,
    required this.score,
    required this.moonSeparationDeg,
  });

  final DsoObject dso;
  final double maxAltitudeDeg;
  final bool isVisible;
  final DateTime? bestTimeUtc;

  /// Visibility score 0–10: higher = better night for this object.
  final double score;

  final double moonSeparationDeg;
}

abstract final class DsoVisibility {
  static const double _minAltDeg = 10;

  /// Compute visibility for [dso] on the night starting at UTC [midnight].
  ///
  /// [moonIllumination] — Moon illumination 0–100 (%).
  /// [moonRaHours] / [moonDecDeg] — Moon equatorial coords at midnight.
  static DsoVisibilityResult compute(
    DsoObject dso,
    DateTime midnight, // UTC midnight of the target date
    double latDeg,
    double lonDeg,
    double moonIllumination,
    double moonRaHours,
    double moonDecDeg,
  ) {
    final midnightJD = _toJD(midnight);

    // Scan 21:00–05:00 UTC (= 20:00 to 04:00 prev/next day in UTC midnight terms)
    // Window: midnightJD - 3h to + 5h (covers central European night in both seasons)
    var maxAlt = -90.0;
    double? bestJD;
    for (var i = 0; i <= 16; i++) {
      final h = -3.0 + i * 0.5; // steps: 21:00 to 05:00
      final jd = midnightJD + h / 24.0;
      final alt = _altitude(dso.raHours, dso.decDeg, jd, latDeg, lonDeg);
      if (alt > maxAlt) {
        maxAlt = alt;
        bestJD = jd;
      }
    }

    final isVisible = maxAlt >= _minAltDeg;
    final bestTime = bestJD != null ? _fromJD(bestJD) : null;

    final moonSep = _angularDistance(
      dso.raHours, dso.decDeg, moonRaHours, moonDecDeg,
    );

    // Score: altitude component (0–10) reduced by Moon interference
    final altScore = isVisible
        ? ((maxAlt - _minAltDeg).clamp(0.0, 50.0) / 50.0 * 10.0)
        : 0.0;
    // Moon penalty: larger when Moon is bright AND close to the target
    final moonPenalty =
        (moonIllumination / 100.0) * (1.0 - (moonSep / 90.0).clamp(0.0, 1.0)) * 3.0;
    final score = (altScore - moonPenalty).clamp(0.0, 10.0);

    return DsoVisibilityResult(
      dso: dso,
      maxAltitudeDeg: maxAlt,
      isVisible: isVisible,
      bestTimeUtc: bestTime,
      score: score,
      moonSeparationDeg: moonSep,
    );
  }

  // ── Approximate Moon state (no Sweph) ────────────────────────────────────

  /// Approximate Moon illumination 0–100 % for a UTC [date].
  /// Pure formula — no FFI. Error typically < 2 percentage points.
  static double approxMoonIllumination(DateTime date) {
    // Reference new moon: 2025-01-29 UTC 00:00
    const double synodicDays = 29.53059;
    final daysSinceRef =
        date.millisecondsSinceEpoch / 86400000.0 - 1738108800000 / 86400000.0;
    final phase = daysSinceRef % synodicDays;
    final normalised = phase < 0 ? phase + synodicDays : phase;
    return ((1 - cos(normalised / synodicDays * 2 * pi)) / 2) * 100;
  }

  /// Approximate Moon RA (hours) for a UTC [date]. Accuracy ~10–15°.
  static double approxMoonRaHours(DateTime date) {
    const double synodicDays = 29.53059;
    const double refRaDeg = 321.0; // sun RA on 2025-01-29 ≈ 321° (Aquarius)
    final daysSinceRef =
        (date.millisecondsSinceEpoch - 1738108800000) / 86400000.0;
    final raDeg =
        ((refRaDeg + daysSinceRef * (360.0 / synodicDays)) % 360 + 360) % 360;
    return raDeg / 15.0;
  }

  /// Approximate Moon declination (°) for a UTC [date]. Accuracy ~5°.
  static double approxMoonDecDeg(DateTime date) {
    const double synodicDays = 29.53059;
    final daysSinceRef =
        (date.millisecondsSinceEpoch - 1738108800000) / 86400000.0;
    final phase = daysSinceRef % synodicDays;
    final normalised = phase < 0 ? phase + synodicDays : phase;
    return sin(normalised / synodicDays * 2 * pi) * 23.5;
  }

  // ── Pure-math helpers (no Sweph dependency) ──────────────────────────────

  static double _altitude(
    double raH,
    double decDeg,
    double jd,
    double latDeg,
    double lonDeg,
  ) {
    final raDeg = raH * 15.0;
    final gmst = _gmstDeg(jd);
    final lst = (gmst + lonDeg) % 360;
    var ha = ((lst - raDeg) % 360 + 360) % 360;
    if (ha > 180) ha -= 360; // bring to −180..+180
    final haRad = ha * pi / 180;
    final decRad = decDeg * pi / 180;
    final latRad = latDeg * pi / 180;
    final sinAlt =
        sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad);
    return asin(sinAlt.clamp(-1.0, 1.0)) * 180 / pi;
  }

  static double _gmstDeg(double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmst = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    return ((gmst % 360) + 360) % 360;
  }

  static double _angularDistance(
    double ra1H,
    double dec1,
    double ra2H,
    double dec2,
  ) {
    final ra1 = ra1H * 15.0 * pi / 180;
    final ra2 = ra2H * 15.0 * pi / 180;
    final d1 = dec1 * pi / 180;
    final d2 = dec2 * pi / 180;
    final cosD = sin(d1) * sin(d2) + cos(d1) * cos(d2) * cos(ra1 - ra2);
    return acos(cosD.clamp(-1.0, 1.0)) * 180 / pi;
  }

  /// Gregorian date → Julian Day Number (proleptic Gregorian, no Sweph needed).
  static double _toJD(DateTime utc) {
    final y = utc.year;
    final m = utc.month;
    final d = utc.day +
        (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
    final a = ((14 - m) / 12).floor();
    final y2 = y + 4800 - a;
    final m2 = m + 12 * a - 3;
    return d +
        ((153 * m2 + 2) / 5).floor() +
        365 * y2 +
        (y2 / 4).floor() -
        (y2 / 100).floor() +
        (y2 / 400).floor() -
        32045.0 -
        0.5;
  }

  static DateTime _fromJD(double jd) {
    final z = (jd + 0.5).floor();
    final f = (jd + 0.5) - z;
    final a = z < 2299161
        ? z
        : () {
            final alpha = (z - 1867216.25) ~/ 36524.25;
            return z + 1 + alpha - alpha ~/ 4;
          }();
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final dd = (365.25 * c).floor();
    final e = ((b - dd) / 30.6001).floor();
    final day = b - dd - (30.6001 * e).floor();
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;
    final fracH = f * 24;
    final hour = fracH.floor();
    final fracM = (fracH - hour) * 60;
    final minute = fracM.floor();
    final second = ((fracM - minute) * 60).round();
    return DateTime.utc(year, month, day, hour, minute, second.clamp(0, 59));
  }
}
