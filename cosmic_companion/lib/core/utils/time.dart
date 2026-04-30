import 'package:sweph/sweph.dart';

abstract final class TimeUtils {
  /// DateTime UTC → Julian Day Number (do obliczeń efemerydowych).
  static double toJulianDay(DateTime utc) {
    final hours = utc.hour + utc.minute / 60.0 + utc.second / 3600.0;
    return Sweph.swe_julday(
      utc.year,
      utc.month,
      utc.day,
      hours,
      CalendarType.SE_GREG_CAL,
    );
  }

  /// Julian Day → DateTime UTC.
  static DateTime fromJulianDay(double jd) =>
      Sweph.swe_jdet_to_utc(jd, CalendarType.SE_GREG_CAL);
}
