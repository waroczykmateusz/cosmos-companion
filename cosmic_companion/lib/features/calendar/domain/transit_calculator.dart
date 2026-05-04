import 'package:cosmic_companion/core/astronomy/ephemeris_service.dart';
import 'package:cosmic_companion/core/utils/time.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:cosmic_companion/features/calendar/domain/astro_event.dart';
import 'package:sweph/sweph.dart';

class TransitCalculator {
  const TransitCalculator();

  /// Returns all moon phase events (new, first quarter, full, last quarter)
  /// that occur within [start, end).
  Future<List<AstroEvent>> moonPhases(DateTime start, DateTime end) async {
    await EphemerisService.ensureInitialized();

    const targets = [0.0, 90.0, 180.0, 270.0];
    final events = <AstroEvent>[];
    const step = Duration(hours: 6);

    var t = start;
    var prevAngle = _moonPhaseAngle(t);

    while (t.isBefore(end)) {
      final next = t.add(step);
      final nextAngle = _moonPhaseAngle(next);

      for (final target in targets) {
        if (_angleIntervalContains(prevAngle, nextAngle, target)) {
          final exact = _bisectAngle(t, next, target, _moonPhaseAngle);
          events.add(AstroEvent(
            utc: exact,
            type: AstroEventType.moonPhase,
            body: CelestialBodyId.moon,
            moonPhase: MoonPhaseName.fromAngle(target),
          ));
        }
      }

      prevAngle = nextAngle;
      t = next;
    }

    return events;
  }

  /// Returns planetary ingress events (body enters new zodiac sign) within
  /// [start, end) for the given [bodies].
  Future<List<AstroEvent>> ingresses(
    DateTime start,
    DateTime end,
    List<CelestialBodyId> bodies,
  ) async {
    await EphemerisService.ensureInitialized();

    final events = <AstroEvent>[];

    for (final id in bodies) {
      final swBody = EphemerisService.toSwephBody(id);
      // Moon moves ~13°/day → scan every 2 h; others scan every 6 h
      final step = id == CelestialBodyId.moon
          ? const Duration(hours: 2)
          : const Duration(hours: 6);

      var t = start;
      var prevSign = _signIndex(_eclipticLon(swBody, t));

      while (t.isBefore(end)) {
        final next = t.add(step);
        final nextSign = _signIndex(_eclipticLon(swBody, next));

        if (prevSign != nextSign) {
          final exact = _bisectIngress(t, next, swBody, nextSign);
          events.add(AstroEvent(
            utc: exact,
            type: id == CelestialBodyId.moon
                ? AstroEventType.moonIngress
                : AstroEventType.planetaryIngress,
            body: id,
            ingressSign: ZodiacSign.values[nextSign],
          ));
        }

        prevSign = nextSign;
        t = next;
      }
    }

    return events;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  double _moonPhaseAngle(DateTime t) {
    final jd = TimeUtils.toJulianDay(t);
    final moonLon =
        EphemerisService.calcEcliptic(HeavenlyBody.SE_MOON, jd).longitude;
    final sunLon =
        EphemerisService.calcEcliptic(HeavenlyBody.SE_SUN, jd).longitude;
    return (moonLon - sunLon) % 360;
  }

  double _eclipticLon(HeavenlyBody body, DateTime t) {
    final jd = TimeUtils.toJulianDay(t);
    return EphemerisService.calcEcliptic(body, jd).longitude % 360;
  }

  int _signIndex(double lon) => (lon / 30).floor() % 12;

  /// True when the interval (prevAngle, nextAngle] — moving forward in the
  /// 0-360 cycle — contains [target].
  bool _angleIntervalContains(double prev, double next, double target) {
    final p = prev % 360;
    final n = next % 360;
    // Normal case: no wraparound
    if (p <= n) return p < target && target <= n;
    // Wraparound through 0°
    return target > p || target <= n;
  }

  /// Bisects to find the exact DateTime when [angleOf] crosses [target].
  /// Converges to ~1-minute precision in 12 iterations.
  DateTime _bisectAngle(
    DateTime loInit,
    DateTime hiInit,
    double target,
    double Function(DateTime) angleOf,
  ) {
    var lo = loInit;
    var hi = hiInit;
    for (var i = 0; i < 20; i++) {
      final mid = lo.add(hi.difference(lo) ~/ 2);
      if (_angleIntervalContains(angleOf(lo), angleOf(mid), target)) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return lo.add(hi.difference(lo) ~/ 2);
  }

  /// Bisects to find the exact DateTime when [body] enters sign [targetSign].
  DateTime _bisectIngress(
    DateTime loInit,
    DateTime hiInit,
    HeavenlyBody body,
    int targetSign,
  ) {
    var lo = loInit;
    var hi = hiInit;
    for (var i = 0; i < 20; i++) {
      final mid = lo.add(hi.difference(lo) ~/ 2);
      if (_signIndex(_eclipticLon(body, mid)) != targetSign) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return lo.add(hi.difference(lo) ~/ 2);
  }
}
