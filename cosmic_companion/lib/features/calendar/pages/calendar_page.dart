import 'package:cosmic_companion/core/theme/app_theme.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:cosmic_companion/features/calendar/domain/astro_event.dart';
import 'package:cosmic_companion/features/calendar/providers/calendar_providers.dart';
import 'package:cosmic_companion/features/dso/providers/dso_providers.dart';
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

    // Collect event days for the current month (moon phase / ingress dots)
    final eventDays = <int>{};
    if (eventsAsync.valueOrNull != null) {
      for (final e in eventsAsync.value!) {
        final local = e.utc.toLocal();
        if (local.year == month.year && local.month == month.month) {
          eventDays.add(local.day);
        }
      }
    }

    // Events for selected day
    final selectedEvents = eventsAsync.valueOrNull
            ?.where((e) {
              final local = e.utc.toLocal();
              return local.year == _selected.year &&
                  local.month == _selected.month &&
                  local.day == _selected.day;
            })
            .toList() ??
        [];

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
              eventDays: eventDays,
              onSelect: (d) => setState(() => _selected = d),
            ),
          ),

          // ── Legend ──────────────────────────────────────────────────────
          const SliverToBoxAdapter(child: _Legend()),

          // ── 7-day forecast strip ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ForecastStrip(badgeDays: badgeDays, month: month),
          ),

          // ── Selected day events ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SelectedDaySection(
              day: _selected,
              events: selectedEvents,
              hasDsoBadge: badgeDays.contains(_selected.day) &&
                  _selected.month == month.month,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
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
    required this.eventDays,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Set<int> badgeDays;
  final Set<int> eventDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    // weekday: Mon=1..Sun=7 → offset from Monday
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
          final hasEvent = isCurrentMonth && eventDays.contains(day);

          return _DayCell(
            day: day,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            isSelected: isSelected,
            isGoodDso: isGoodDso,
            hasEvent: hasEvent,
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
    required this.hasEvent,
    required this.onTap,
  });

  final int day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isGoodDso;
  final bool hasEvent;
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
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor,
                  fontWeight:
                      (isToday || isSelected) ? FontWeight.w700 : null,
                ),
              ),
            ),
            if (hasEvent)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white70
                          : AppTheme.scoreGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
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
            label: 'Dobre DSO',
          ),
          const SizedBox(width: 12),
          const _LegendItem(
            color: AppTheme.scoreGreen,
            label: 'Wydarzenie',
            circle: true,
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
    this.circle = false,
  });

  final Color color;
  final String label;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: circle
                ? BorderRadius.circular(3)
                : BorderRadius.circular(2),
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

class _ForecastStrip extends StatelessWidget {
  const _ForecastStrip({required this.badgeDays, required this.month});

  final Set<int> badgeDays;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
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

              // Rough score from DSO badge + weekday variation (placeholder)
              final score = goodDso ? 7.0 + (day.day % 3) * 0.5 : 3.0;
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
                      _moonEmoji(day),
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

  String _moonEmoji(DateTime day) {
    // Approximate moon phase by day-of-month cycle (29.5-day period)
    // Reference: new moon approx every ~29.5 days from a known epoch
    final epoch = DateTime(2024, 1, 11); // known new moon
    final diff = day.difference(epoch).inDays;
    final phase = (diff % 29.5).abs();
    if (phase < 1.5) return '🌑';
    if (phase < 6) return '🌒';
    if (phase < 8.5) return '🌓';
    if (phase < 13) return '🌔';
    if (phase < 16) return '🌕';
    if (phase < 21) return '🌖';
    if (phase < 23.5) return '🌗';
    return '🌘';
  }
}

// ── Selected day section ──────────────────────────────────────────────────────

class _SelectedDaySection extends StatelessWidget {
  const _SelectedDaySection({
    required this.day,
    required this.events,
    required this.hasDsoBadge,
  });

  final DateTime day;
  final List<AstroEvent> events;
  final bool hasDsoBadge;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEE · d MMMM', 'pl').format(day).capitalize();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WYBRANY DZIEŃ',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMain,
                ),
              ),
              if (hasDsoBadge) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.scoreGreen.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppTheme.scoreGreen.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Dobra noc dla DSO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.scoreGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            const Text(
              'Brak wydarzeń astronomicznych w tym dniu.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            )
          else
            ...events.map((e) => _EventCard(event: e)),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final AstroEvent event;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('HH:mm').format(event.utc.toLocal());
    final (icon, title, sub, borderColor) = _info();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.textAccent,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            timeLabel,
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

  (String icon, String title, String? sub, Color borderColor) _info() {
    switch (event.type) {
      case AstroEventType.moonPhase:
        final phase = event.moonPhase!;
        return (
          _moonEmoji(phase),
          _moonName(phase),
          'Faza Księżyca',
          AppTheme.scoreOrange.withValues(alpha: 0.2),
        );
      case AstroEventType.moonIngress:
        return (
          '☽',
          'Księżyc → ${_signName(event.ingressSign!)}',
          'Ingres Księżyca',
          AppTheme.textAccent.withValues(alpha: 0.2),
        );
      case AstroEventType.planetaryIngress:
        return (
          _bodyEmoji(event.body),
          '${_bodyName(event.body)} → ${_signName(event.ingressSign!)}',
          'Ingres planety',
          AppTheme.accentBlue.withValues(alpha: 0.2),
        );
    }
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

  String _signName(ZodiacSign s) => switch (s) {
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

  String _bodyName(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => 'Słońce',
        CelestialBodyId.mercury => 'Merkury',
        CelestialBodyId.venus => 'Wenus',
        CelestialBodyId.mars => 'Mars',
        CelestialBodyId.jupiter => 'Jowisz',
        CelestialBodyId.saturn => 'Saturn',
        _ => id.name,
      };

  String _bodyEmoji(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => '☀️',
        CelestialBodyId.mercury => '☿',
        CelestialBodyId.venus => '♀',
        CelestialBodyId.mars => '♂',
        CelestialBodyId.jupiter => '♃',
        CelestialBodyId.saturn => '♄',
        _ => '★',
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
