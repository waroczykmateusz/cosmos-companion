import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dashboard/widgets/body_detail_sheet.dart';
import 'package:cosmic_companion/features/dashboard/widgets/moon_phase_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MoonCard extends ConsumerWidget {
  const MoonCard({super.key});

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final phaseAsync = ref.watch(moonPhaseProvider);
    final moonAsync = ref.watch(moonBodyProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: moonAsync.valueOrNull != null
            ? () => showBodyDetailSheet(context, moonAsync.value!)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: phaseAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(
              '${l10n.error}: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            data: (phase) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.moonPhaseLabel,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _phaseName(l10n, phase.name),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.illuminationPercent(
                          phase.illuminationPercent.round(),
                        ),
                      ),
                      if (moonAsync.valueOrNull case final moon?) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              moon.isAboveHorizon
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                            ),
                            Text(
                              moon.isAboveHorizon
                                  ? 'Alt ${moon.altitude.toStringAsFixed(1)}°'
                                  : 'Pod horyzontem',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              moon.isRetrograde ? 'Rx' : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.orange),
                            ),
                          ],
                        ),
                        if (_hasRiseSetData(moon)) ...[
                          const SizedBox(height: 12),
                          _RiseSetMiniRow(
                            moon: moon,
                            timeFmt: _timeFmt,
                            l10n: l10n,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                // Right: graphical moon phase
                const SizedBox(width: 12),
                MoonPhaseWidget(
                  phaseAngle: phase.phaseAngle,
                  illuminationPercent: phase.illuminationPercent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasRiseSetData(CelestialBody moon) =>
      moon.riseTime != null ||
      moon.transitTime != null ||
      moon.setTime != null;

  String _phaseName(AppLocalizations l10n, MoonPhaseName phase) =>
      switch (phase) {
        MoonPhaseName.newMoon => l10n.moonPhaseNew,
        MoonPhaseName.waxingCrescent => l10n.moonPhaseWaxingCrescent,
        MoonPhaseName.firstQuarter => l10n.moonPhaseFirstQuarter,
        MoonPhaseName.waxingGibbous => l10n.moonPhaseWaxingGibbous,
        MoonPhaseName.fullMoon => l10n.moonPhaseFull,
        MoonPhaseName.waningGibbous => l10n.moonPhaseWaningGibbous,
        MoonPhaseName.lastQuarter => l10n.moonPhaseLastQuarter,
        MoonPhaseName.waningCrescent => l10n.moonPhaseWaningCrescent,
      };
}

class _RiseSetMiniRow extends StatelessWidget {
  const _RiseSetMiniRow({
    required this.moon,
    required this.timeFmt,
    required this.l10n,
  });

  final CelestialBody moon;
  final DateFormat timeFmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TimeChip(
          icon: Icons.wb_twilight_outlined,
          label: l10n.riseLabel,
          time: moon.riseTime,
          timeFmt: timeFmt,
          theme: theme,
          cs: cs,
        ),
        _TimeChip(
          icon: Icons.wb_sunny_outlined,
          label: l10n.transitLabel,
          time: moon.transitTime,
          timeFmt: timeFmt,
          theme: theme,
          cs: cs,
        ),
        _TimeChip(
          icon: Icons.nights_stay_outlined,
          label: l10n.setLabel,
          time: moon.setTime,
          timeFmt: timeFmt,
          theme: theme,
          cs: cs,
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.timeFmt,
    required this.theme,
    required this.cs,
  });

  final IconData icon;
  final String label;
  final DateTime? time;
  final DateFormat timeFmt;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final local = time?.toLocal();
    return Column(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(height: 2),
        Text(
          local != null ? timeFmt.format(local) : '—',
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
