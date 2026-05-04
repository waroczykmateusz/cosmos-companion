import 'package:cosmic_companion/features/dso/domain/dso_object.dart';
import 'package:cosmic_companion/features/dso/domain/dso_visibility.dart';
import 'package:cosmic_companion/features/dso/providers/dso_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

String _dsoTypeEmoji(DsoType type) => switch (type) {
      DsoType.galaxy => '🌌',
      DsoType.openCluster => '✨',
      DsoType.globularCluster => '⭐',
      DsoType.emissionNebula => '🔴',
      DsoType.reflectionNebula => '🔵',
      DsoType.darkNebula => '⬛',
      DsoType.planetaryNebula => '🟢',
      DsoType.supernovaRemnant => '💥',
    };

String _dsoTypeName(DsoType type) => switch (type) {
      DsoType.galaxy => 'Galaktyka',
      DsoType.openCluster => 'Gromada otwarta',
      DsoType.globularCluster => 'Gromada kulista',
      DsoType.emissionNebula => 'Mgławica emisyjna',
      DsoType.reflectionNebula => 'Mgławica odbiciowa',
      DsoType.darkNebula => 'Mgławica ciemna',
      DsoType.planetaryNebula => 'Mgławica planetarna',
      DsoType.supernovaRemnant => 'Pozostałość supernowej',
    };

class DsoCard extends ConsumerWidget {
  const DsoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsoAsync = ref.watch(visibleDsoTodayProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.scatter_plot_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Obiekty tej nocy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            dsoAsync.when(
              loading: () =>
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error: (e, _) => Text(
                'Błąd: $e',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              data: (results) {
                if (results.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Żaden obiekt nie jest dziś dobrze widoczny'),
                  );
                }
                final top = results.take(5).toList();
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
}

class _DsoRow extends StatelessWidget {
  const _DsoRow({required this.result});

  final DsoVisibilityResult result;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                _dsoTypeEmoji(result.dso.type),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.dso.catalogName}  ${result.dso.namePl}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Alt ${result.maxAltitudeDeg.toStringAsFixed(0)}°'
                    '  ${_dsoTypeName(result.dso.type)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            _ScoreChip(score: result.score),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _DsoDetailSheet(result: result),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 7
        ? Colors.green
        : score >= 4
            ? Colors.orange
            : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        score.toStringAsFixed(1),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DsoDetailSheet extends StatelessWidget {
  const _DsoDetailSheet({required this.result});

  final DsoVisibilityResult result;

  @override
  Widget build(BuildContext context) {
    final dso = result.dso;
    final timeStr = result.bestTimeUtc != null
        ? DateFormat('HH:mm').format(result.bestTimeUtc!.toLocal())
        : '–';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _dsoTypeEmoji(dso.type),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dso.catalogName}  ${dso.namePl}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        dso.nameEn,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _ScoreChip(score: result.score),
              ],
            ),
            const Divider(height: 24),
            _row(context, 'Typ', _dsoTypeName(dso.type)),
            _row(
              context,
              'RA / Dec',
              '${dso.raHours.toStringAsFixed(2)} h'
              ' / ${dso.decDeg.toStringAsFixed(1)}°',
            ),
            _row(context, 'Jasność', '${dso.magnitude.toStringAsFixed(1)} mag'),
            _row(
              context,
              'Rozmiar',
              "${dso.angularSizeArcmin.toStringAsFixed(0)}'",
            ),
            const Divider(height: 24),
            _row(
              context,
              'Max wysokość',
              '${result.maxAltitudeDeg.toStringAsFixed(1)}°',
            ),
            _row(context, 'Najlepszy czas', timeStr),
            _row(
              context,
              'Odl. od Księżyca',
              '${result.moonSeparationDeg.toStringAsFixed(0)}°',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );

}
