import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/dashboard/widgets/planet_card.dart';
import 'package:flutter/material.dart';

const _visiblePlanets = [
  CelestialBodyId.sun,
  CelestialBodyId.mercury,
  CelestialBodyId.venus,
  CelestialBodyId.mars,
  CelestialBodyId.jupiter,
  CelestialBodyId.saturn,
  CelestialBodyId.uranus,
  CelestialBodyId.neptune,
];

class PlanetsRow extends StatelessWidget {
  const PlanetsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.planetsSectionTitle,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _visiblePlanets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (_, i) => PlanetCard(id: _visiblePlanets[i]),
          ),
        ),
      ],
    );
  }
}
