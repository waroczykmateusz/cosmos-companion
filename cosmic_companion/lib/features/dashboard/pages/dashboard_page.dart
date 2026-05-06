import 'dart:async';

import 'package:cosmic_companion/core/theme/app_theme.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/auth/pages/profile_page.dart';
import 'package:cosmic_companion/features/calendar/pages/calendar_page.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dashboard/widgets/body_detail_sheet.dart';
import 'package:cosmic_companion/features/dashboard/widgets/moon_phase_widget.dart';
import 'package:cosmic_companion/features/dso/domain/dso_object.dart';
import 'package:cosmic_companion/features/dso/domain/dso_visibility.dart';
import 'package:cosmic_companion/features/dso/pages/catalog_page.dart';
import 'package:cosmic_companion/features/dso/providers/dso_providers.dart';
import 'package:cosmic_companion/features/map/pages/light_pollution_map_page.dart';
import 'package:cosmic_companion/features/map/providers/map_providers.dart';
import 'package:cosmic_companion/features/weather/providers/weather_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ── Shell ─────────────────────────────────────────────────────────────────────

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _tab = 0;

  static final _tabs = [
    const _DashboardContent(),
    const CalendarPage(),
    const LightPollutionMapPage(),
    const CatalogPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
        color: AppTheme.bgMain,
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.bgMain,
        selectedItemColor: AppTheme.accentBlue,
        unselectedItemColor: AppTheme.textMuted,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_checked_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Kalendarz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scatter_plot_outlined),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ── Dashboard tab content ─────────────────────────────────────────────────────

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppTheme.scoreGreen,
      onRefresh: () async {
        ref
          ..invalidate(currentLocationProvider)
          ..invalidate(moonPhaseProvider)
          ..invalidate(moonBodyProvider)
          ..invalidate(visibleDsoTodayProvider)
          ..invalidate(astroTwilightProvider)
          ..invalidate(weatherForecastProvider);
        for (final id in _planetIds) {
          ref.invalidate(planetBodyProvider(id));
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroHeader()),
          const SliverToBoxAdapter(child: _SkyConditionsCard()),
          const SliverToBoxAdapter(child: _HourlyCloudCard()),
          const SliverToBoxAdapter(child: _DarkWindowCard()),
          const SliverToBoxAdapter(child: _RiseSetCard()),
          const SliverToBoxAdapter(child: _PlanetsSection()),
          const SliverToBoxAdapter(child: _DsoSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

const _planetIds = [
  CelestialBodyId.jupiter,
  CelestialBodyId.saturn,
  CelestialBodyId.venus,
  CelestialBodyId.mars,
  CelestialBodyId.mercury,
  CelestialBodyId.uranus,
  CelestialBodyId.neptune,
];

// ── Hero header ───────────────────────────────────────────────────────────────

class _HeroHeader extends ConsumerStatefulWidget {
  @override
  ConsumerState<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends ConsumerState<_HeroHeader> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final locationAsync = ref.watch(currentLocationProvider);
    final phaseAsync = ref.watch(moonPhaseProvider);
    final seeing = ref.watch(weatherSeeingProvider);

    final timeStr = DateFormat('HH:mm').format(_now);
    final dateStr = DateFormat('EEE, d MMMM yyyy', 'pl').format(_now);

    final locLabel = locationAsync.when(
      data: (l) =>
          '${l.latitude.toStringAsFixed(1)}°${l.latitude >= 0 ? 'N' : 'S'}'
          '  ${l.longitude.toStringAsFixed(1)}°${l.longitude >= 0 ? 'E' : 'W'}',
      loading: () => 'GPS…',
      error: (_, __) => 'Lokalizacja niedostępna',
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 16),
      child: Row(
        children: [
          // Left: text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍 $locLabel',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.textMain,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textAccent,
                  ),
                ),
                const SizedBox(height: 10),
                _NightBadge(seeing: seeing),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: moon
          phaseAsync.when(
            data: (phase) => MoonPhaseWidget(
              phaseAngle: phase.phaseAngle,
              illuminationPercent: phase.illuminationPercent,
              size: 80,
            ),
            loading: () => const SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentBlue,
                  strokeWidth: 1.5,
                ),
              ),
            ),
            error: (_, __) => const SizedBox(width: 80, height: 80),
          ),
        ],
      ),
    );
  }
}

class _NightBadge extends StatelessWidget {
  const _NightBadge({required this.seeing});

  final SeeingRating seeing;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (seeing) {
      SeeingRating.excellent => ('Doskonała noc · fotograf', AppTheme.scoreGreen),
      SeeingRating.good => ('Dobra noc dla fotografa', AppTheme.scoreGreen),
      SeeingRating.fair => ('Przeciętna noc', AppTheme.scoreOrange),
      SeeingRating.poor => ('Słaba noc', AppTheme.scoreRed),
      SeeingRating.bad => ('Bardzo słaba noc', AppTheme.scoreRed),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sky conditions card ───────────────────────────────────────────────────────

class _SkyConditionsCard extends ConsumerWidget {
  const _SkyConditionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seeing = ref.watch(weatherSeeingProvider);
    final cloud = ref.watch(cloudCoverProvider);
    final phaseAsync = ref.watch(moonPhaseProvider);
    final twilightAsync = ref.watch(astroTwilightProvider);
    final bortleAsync = ref.watch(bortleLevelProvider);

    final pips = _pipsFor(seeing);
    final seeingLabel = _seeingLabel(seeing);
    final bortleLevel = bortleAsync.valueOrNull;

    final illumination = phaseAsync.valueOrNull?.illuminationPercent ?? 0.0;
    final illumColor = illumination < 30
        ? AppTheme.scoreGreen
        : illumination < 60
            ? AppTheme.scoreOrange
            : AppTheme.scoreRed;

    final twilightStr = twilightAsync.valueOrNull != null
        ? DateFormat('HH:mm').format(twilightAsync.value!.toLocal())
        : '–';

    return _SpaceCard(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'WARUNKI NIEBA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textAccent,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: i < pips
                          ? AppTheme.scoreGreen
                          : AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$seeingLabel · $pips/5',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.scoreGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricCell(
                  label: 'ILUMINACJA KSIĘŻYCA',
                  value: '${illumination.round()}%',
                  valueColor: illumColor,
                  sub: illumination < 30
                      ? 'Świetnie dla mgławic'
                      : illumination < 60
                          ? 'Przeszkadza przy mgławicach'
                          : 'Utrudnia obserwacje DSO',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCell(
                  label: 'BORTLE',
                  value: bortleLevel != null ? '${bortleLevel.value}' : '–',
                  valueColor: bortleLevel == null
                      ? AppTheme.textMuted
                      : bortleLevel.value <= 4
                          ? AppTheme.scoreGreen
                          : bortleLevel.value <= 6
                              ? AppTheme.scoreOrange
                              : AppTheme.scoreRed,
                  sub: bortleLevel?.description ?? '…',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricCell(
                  label: 'ZACHMURZENIE',
                  value: cloud != null ? '$cloud%' : '–',
                  valueColor: cloud == null
                      ? AppTheme.textMuted
                      : cloud < 30
                          ? AppTheme.scoreGreen
                          : cloud < 70
                              ? AppTheme.scoreOrange
                              : AppTheme.scoreRed,
                  sub: cloud == null
                      ? 'Ładowanie...'
                      : cloud < 10
                          ? 'Bezchmurnie'
                          : cloud < 30
                              ? 'Małe zachmurzenie'
                              : cloud < 60
                                  ? 'Umiarkowane'
                                  : cloud < 85
                                      ? 'Duże zachmurzenie'
                                      : 'Niebo pokryte',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCell(
                  label: 'ZMIERZCH ASTRON.',
                  value: twilightStr,
                  valueColor: AppTheme.textMain,
                  valueFontSize: 18,
                  sub: 'Pełna ciemność od tej godz.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _pipsFor(SeeingRating r) => switch (r) {
        SeeingRating.excellent => 5,
        SeeingRating.good => 4,
        SeeingRating.fair => 3,
        SeeingRating.poor => 2,
        SeeingRating.bad => 1,
      };

  String _seeingLabel(SeeingRating r) => switch (r) {
        SeeingRating.excellent => 'Doskonałe',
        SeeingRating.good => 'Dobre',
        SeeingRating.fair => 'Przeciętne',
        SeeingRating.poor => 'Słabe',
        SeeingRating.bad => 'Złe',
      };
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.sub,
    this.valueFontSize = 22,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String sub;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x0D050E23),
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w600,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: const TextStyle(fontSize: 9, color: AppTheme.textAccent),
          ),
        ],
      ),
    );
  }
}

// ── Hourly cloud cover card ───────────────────────────────────────────────────

class _HourlyCloudCard extends ConsumerWidget {
  const _HourlyCloudCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(weatherForecastProvider);

    return forecastAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (forecast) {
        if (forecast == null) return const SizedBox.shrink();
        final entries = forecast.tonightHourly;
        if (entries.isEmpty) return const SizedBox.shrink();

        return _SpaceCard(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ZACHMURZENIE · NOC GODZINOWO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textAccent,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final e = entries[i];
                    final cloud = e.cloudCoverPct;
                    final color = cloud < 30
                        ? AppTheme.scoreGreen
                        : cloud < 60
                            ? AppTheme.scoreOrange
                            : AppTheme.scoreRed;
                    final timeLabel =
                        DateFormat('HH:mm').format(e.time);
                    final isNow = DateTime.now()
                            .difference(e.time)
                            .abs()
                            .inMinutes <
                        30;
                    return Container(
                      width: 46,
                      decoration: BoxDecoration(
                        color: isNow
                            ? AppTheme.accentBlue.withValues(alpha: 0.10)
                            : const Color(0x0D050E23),
                        border: Border.all(
                          color: isNow
                              ? AppTheme.accentBlue.withValues(alpha: 0.35)
                              : AppTheme.border,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeLabel,
                            style: TextStyle(
                              fontSize: 8,
                              color: isNow
                                  ? AppTheme.accentBlue
                                  : AppTheme.textMuted,
                              fontWeight: isNow
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$cloud%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 28,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: cloud / 100.0,
                                minHeight: 3,
                                backgroundColor: AppTheme.border,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Dark sky window card ──────────────────────────────────────────────────────

class _DarkWindowCard extends ConsumerWidget {
  const _DarkWindowCard();

  static final _fmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final twilightAsync = ref.watch(astroTwilightProvider);
    final dawnAsync = ref.watch(astroDawnProvider);
    final moonAsync = ref.watch(moonBodyProvider);

    final twilight = twilightAsync.valueOrNull;
    final dawn = dawnAsync.valueOrNull;
    final moonSet = moonAsync.valueOrNull?.setTime;

    if (twilight == null) return const SizedBox.shrink();

    final start = twilight.toLocal();

    String window;
    String sub;
    // Moon sets during the dark window → free window is twilight → moonSet
    if (moonSet != null && moonSet.isAfter(twilight) &&
        (dawn == null || moonSet.isBefore(dawn))) {
      final moonSetLocal = moonSet.toLocal();
      final dawnLocal = dawn?.toLocal();
      final endFmt = dawnLocal != null ? _fmt.format(dawnLocal) : '–';
      window = '${_fmt.format(moonSetLocal)} – $endFmt';
      final dur = (dawn ?? moonSet).difference(moonSet);
      final h = dur.inHours;
      final m = dur.inMinutes % 60;
      sub = 'Księżyc zachodzi o ${_fmt.format(moonSetLocal)} · ${h}h ${m}min bez Księżyca';
    } else {
      // No moon interference — full window from twilight to dawn
      final dawnLocal = dawn?.toLocal();
      final endFmt = dawnLocal != null ? ' – ${_fmt.format(dawnLocal)}' : '';
      window = '${_fmt.format(start)}$endFmt';
      sub = 'Pełna ciemność po zmierzchu astronomicznym';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.scoreGreen.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.scoreGreen.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🌑', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Okno ciemnego nieba: $window',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.scoreGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppTheme.scoreGreen.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rise / set table ──────────────────────────────────────────────────────────

class _RiseSetCard extends ConsumerWidget {
  const _RiseSetCard();

  static final _fmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sunAsync = ref.watch(planetBodyProvider(CelestialBodyId.sun));
    final moonAsync = ref.watch(moonBodyProvider);
    final twilightAsync = ref.watch(astroTwilightProvider);

    return _SpaceCard(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WSCHODY I ZACHODY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textAccent,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _RiseSetRow(
            icon: '☀️',
            label: 'Słońce',
            col1Label: 'Wschód',
            col1: _fmtTime(sunAsync.valueOrNull?.riseTime),
            col2Label: 'Zachód',
            col2: _fmtTime(sunAsync.valueOrNull?.setTime),
            col3Label: 'Astro zmierzch',
            col3: _fmtTime(twilightAsync.valueOrNull),
          ),
          const Divider(height: 16, color: AppTheme.border),
          _RiseSetRow(
            icon: '🌙',
            label: 'Księżyc',
            col1Label: 'Wschód',
            col1: _fmtTime(moonAsync.valueOrNull?.riseTime),
            col2Label: 'Zachód',
            col2: _fmtTime(moonAsync.valueOrNull?.setTime),
            col3Label: 'Alt teraz',
            col3: moonAsync.valueOrNull != null
                ? '${moonAsync.value!.altitude.toStringAsFixed(0)}°'
                : '–',
            col3Color: (moonAsync.valueOrNull?.isAboveHorizon ?? false)
                ? AppTheme.scoreGreen
                : null,
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime? t) =>
      t != null ? _fmt.format(t.toLocal()) : '–';
}

class _RiseSetRow extends StatelessWidget {
  const _RiseSetRow({
    required this.icon,
    required this.label,
    required this.col1Label,
    required this.col1,
    required this.col2Label,
    required this.col2,
    required this.col3Label,
    required this.col3,
    this.col3Color,
  });

  final String icon;
  final String label;
  final String col1Label;
  final String col1;
  final String col2Label;
  final String col2;
  final String col3Label;
  final String col3;
  final Color? col3Color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textAccent),
          ),
        ),
        Expanded(child: _Col(label: col1Label, value: col1)),
        Expanded(child: _Col(label: col2Label, value: col2)),
        Expanded(child: _Col(label: col3Label, value: col3, valueColor: col3Color)),
      ],
    );
  }
}

class _Col extends StatelessWidget {
  const _Col({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.textMain,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ── Planets section ───────────────────────────────────────────────────────────

class _PlanetsSection extends StatelessWidget {
  const _PlanetsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PLANETY · WYSOKOŚĆ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textAccent,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _planetIds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _PlanetChip(id: _planetIds[i]),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _PlanetChip extends ConsumerWidget {
  const _PlanetChip({required this.id});

  final CelestialBodyId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyAsync = ref.watch(planetBodyProvider(id));

    return GestureDetector(
      onTap: bodyAsync.valueOrNull != null
          ? () => showBodyDetailSheet(context, bodyAsync.value!)
          : null,
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.9,
                  colors: _gradient(id),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _name(id),
              style: const TextStyle(fontSize: 8, color: AppTheme.textAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            bodyAsync.when(
              data: (body) => Column(
                children: [
                  Text(
                    body.isAboveHorizon
                        ? '${body.altitude.toStringAsFixed(0)}°'
                        : '–',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _altColor(body.altitude, body.isAboveHorizon),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 44,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor:
                          body.altitude.clamp(0, 90) / 90,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _altColor(body.altitude, body.isAboveHorizon),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 16),
              error: (_, __) => const SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }

  Color _altColor(double alt, bool above) {
    if (!above) return AppTheme.scoreRed;
    if (alt > 30) return AppTheme.scoreGreen;
    if (alt > 10) return AppTheme.scoreOrange;
    return AppTheme.scoreRed;
  }

  List<Color> _gradient(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun =>
          const [Color(0xFFFFF5A0), Color(0xFFFFD700), Color(0xFFF08000)],
        CelestialBodyId.jupiter =>
          const [Color(0xFFE8C87A), Color(0xFFC4A882), Color(0xFF3A2500)],
        CelestialBodyId.saturn =>
          const [Color(0xFFF0E070), Color(0xFFC8B060), Color(0xFF302000)],
        CelestialBodyId.venus =>
          const [Color(0xFFFFD0A0), Color(0xFFE8C87A), Color(0xFF302000)],
        CelestialBodyId.mars =>
          const [Color(0xFFFF9060), Color(0xFFC1634A), Color(0xFF2A0A00)],
        CelestialBodyId.mercury =>
          const [Color(0xFFB0A090), Color(0xFFB5A99A), Color(0xFF201A10)],
        CelestialBodyId.uranus =>
          const [Color(0xFF9AF0F0), Color(0xFF7DE8E8), Color(0xFF003030)],
        CelestialBodyId.neptune =>
          const [Color(0xFF8898F8), Color(0xFF3F6FE0), Color(0xFF001040)],
        _ => const [Color(0xFF888888), Color(0xFF666666), Color(0xFF222222)],
      };

  String _name(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => 'Słońce',
        CelestialBodyId.mercury => 'Merkury',
        CelestialBodyId.venus => 'Wenus',
        CelestialBodyId.mars => 'Mars',
        CelestialBodyId.jupiter => 'Jowisz',
        CelestialBodyId.saturn => 'Saturn',
        CelestialBodyId.uranus => 'Uran',
        CelestialBodyId.neptune => 'Neptun',
        _ => id.name,
      };
}

// ── DSO tonight section ───────────────────────────────────────────────────────

// ── Cloud cover banner ────────────────────────────────────────────────────────

class _CloudBanner extends StatelessWidget {
  const _CloudBanner({required this.cloudPct});

  final int cloudPct;

  @override
  Widget build(BuildContext context) {
    final overcast = cloudPct >= 80;
    final color = overcast ? AppTheme.scoreRed : AppTheme.scoreOrange;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(overcast ? '☁' : '⛅', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overcast
                      ? 'Niebo zachmurzone · obserwacja niemożliwa'
                      : 'Częściowe zachmurzenie · warunki ograniczone',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  'Zachmurzenie $cloudPct% · wyniki astronomiczne poniżej',
                  style: TextStyle(
                    fontSize: 9,
                    color: color.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── DSO tonight section ───────────────────────────────────────────────────────

class _DsoSection extends ConsumerWidget {
  const _DsoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsoAsync = ref.watch(visibleDsoTodayProvider);
    final cloud = ref.watch(cloudCoverProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Obiekty tej nocy',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain,
                    ),
                  ),
                  Text(
                    'Posortowane wg szansy na dobre zdjęcie',
                    style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (cloud != null && cloud >= 30) _CloudBanner(cloudPct: cloud),
          dsoAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: AppTheme.scoreGreen),
              ),
            ),
            error: (e, _) => Text(
              'Błąd: $e',
              style: const TextStyle(color: AppTheme.scoreRed),
            ),
            data: (results) {
              if (results.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Żaden obiekt nie jest dziś dobrze widoczny',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }
              return Column(
                children: results
                    .take(7)
                    .map((r) => _DsoNightCard(result: r))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DsoNightCard extends StatelessWidget {
  const _DsoNightCard({required this.result});

  final DsoVisibilityResult result;

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final score = result.score;
    final accentColor = score >= 7
        ? AppTheme.scoreGreen
        : score >= 5
            ? AppTheme.scoreOrange
            : AppTheme.scoreRed;

    final timeStr = result.bestTimeUtc != null
        ? _timeFmt.format(result.bestTimeUtc!.toLocal())
        : '–';

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Left color strip
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  // Emoji icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      border:
                          Border.all(color: accentColor.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _emoji(result.dso.type),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              result.dso.catalogName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMain,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                result.dso.namePl,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textAccent,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_typeName(result.dso.type)} · '
                          'mag ${result.dso.magnitude.toStringAsFixed(1)} · '
                          "${result.dso.angularSizeArcmin.toStringAsFixed(0)}'",
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _Tag(
                              'Alt ${result.maxAltitudeDeg.toStringAsFixed(0)}°',
                              color: AppTheme.accentBlue,
                              bg: const Color(0x264A7FD4),
                            ),
                            _Tag(
                              'Księżyc ${result.moonSeparationDeg.toStringAsFixed(0)}°',
                              color: AppTheme.scoreOrange,
                              bg: const Color(0x26BA7517),
                            ),
                            _Tag(
                              'Najlepiej $timeStr',
                              color: const Color(0xFF9F97E0),
                              bg: const Color(0x26534AB7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Score circle
                  Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
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
                            score.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '/ 10',
                        style: TextStyle(fontSize: 7, color: AppTheme.textMuted),
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
      builder: (_) => _DsoDetailSheet(result: result),
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

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.color, required this.bg});

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── DSO detail sheet (shared between dashboard and catalog) ───────────────────

class _DsoDetailSheet extends StatelessWidget {
  const _DsoDetailSheet({required this.result});

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
            Row(
              children: [
                Text(
                  _emoji(dso.type),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
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
                      Text(
                        dso.nameEn,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.border),
            _row('Typ', _typeName(dso.type)),
            _row(
              'RA / Dec',
              '${dso.raHours.toStringAsFixed(2)} h'
              ' / ${dso.decDeg.toStringAsFixed(1)}°',
            ),
            _row('Jasność', '${dso.magnitude.toStringAsFixed(1)} mag'),
            _row('Rozmiar', "${dso.angularSizeArcmin.toStringAsFixed(0)}'"),
            const Divider(height: 24, color: AppTheme.border),
            _row('Max wysokość', '${result.maxAltitudeDeg.toStringAsFixed(1)}°'),
            _row('Najlepszy czas', timeStr),
            _row('Odl. od Księżyca', '${result.moonSeparationDeg.toStringAsFixed(0)}°'),
            _row('Score', result.score.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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

// ── Shared card container ─────────────────────────────────────────────────────

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({required this.child, this.margin});

  final Widget child;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
