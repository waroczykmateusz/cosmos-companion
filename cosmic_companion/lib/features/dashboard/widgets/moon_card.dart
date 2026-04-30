import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoonCard extends ConsumerWidget {
  const MoonCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final phaseAsync = ref.watch(moonPhaseProvider);
    final moonAsync = ref.watch(moonBodyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: phaseAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            '${l10n.error}: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          data: (phase) => Column(
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
              Text(l10n.illuminationPercent(phase.illuminationPercent.round())),
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
              ],
            ],
          ),
        ),
      ),
    );
  }

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
