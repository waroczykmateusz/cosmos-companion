import 'package:cosmic_companion/features/calendar/domain/astro_event.dart';
import 'package:cosmic_companion/features/calendar/domain/event_aggregator.dart';
import 'package:cosmic_companion/features/calendar/domain/transit_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _aggregatorProvider = Provider<EventAggregator>(
  (ref) => const EventAggregator(TransitCalculator()),
);

/// Currently displayed month (UTC, day=1).
final calendarMonthProvider = StateProvider<DateTime>(
  (ref) {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month);
  },
);

/// Events for the selected month.
final calendarEventsProvider =
    FutureProvider.autoDispose<List<AstroEvent>>((ref) {
  final month = ref.watch(calendarMonthProvider);
  final aggregator = ref.watch(_aggregatorProvider);
  return aggregator.eventsForMonth(month);
});
