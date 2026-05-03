import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dso/domain/dso_catalog.dart';
import 'package:cosmic_companion/features/dso/domain/dso_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Visible DSO tonight, sorted descending by score. Filters out score == 0.
final visibleDsoTodayProvider =
    FutureProvider.autoDispose<List<DsoVisibilityResult>>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  final moonPhase = await ref.watch(moonPhaseProvider.future);
  final moonBody = await ref.watch(moonBodyProvider.future);

  final now = DateTime.now().toUtc();
  final midnight = DateTime.utc(now.year, now.month, now.day);

  final results = DsoCatalog.all
      .map(
        (dso) => DsoVisibility.compute(
          dso,
          midnight,
          location.latitude,
          location.longitude,
          moonPhase.illuminationPercent,
          moonBody.rightAscension,
          moonBody.declination,
        ),
      )
      .where((r) => r.isVisible)
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  return results;
});

/// For each day in the given month: whether any DSO scores ≥ 7 (altitude-only,
/// no Moon factor — keeps this provider free of per-day ephemeris calls).
final dsoBadgeMonthProvider =
    FutureProvider.autoDispose.family<Set<int>, DateTime>((ref, month) async {
  final location = await ref.watch(currentLocationProvider.future);

  final daysInMonth =
      DateTime(month.year, month.month + 1, 0).day;

  final goodDays = <int>{};
  for (var day = 1; day <= daysInMonth; day++) {
    final midnight = DateTime.utc(month.year, month.month, day);
    final anyGood = DsoCatalog.all.any((dso) {
      final r = DsoVisibility.compute(
        dso,
        midnight,
        location.latitude,
        location.longitude,
        0, // ignore Moon for calendar badge
        0,
        0,
      );
      return r.score >= 7;
    });
    if (anyGood) goodDays.add(day);
  }
  return goodDays;
});
