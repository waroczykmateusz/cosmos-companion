import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeeingIndicator extends ConsumerWidget {
  const SeeingIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final seeing = ref.watch(mockSeeingProvider);
    final name = _name(l10n, seeing);
    final color = _color(seeing);

    return Card(
      child: ListTile(
        leading: Icon(Icons.visibility_outlined, color: color),
        title: Text(l10n.seeingLabel),
        trailing: Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _name(AppLocalizations l10n, SeeingRating r) => switch (r) {
        SeeingRating.excellent => l10n.seeingExcellent,
        SeeingRating.good => l10n.seeingGood,
        SeeingRating.fair => l10n.seeingFair,
        SeeingRating.poor => l10n.seeingPoor,
        SeeingRating.bad => l10n.seeingBad,
      };

  Color _color(SeeingRating r) => switch (r) {
        SeeingRating.excellent => Colors.green,
        SeeingRating.good => Colors.lightGreen,
        SeeingRating.fair => Colors.amber,
        SeeingRating.poor => Colors.orange,
        SeeingRating.bad => Colors.red,
      };
}
