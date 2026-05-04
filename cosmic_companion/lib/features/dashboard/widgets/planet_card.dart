import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dashboard/widgets/body_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanetCard extends ConsumerWidget {
  const PlanetCard({required this.id, super.key});

  final CelestialBodyId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyAsync = ref.watch(planetBodyProvider(id));

    return SizedBox(
      width: 130,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: bodyAsync.valueOrNull != null
              ? () => showBodyDetailSheet(context, bodyAsync.value!)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: bodyAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Center(
                child: Icon(
                  Icons.error_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              data: (body) => _PlanetCardContent(body: body),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanetCardContent extends StatelessWidget {
  const _PlanetCardContent({required this.body});

  final CelestialBody body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              _emoji(body.id),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                body.displayName,
                style: theme.textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (body.isRetrograde)
              Text(
                'Rx',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _signName(body.zodiacSign),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              body.isAboveHorizon
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 14,
              color: body.isAboveHorizon ? Colors.greenAccent : Colors.grey,
            ),
            Expanded(
              child: Text(
                body.isAboveHorizon
                    ? l10n.aboveHorizon(body.altitude.toStringAsFixed(1))
                    : l10n.belowHorizon,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: body.isAboveHorizon ? Colors.greenAccent : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _emoji(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => '☀️',
        CelestialBodyId.moon => '🌙',
        CelestialBodyId.mercury => '☿',
        CelestialBodyId.venus => '♀',
        CelestialBodyId.mars => '♂',
        CelestialBodyId.jupiter => '♃',
        CelestialBodyId.saturn => '♄',
        CelestialBodyId.uranus => '♅',
        CelestialBodyId.neptune => '♆',
        CelestialBodyId.pluto => '♇',
        _ => '★',
      };

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
