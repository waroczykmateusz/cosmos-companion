import 'package:cosmic_companion/core/theme/app_theme.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:cosmic_companion/features/calendar/domain/astro_event.dart';
import 'package:cosmic_companion/features/calendar/providers/calendar_providers.dart';
import 'package:cosmic_companion/features/dso/domain/dso_object.dart';
import 'package:cosmic_companion/features/dso/domain/dso_visibility.dart';
import 'package:cosmic_companion/features/dso/providers/dso_providers.dart';
import 'package:cosmic_companion/features/weather/providers/weather_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final month = ref.watch(calendarMonthProvider);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final badgeDaysAsync = ref.watch(dsoBadgeMonthProvider(month));

    final badgeDays = badgeDaysAsync.valueOrNull ?? const <int>{};

    // Moon phase emoji per day (only moonPhase events, not ingress)
    final moonPhaseDays = <int, String>{};
    for (final e in eventsAsync.valueOrNull ?? <AstroEvent>[]) {
      final local = e.utc.toLocal();
      if (local.year == month.year &&
          local.month == month.month &&
          e.type == AstroEventType.moonPhase &&
          e.moonPhase != null) {
        moonPhaseDays[local.day] = _moonEmoji(e.moonPhase!);
      }
    }

    // Moon phase events for selected day (no zodiac ingress)
    final selectedMoonEvents = (eventsAsync.valueOrNull ?? <AstroEvent>[])
        .where((e) {
          final local = e.utc.toLocal();
          return local.year == _selected.year &&
              local.month == _selected.month &&
              local.day == _selected.day &&
              e.type == AstroEventType.moonPhase;
        })
        .toList();

    final monthLabel =
        DateFormat('MMMM yyyy', 'pl').format(month).capitalize();

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain,
                    ),
                  ),
                  Row(
                    children: [
                      _NavBtn(
                        icon: Icons.chevron_left,
                        onTap: () => ref
                            .read(calendarMonthProvider.notifier)
                            .state = DateTime.utc(month.year, month.month - 1),
                      ),
                      const SizedBox(width: 4),
                      _NavBtn(
                        icon: Icons.chevron_right,
                        onTap: () => ref
                            .read(calendarMonthProvider.notifier)
                            .state = DateTime.utc(month.year, month.month + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Day-of-week labels ───────────────────────────────────────────
          const SliverToBoxAdapter(child: _DowRow()),

          // ── Mini calendar grid ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _CalendarGrid(
              month: month,
              selected: _selected,
              badgeDays: badgeDays,
              moonPhaseDays: moonPhaseDays,
              onSelect: (d) => setState(() => _selected = d),
            ),
          ),

          // ── Legend ──────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _Legend()),

          // ── 7-day forecast strip ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ForecastStrip(badgeDays: badgeDays, month: month),
          ),

          // ── Selected day ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SelectedDaySection(
              day: _selected,
              moonEvents: selectedMoonEvents,
              hasDsoBadge: badgeDays.contains(_selected.day) &&
                  _selected.month == month.month,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _moonEmoji(MoonPhaseName phase) => switch (phase) {
        MoonPhaseName.newMoon => '🌑',
        MoonPhaseName.waxingCrescent => '🌒',
        MoonPhaseName.firstQuarter => '🌓',
        MoonPhaseName.waxingGibbous => '🌔',
        MoonPhaseName.fullMoon => '🌕',
        MoonPhaseName.waningGibbous => '🌖',
        MoonPhaseName.lastQuarter => '🌗',
        MoonPhaseName.waningCrescent => '🌘',
      };
}

// ── Day-of-week header ────────────────────────────────────────────────────────

class _DowRow extends StatelessWidget {
  const _DowRow();

  static const _days = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'Sb', 'Nd'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: _days
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selected,
    required this.badgeDays,
    required this.moonPhaseDays,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Set<int> badgeDays;
  final Map<int, String> moonPhaseDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final daysInPrevMonth = DateTime(month.year, month.month, 0).day;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: totalCells,
        itemBuilder: (_, index) {
          final int day;
          final bool isCurrentMonth;

          if (index < startOffset) {
            day = daysInPrevMonth - startOffset + index + 1;
            isCurrentMonth = false;
          } else if (index >= startOffset + daysInMonth) {
            day = index - startOffset - daysInMonth + 1;
            isCurrentMonth = false;
          } else {
            day = index - startOffset + 1;
            isCurrentMonth = true;
          }

          final cellDate = isCurrentMonth
              ? DateTime(month.year, month.month, day)
              : index < startOffset
                  ? DateTime(month.year, month.month - 1, day)
                  : DateTime(month.year, month.month + 1, day);

          final isToday = isCurrentMonth &&
              day == now.day &&
              month.month == now.month &&
              month.year == now.year;

          final isSelected = isCurrentMonth &&
              cellDate.year == selected.year &&
              cellDate.month == selected.month &&
              cellDate.day == selected.day;

          final isGoodDso = isCurrentMonth && badgeDays.contains(day);
          final moonEmoji =
              isCurrentMonth ? moonPhaseDays[day] : null;

          return _DayCell(
            day: day,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            isSelected: isSelected,
            isGoodDso: isGoodDso,
            moonEmoji: moonEmoji,
            onTap: isCurrentMonth ? () => onSelect(cellDate) : null,
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.isGoodDso,
    required this.moonEmoji,
    required this.onTap,
  });

  final int day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isGoodDso;
  final String? moonEmoji;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color? bg;
    Color textColor;
    Border? border;

    if (isSelected) {
      bg = AppTheme.accentBlue;
      textColor = Colors.white;
    } else if (isToday) {
      bg = AppTheme.accentBlue.withValues(alpha: 0.18);
      textColor = AppTheme.accentBlue;
      border = Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3));
    } else if (isGoodDso) {
      bg = AppTheme.scoreGreen.withValues(alpha: 0.1);
      textColor = AppTheme.textMain;
      border = Border.all(color: AppTheme.scoreGreen.withValues(alpha: 0.2));
    } else if (!isCurrentMonth) {
      textColor = AppTheme.border;
    } else {
      textColor = AppTheme.textAccent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight:
                    (isToday || isSelected) ? FontWeight.w700 : null,
              ),
            ),
            if (moonEmoji != null)
              Text(
                moonEmoji!,
                style: TextStyle(
                  fontSize: isSelected ? 8 : 7,
                  height: 1.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Row(
        children: [
          _LegendItem(
            color: AppTheme.scoreGreen.withValues(alpha: 0.5),
            label: 'Dobra astronomia',
          ),
          const SizedBox(width: 12),
          const _LegendItem(
            color: AppTheme.accentBlue,
            label: 'Faza Księżyca',
            isEmoji: true,
          ),
          const SizedBox(width: 12),
          _LegendItem(
            color: AppTheme.accentBlue.withValues(alpha: 0.5),
            label: 'Dziś',
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.isEmoji = false,
  });

  final Color color;
  final String label;
  final bool isEmoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isEmoji)
          const Text('🌓', style: TextStyle(fontSize: 9))
        else
          Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

// ── 7-day forecast strip ──────────────────────────────────────────────────────

class _ForecastStrip extends ConsumerWidget {
  const _ForecastStrip({required this.badgeDays, required this.month});

  final Set<int> badgeDays;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekCloud = ref.watch(weekCloudCoverProvider);
    final now = DateTime.now();
    const dowLabels = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'Sb', 'Nd'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Text(
            'PROGNOZA 7 DNI',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (_, i) {
              final day = now.add(Duration(days: i));
              final isToday = i == 0;
              final goodDso = day.month == month.month &&
                  badgeDays.contains(day.day);

              final illum = DsoVisibility.approxMoonIllumination(day.toUtc());
              final illumNext = DsoVisibility.approxMoonIllumination(
                  day.add(const Duration(days: 1)).toUtc());
              final waxing = illumNext > illum;
              final cloud = i < weekCloud.length ? weekCloud[i] : 0;
              final score = goodDso
                  ? (10.0 - illum / 100.0 * 3.0 - cloud / 100.0 * 4.0)
                      .clamp(0.0, 10.0)
                  : (4.0 - illum / 100.0 * 2.0 - cloud / 100.0 * 3.0)
                      .clamp(0.0, 4.0);
              final scoreColor = score >= 7
                  ? AppTheme.scoreGreen
                  : score >= 5
                      ? AppTheme.scoreOrange
                      : AppTheme.scoreRed;

              return Container(
                width: 44,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppTheme.accentBlue.withValues(alpha: 0.12)
                      : AppTheme.bgCard,
                  border: Border.all(
                    color: isToday
                        ? AppTheme.accentBlue.withValues(alpha: 0.4)
                        : AppTheme.border,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dowLabels[(day.weekday - 1) % 7],
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _moonEmoji(illum, waxing),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  String _moonEmoji(double illum, bool waxing) {
    if (illum < 3) return '🌑';
    if (illum < 45) return waxing ? '🌒' : '🌘';
    if (illum < 55) return waxing ? '🌓' : '🌗';
    if (illum < 97) return waxing ? '🌔' : '🌖';
    return '🌕';
  }
}

// ── Selected day section ──────────────────────────────────────────────────────

class _SelectedDaySection extends ConsumerWidget {
  const _SelectedDaySection({
    required this.day,
    required this.moonEvents,
    required this.hasDsoBadge,
  });

  final DateTime day;
  final List<AstroEvent> moonEvents;
  final bool hasDsoBadge;

  static final _fmt = DateFormat('HH:mm');
  static final _dayFmt = DateFormat('EEE · d MMMM', 'pl');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsoAsync = ref.watch(dsoForDateProvider(day));
    final label = _dayFmt.format(day).capitalize();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day label + DSO badge
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
              if (hasDsoBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.scoreGreen.withValues(alpha: 0.15),
                    border: Border.all(
                        color: AppTheme.scoreGreen.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Dobra astronomia',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.scoreGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Moon phase events
          if (moonEvents.isNotEmpty) ...[
            ...moonEvents.map((e) => _MoonEventCard(event: e)),
            const SizedBox(height: 6),
          ],

          // DSO best events
          dsoAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.scoreGreen,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, _) => Text(
              'Błąd: $e',
              style: const TextStyle(color: AppTheme.scoreRed, fontSize: 11),
            ),
            data: (results) {
              if (results.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Żaden obiekt nie jest tego dnia dobrze widoczny.',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NAJLEPSZE OBIEKTY DSO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...results.take(5).map(
                        (r) => _DsoEventCard(result: r, fmt: _fmt),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Moon phase event card ─────────────────────────────────────────────────────

class _MoonEventCard extends StatelessWidget {
  const _MoonEventCard({required this.event});

  final AstroEvent event;

  @override
  Widget build(BuildContext context) {
    final phase = event.moonPhase!;
    final timeStr = DateFormat('HH:mm').format(event.utc.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(
            color: AppTheme.scoreOrange.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              _moonEmoji(phase),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _moonName(phase),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
                const Text(
                  'Faza Księżyca',
                  style: TextStyle(fontSize: 9, color: AppTheme.textAccent),
                ),
              ],
            ),
          ),
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentBlue,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _moonEmoji(MoonPhaseName p) => switch (p) {
        MoonPhaseName.newMoon => '🌑',
        MoonPhaseName.waxingCrescent => '🌒',
        MoonPhaseName.firstQuarter => '🌓',
        MoonPhaseName.waxingGibbous => '🌔',
        MoonPhaseName.fullMoon => '🌕',
        MoonPhaseName.waningGibbous => '🌖',
        MoonPhaseName.lastQuarter => '🌗',
        MoonPhaseName.waningCrescent => '🌘',
      };

  String _moonName(MoonPhaseName p) => switch (p) {
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

// ── DSO event card ────────────────────────────────────────────────────────────

class _DsoEventCard extends StatelessWidget {
  const _DsoEventCard({required this.result, required this.fmt});

  final DsoVisibilityResult result;
  final DateFormat fmt;

  @override
  Widget build(BuildContext context) {
    final score = result.score;
    final accentColor = score >= 7
        ? AppTheme.scoreGreen
        : score >= 5
            ? AppTheme.scoreOrange
            : AppTheme.scoreRed;

    final timeStr = result.bestTimeUtc != null
        ? fmt.format(result.bestTimeUtc!.toLocal())
        : '–';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              _emoji(result.dso.type),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.dso.catalogName} w kulminacji',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Alt max ${result.maxAltitudeDeg.toStringAsFixed(0)}° '
                  '· score ${score.toStringAsFixed(1)} '
                  '· Księżyc ${result.moonSeparationDeg.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accentColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
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

// ── Nav button ────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textAccent),
      ),
    );
  }
}

// ── String extension ──────────────────────────────────────────────────────────

extension _StringCapitalize on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
