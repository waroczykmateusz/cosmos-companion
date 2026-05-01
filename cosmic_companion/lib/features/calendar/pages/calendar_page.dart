import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:cosmic_companion/features/calendar/domain/astro_event.dart';
import 'package:cosmic_companion/features/calendar/providers/calendar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(calendarMonthProvider);
    final eventsAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _MonthHeader(month: month),
        ),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '${l10n.error}: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (events) => events.isEmpty
            ? Center(child: Text(l10n.calendarNoEvents))
            : _EventList(events: events, month: month),
      ),
    );
  }
}

// ── Month navigation header ───────────────────────────────────────────────────

class _MonthHeader extends ConsumerWidget {
  const _MonthHeader({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = DateFormat('LLLL yyyy', 'pl').format(month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref
                .read(calendarMonthProvider.notifier)
                .state = DateTime.utc(month.year, month.month - 1),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref
                .read(calendarMonthProvider.notifier)
                .state = DateTime.utc(month.year, month.month + 1),
          ),
        ],
      ),
    );
  }
}

// ── Event list grouped by day ─────────────────────────────────────────────────

class _EventList extends StatelessWidget {
  const _EventList({required this.events, required this.month});

  final List<AstroEvent> events;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    // Group events by local date
    final grouped = <DateTime, List<AstroEvent>>{};
    for (final e in events) {
      final local = e.utc.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      grouped.putIfAbsent(day, () => []).add(e);
    }
    final days = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        return _DaySection(day: day, events: grouped[day]!);
      },
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day, required this.events});

  final DateTime day;
  final List<AstroEvent> events;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final label = DateFormat('d MMMM • EEEE', 'pl').format(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'DZIŚ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
        ...events.map((e) => _EventTile(event: e)),
        const Divider(height: 1),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final AstroEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timeLabel = DateFormat('HH:mm').format(event.utc.toLocal());
    final (icon, title, subtitle) = _eventInfo(l10n);

    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Text(
        timeLabel,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      dense: true,
    );
  }

  (String icon, String title, String? subtitle) _eventInfo(
    AppLocalizations l10n,
  ) {
    switch (event.type) {
      case AstroEventType.moonPhase:
        final phase = event.moonPhase!;
        return (
          _moonPhaseEmoji(phase),
          _moonPhaseName(l10n, phase),
          l10n.calendarMoonPhaseEvent,
        );

      case AstroEventType.moonIngress:
        final sign = event.ingressSign!;
        return (
          '☽',
          _signName(sign),
          l10n.calendarLabelMoonIngress,
        );

      case AstroEventType.planetaryIngress:
        final sign = event.ingressSign!;
        final body = _bodyName(event.body);
        return (
          _bodyEmoji(event.body),
          l10n.planetaryIngressEvent(body, _signName(sign)),
          l10n.calendarLabelPlanetIngress,
        );
    }
  }

  String _moonPhaseEmoji(MoonPhaseName phase) => switch (phase) {
        MoonPhaseName.newMoon => '🌑',
        MoonPhaseName.waxingCrescent => '🌒',
        MoonPhaseName.firstQuarter => '🌓',
        MoonPhaseName.waxingGibbous => '🌔',
        MoonPhaseName.fullMoon => '🌕',
        MoonPhaseName.waningGibbous => '🌖',
        MoonPhaseName.lastQuarter => '🌗',
        MoonPhaseName.waningCrescent => '🌘',
      };

  String _moonPhaseName(AppLocalizations l10n, MoonPhaseName phase) =>
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

  String _bodyName(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => 'Słońce',
        CelestialBodyId.moon => 'Księżyc',
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
