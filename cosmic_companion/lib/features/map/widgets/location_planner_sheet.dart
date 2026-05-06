import 'package:cosmic_companion/core/theme/app_theme.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dso/domain/dso_object.dart';
import 'package:cosmic_companion/features/dso/domain/dso_visibility.dart';
import 'package:cosmic_companion/features/map/providers/map_providers.dart';
import 'package:cosmic_companion/features/weather/domain/weather_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LocationPlannerSheet extends ConsumerWidget {
  const LocationPlannerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(selectedPlannerLocationProvider);
    final bortleAsync = ref.watch(plannerBortleProvider);
    final dsoAsync = ref.watch(plannerDsoProvider);
    final moonAsync = ref.watch(moonPhaseProvider);
    final weatherAsync = ref.watch(plannerWeatherProvider);

    if (loc == null) return const SizedBox.shrink();

    final latStr =
        '${loc.latitude.abs().toStringAsFixed(4)}°${loc.latitude >= 0 ? 'N' : 'S'}';
    final lonStr =
        '${loc.longitude.abs().toStringAsFixed(4)}°${loc.longitude >= 0 ? 'E' : 'W'}';

    return DraggableScrollableSheet(
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgMain,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: coordinates + Bortle
            Row(
              children: [
                const Icon(Icons.place, color: AppTheme.accentBlue, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$latStr  $lonStr',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
                const Spacer(),
                bortleAsync.when(
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.accentBlue),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (bortle) => bortle == null
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: bortle.color.withAlpha(40),
                            border: Border.all(color: bortle.color),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Bortle ${bortle.value}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: bortle.color,
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // Bortle description
            bortleAsync.maybeWhen(
              data: (bortle) => bortle != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4, left: 24),
                      child: Text(
                        bortle.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),
            const _SectionHeader(label: 'KSIĘŻYC'),
            const SizedBox(height: 8),

            // Moon card
            moonAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.accentBlue),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (moon) {
                final illum = moon.illuminationPercent;
                final waxing = moon.phaseAngle < 180;
                final emoji = _moonEmoji(illum, waxing);
                final illumColor = illum < 30
                    ? AppTheme.scoreGreen
                    : illum < 60
                        ? AppTheme.scoreOrange
                        : AppTheme.scoreRed;
                return _InfoCard(
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${illum.round()}% iluminacji',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: illumColor,
                            ),
                          ),
                          Text(
                            _phaseName(moon.name),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            const _SectionHeader(label: 'POGODA TEJ NOCY'),
            const SizedBox(height: 8),

            weatherAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accentBlue),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (WeatherForecast? weather) {
                if (weather == null) {
                  return const _InfoCard(
                    child: Text(
                      'Brak danych pogodowych dla tej lokalizacji.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  );
                }
                final cloud = weather.tonightCloudCoverPct;
                final precip = weather.tonightPrecipPct;
                final cloudColor = cloud < 30
                    ? AppTheme.scoreGreen
                    : cloud < 60
                        ? AppTheme.scoreOrange
                        : AppTheme.scoreRed;
                return _InfoCard(
                  child: Column(
                    children: [
                      _WeatherRow(
                        icon: Icons.cloud,
                        label: 'Zachmurzenie',
                        value: '$cloud%',
                        valueColor: cloudColor,
                        bar: cloud / 100.0,
                        barColor: cloudColor,
                      ),
                      const SizedBox(height: 8),
                      _WeatherRow(
                        icon: Icons.umbrella,
                        label: 'Prawdopodobieństwo opadów',
                        value: '$precip%',
                        valueColor: precip > 50
                            ? AppTheme.scoreRed
                            : AppTheme.textMuted,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            const _SectionHeader(label: 'OBIEKTY DSO TEJ NOCY'),
            const SizedBox(height: 8),

            // DSO list
            dsoAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.scoreGreen),
                      SizedBox(height: 8),
                      Text('Obliczam widoczność…',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
              error: (e, _) => Text('Błąd: $e',
                  style: const TextStyle(color: AppTheme.scoreRed)),
              data: (results) {
                if (results == null || results.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Brak widocznych obiektów DSO tej nocy.',
                      style:
                          TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  );
                }
                final top = results.take(8).toList();
                return Column(
                  children: top
                      .map((r) => _DsoRow(result: r))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _moonEmoji(double illum, bool waxing) {
    if (illum < 3) return '🌑';
    if (illum < 45) return waxing ? '🌒' : '🌘';
    if (illum < 55) return waxing ? '🌓' : '🌗';
    if (illum < 97) return waxing ? '🌔' : '🌖';
    return '🌕';
  }

  String _phaseName(MoonPhaseName name) => switch (name) {
        MoonPhaseName.newMoon => 'Nów',
        MoonPhaseName.waxingCrescent => 'Sierp rosnący',
        MoonPhaseName.firstQuarter => 'Pierwsza kwadra',
        MoonPhaseName.waxingGibbous => 'Gibbous rosnący',
        MoonPhaseName.fullMoon => 'Pełnia',
        MoonPhaseName.waningGibbous => 'Gibbous malejący',
        MoonPhaseName.lastQuarter => 'Ostatnia kwadra',
        MoonPhaseName.waningCrescent => 'Sierp malejący',
      };
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
          letterSpacing: 1.2,
        ),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: child,
      );
}

class _WeatherRow extends StatelessWidget {
  const _WeatherRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.bar,
    this.barColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final double? bar;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
        if (bar != null) ...[
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: bar,
              minHeight: 4,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  barColor ?? AppTheme.accentBlue),
            ),
          ),
        ],
      ],
    );
  }
}

class _DsoRow extends StatelessWidget {
  const _DsoRow({required this.result});
  final DsoVisibilityResult result;

  @override
  Widget build(BuildContext context) {
    final score = result.score;
    final scoreColor = score >= 7
        ? AppTheme.scoreGreen
        : score >= 5
            ? AppTheme.scoreOrange
            : AppTheme.scoreRed;

    final bestTime = result.bestTimeUtc != null
        ? DateFormat('HH:mm').format(result.bestTimeUtc!.toLocal())
        : '–';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Text(
            _emoji(result.dso.type),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.dso.catalogName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
                Text(
                  'Alt max ${result.maxAltitudeDeg.round()}°  ·  ${result.dso.namePl}',
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
              Text(
                bestTime,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _emoji(DsoType type) => switch (type) {
        DsoType.galaxy => '🌌',
        DsoType.openCluster => '✨',
        DsoType.globularCluster => '⭐',
        DsoType.emissionNebula => '🔴',
        DsoType.reflectionNebula => '🔵',
        DsoType.darkNebula => '⬛',
        DsoType.planetaryNebula => '🟢',
        DsoType.supernovaRemnant => '💥',
      };
}
