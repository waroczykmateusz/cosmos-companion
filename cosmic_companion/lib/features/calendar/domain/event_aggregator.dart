import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/calendar/domain/astro_event.dart';
import 'package:cosmic_companion/features/calendar/domain/transit_calculator.dart';

/// Planets tracked for ingress events in the calendar.
const _ingressBodies = [
  CelestialBodyId.moon,
  CelestialBodyId.sun,
  CelestialBodyId.mercury,
  CelestialBodyId.venus,
  CelestialBodyId.mars,
  CelestialBodyId.jupiter,
  CelestialBodyId.saturn,
];

class EventAggregator {
  const EventAggregator(this._calculator);

  final TransitCalculator _calculator;

  /// Returns all events for the calendar month containing [month], sorted by
  /// time ascending.
  Future<List<AstroEvent>> eventsForMonth(DateTime month) async {
    final start = DateTime.utc(month.year, month.month);
    final end = DateTime.utc(month.year, month.month + 1);

    final results = await Future.wait([
      _calculator.moonPhases(start, end),
      _calculator.ingresses(start, end, _ingressBodies),
    ]);

    return (results[0] + results[1])
      ..sort((a, b) => a.utc.compareTo(b.utc));
  }
}
