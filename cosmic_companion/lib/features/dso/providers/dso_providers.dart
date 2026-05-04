import 'package:cosmic_companion/core/astronomy/celestial_calculator.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
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

/// All DSO from the catalog with visibility computed (including below-horizon).
/// Used by the catalog page to show every object with score / altitude.
final allDsoWithVisibilityProvider =
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
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  return results;
});

/// DSO visibility for an arbitrary calendar date.
/// Takes a UTC midnight DateTime, computes moon state via Sweph for that date.
final dsoForDateProvider = FutureProvider.autoDispose
    .family<List<DsoVisibilityResult>, DateTime>((ref, date) async {
  final location = await ref.watch(currentLocationProvider.future);
  final calculator = CelestialCalculator();
  final midnight = DateTime.utc(date.year, date.month, date.day);

  final moonPhase = await calculator.computeMoonPhase(midnight);
  final moonBody = await calculator.computeBody(
    CelestialBodyId.moon,
    midnight,
    location,
  );

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

/// For each day in the given month: whether any DSO scores ≥ 7.
/// Uses formula-based Moon approximation (no FFI) for moon illumination
/// and position — fast enough to run for all 31 days synchronously.
final dsoBadgeMonthProvider =
    FutureProvider.autoDispose.family<Set<int>, DateTime>((ref, month) async {
  final location = await ref.watch(currentLocationProvider.future);

  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

  final goodDays = <int>{};
  for (var day = 1; day <= daysInMonth; day++) {
    final midnight = DateTime.utc(month.year, month.month, day);
    final illumination = DsoVisibility.approxMoonIllumination(midnight);
    final moonRa = DsoVisibility.approxMoonRaHours(midnight);
    final moonDec = DsoVisibility.approxMoonDecDeg(midnight);
    final anyGood = DsoCatalog.all.any((dso) {
      final r = DsoVisibility.compute(
        dso,
        midnight,
        location.latitude,
        location.longitude,
        illumination,
        moonRa,
        moonDec,
      );
      return r.score >= 7;
    });
    if (anyGood) goodDays.add(day);
  }
  return goodDays;
});
