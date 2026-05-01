import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/map/domain/bortle_classifier.dart';
import 'package:flutter/material.dart';

class BortleLegend extends StatelessWidget {
  const BortleLegend({super.key, this.highlighted});

  /// If set, this level row is visually highlighted as the current location.
  final BortleLevel? highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              l10n.bortleScaleTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...BortleLevel.values.map(
            (level) => _LevelRow(
              level: level,
              isHighlighted: level == highlighted,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level, required this.isHighlighted});

  final BortleLevel level;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isHighlighted
          ? Theme.of(context).colorScheme.primaryContainer.withAlpha(80)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: level.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${level.value}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isHighlighted ? FontWeight.bold : null,
                  ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                level.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: isHighlighted ? FontWeight.bold : null,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isHighlighted)
              const Icon(Icons.my_location, size: 14, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
