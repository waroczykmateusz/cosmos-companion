import 'package:cosmic_companion/core/theme/app_theme.dart';
import 'package:cosmic_companion/features/dso/domain/dso_object.dart';
import 'package:cosmic_companion/features/dso/domain/dso_visibility.dart';
import 'package:cosmic_companion/features/dso/providers/dso_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ── Filter / sort state ───────────────────────────────────────────────────────

enum _CatalogSort { scoreToday, magnitude, size, altitude }

// ── Page ──────────────────────────────────────────────────────────────────────

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  DsoType? _typeFilter; // null = all
  _CatalogSort _sort = _CatalogSort.scoreToday;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final allAsync = ref.watch(allDsoWithVisibilityProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14, topPad + 14, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Katalog DSO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
                ),
                allAsync.when(
                  data: (r) => Text(
                    '${r.length} obiektów',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // ── Type filter chips ────────────────────────────────────────────
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _FilterChip(
                  label: 'Wszystkie',
                  active: _typeFilter == null,
                  onTap: () => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '🌌 Galaktyki',
                  active: _typeFilter == DsoType.galaxy,
                  onTap: () => setState(
                      () => _typeFilter = DsoType.galaxy),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '✨ Gromady',
                  active: _typeFilter == DsoType.openCluster ||
                      _typeFilter == DsoType.globularCluster,
                  onTap: () => setState(
                      () => _typeFilter = DsoType.openCluster),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '🔴 Mgławice',
                  active: _typeFilter == DsoType.emissionNebula ||
                      _typeFilter == DsoType.reflectionNebula ||
                      _typeFilter == DsoType.darkNebula,
                  onTap: () => setState(
                      () => _typeFilter = DsoType.emissionNebula),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '🟢 Planetarne',
                  active: _typeFilter == DsoType.planetaryNebula,
                  onTap: () => setState(
                      () => _typeFilter = DsoType.planetaryNebula),
                ),
              ],
            ),
          ),
          // ── Sort row ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                const Text(
                  'Sortuj:',
                  style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Score dziś',
                  active: _sort == _CatalogSort.scoreToday,
                  onTap: () =>
                      setState(() => _sort = _CatalogSort.scoreToday),
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Jasność',
                  active: _sort == _CatalogSort.magnitude,
                  onTap: () =>
                      setState(() => _sort = _CatalogSort.magnitude),
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Rozmiar',
                  active: _sort == _CatalogSort.size,
                  onTap: () => setState(() => _sort = _CatalogSort.size),
                ),
                const SizedBox(width: 6),
                _SortChip(
                  label: 'Altitude',
                  active: _sort == _CatalogSort.altitude,
                  onTap: () =>
                      setState(() => _sort = _CatalogSort.altitude),
                ),
              ],
            ),
          ),
          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: allAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.scoreGreen),
              ),
              error: (e, _) => Center(
                child: Text('Błąd: $e',
                    style: const TextStyle(color: AppTheme.scoreRed)),
              ),
              data: (results) {
                final filtered = _applyFilter(results);
                final sorted = _applySort(filtered);
                if (sorted.isEmpty) {
                  return const Center(
                    child: Text(
                      'Brak obiektów dla wybranego filtru',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) => _CatalogRow(result: sorted[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DsoVisibilityResult> _applyFilter(List<DsoVisibilityResult> all) {
    if (_typeFilter == null) return all;
    // Cluster shortcut: openCluster filter shows both open + globular
    if (_typeFilter == DsoType.openCluster) {
      return all
          .where((r) =>
              r.dso.type == DsoType.openCluster ||
              r.dso.type == DsoType.globularCluster)
          .toList();
    }
    // Nebula shortcut: emissionNebula filter shows emission + reflection + dark + SNR
    if (_typeFilter == DsoType.emissionNebula) {
      return all
          .where((r) =>
              r.dso.type == DsoType.emissionNebula ||
              r.dso.type == DsoType.reflectionNebula ||
              r.dso.type == DsoType.darkNebula ||
              r.dso.type == DsoType.supernovaRemnant)
          .toList();
    }
    return all.where((r) => r.dso.type == _typeFilter).toList();
  }

  List<DsoVisibilityResult> _applySort(List<DsoVisibilityResult> list) {
    final copy = List<DsoVisibilityResult>.from(list);
    switch (_sort) {
      case _CatalogSort.scoreToday:
        copy.sort((a, b) => b.score.compareTo(a.score));
      case _CatalogSort.magnitude:
        copy.sort((a, b) => a.dso.magnitude.compareTo(b.dso.magnitude));
      case _CatalogSort.size:
        copy.sort(
            (a, b) => b.dso.angularSizeArcmin.compareTo(a.dso.angularSizeArcmin));
      case _CatalogSort.altitude:
        copy.sort(
            (a, b) => b.maxAltitudeDeg.compareTo(a.maxAltitudeDeg));
    }
    return copy;
  }
}

// ── Catalog row ───────────────────────────────────────────────────────────────

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({required this.result});

  final DsoVisibilityResult result;

  @override
  Widget build(BuildContext context) {
    final score = result.score;
    final visible = result.isVisible;
    final accentColor = !visible
        ? AppTheme.border
        : score >= 7
            ? AppTheme.scoreGreen
            : score >= 5
                ? AppTheme.scoreOrange
                : AppTheme.scoreRed;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _emoji(result.dso.type),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Body
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.dso.catalogName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          result.dso.namePl,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.textAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 4,
                          children: [
                            _MiniTag(_typeName(result.dso.type),
                                const Color(0xFF9F97E0),
                                const Color(0x26534AB7)),
                            _MiniTag(
                              'mag ${result.dso.magnitude.toStringAsFixed(1)}',
                              AppTheme.textAccent,
                              AppTheme.border,
                            ),
                            _MiniTag(
                              "${result.dso.angularSizeArcmin.toStringAsFixed(0)}'",
                              AppTheme.textAccent,
                              AppTheme.border,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Score + alt
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.15),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            visible ? score.toStringAsFixed(1) : '—',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        visible
                            ? 'Alt ${result.maxAltitudeDeg.toStringAsFixed(0)}°'
                            : 'Pod hor.',
                        style: const TextStyle(
                          fontSize: 8,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgCard,
      builder: (_) => _CatalogDetailSheet(result: result),
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

  String _typeName(DsoType type) => switch (type) {
        DsoType.galaxy => 'Galaktyka',
        DsoType.openCluster => 'Gromada otwarta',
        DsoType.globularCluster => 'Gromada kulista',
        DsoType.emissionNebula => 'Mgławica emisyjna',
        DsoType.reflectionNebula => 'Mgławica odbiciowa',
        DsoType.darkNebula => 'Mgławica ciemna',
        DsoType.planetaryNebula => 'Mgławica planetarna',
        DsoType.supernovaRemnant => 'Pozostałość supernowej',
      };
}

class _MiniTag extends StatelessWidget {
  const _MiniTag(this.label, this.color, this.bg);

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8, color: color),
      ),
    );
  }
}

// ── Filter / sort chip widgets ────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.accentBlue.withValues(alpha: 0.18)
              : Colors.transparent,
          border: Border.all(
            color: active
                ? AppTheme.accentBlue.withValues(alpha: 0.4)
                : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: active ? AppTheme.accentBlue : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.accentBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: active
                ? AppTheme.accentBlue.withValues(alpha: 0.35)
                : AppTheme.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: active ? AppTheme.accentBlue : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Detail sheet (catalog) ────────────────────────────────────────────────────

class _CatalogDetailSheet extends StatelessWidget {
  const _CatalogDetailSheet({required this.result});

  final DsoVisibilityResult result;

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final dso = result.dso;
    final timeStr = result.bestTimeUtc != null
        ? _timeFmt.format(result.bestTimeUtc!.toLocal())
        : '–';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dso.catalogName}  ${dso.namePl}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain,
              ),
            ),
            Text(dso.nameEn,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textAccent)),
            const Divider(height: 20, color: AppTheme.border),
            _row('RA / Dec',
                '${dso.raHours.toStringAsFixed(2)} h / ${dso.decDeg.toStringAsFixed(1)}°'),
            _row('Jasność', '${dso.magnitude.toStringAsFixed(1)} mag'),
            _row('Rozmiar', "${dso.angularSizeArcmin.toStringAsFixed(0)}'"),
            if (result.isVisible) ...[
              const Divider(height: 20, color: AppTheme.border),
              _row('Max altitude', '${result.maxAltitudeDeg.toStringAsFixed(1)}°'),
              _row('Najlepszy czas', timeStr),
              _row('Odl. Księżyc', '${result.moonSeparationDeg.toStringAsFixed(0)}°'),
              _row('Score', result.score.toStringAsFixed(1)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMain)),
          ],
        ),
      );
}
