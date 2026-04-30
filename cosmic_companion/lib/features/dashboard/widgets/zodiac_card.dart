import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZodiacCard extends ConsumerWidget {
  const ZodiacCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final moonAsync = ref.watch(moonBodyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: moonAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            '${l10n.error}: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          data: (moon) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.zodiacSignLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _signName(moon.zodiacSign),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${moon.signDegree.toStringAsFixed(2)}°',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _signName(ZodiacSign sign) => switch (sign) {
        ZodiacSign.aries => 'Baran ♈',
        ZodiacSign.taurus => 'Byk ♉',
        ZodiacSign.gemini => 'Bliźnięta ♊',
        ZodiacSign.cancer => 'Rak ♋',
        ZodiacSign.leo => 'Lew ♌',
        ZodiacSign.virgo => 'Panna ♍',
        ZodiacSign.libra => 'Waga ♎',
        ZodiacSign.scorpio => 'Skorpion ♏',
        ZodiacSign.sagittarius => 'Strzelec ♐',
        ZodiacSign.capricorn => 'Koziorożec ♑',
        ZodiacSign.aquarius => 'Wodnik ♒',
        ZodiacSign.pisces => 'Ryby ♓',
      };
}
