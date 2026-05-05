import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/map/domain/bortle_classifier.dart';
import 'package:cosmic_companion/features/map/providers/map_providers.dart';
import 'package:cosmic_companion/features/map/widgets/bortle_legend.dart';
import 'package:cosmic_companion/features/map/widgets/location_planner_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class LightPollutionMapPage extends ConsumerStatefulWidget {
  const LightPollutionMapPage({super.key});

  @override
  ConsumerState<LightPollutionMapPage> createState() =>
      _LightPollutionMapPageState();
}

class _LightPollutionMapPageState
    extends ConsumerState<LightPollutionMapPage> {
  bool _showOverlay = true;
  bool _showLegend = false;

  void _onMapTap(TapPosition _, LatLng point) {
    ref.read(selectedPlannerLocationProvider.notifier).state = point;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPlannerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locationAsync = ref.watch(currentLocationProvider);
    final selectedLoc = ref.watch(selectedPlannerLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTitle),
        actions: [
          IconButton(
            icon: Icon(
              _showOverlay ? Icons.layers : Icons.layers_outlined,
            ),
            tooltip: l10n.lightPollutionOverlay,
            onPressed: () => setState(() => _showOverlay = !_showOverlay),
          ),
          IconButton(
            icon: Icon(
              _showLegend ? Icons.info : Icons.info_outline,
            ),
            tooltip: l10n.bortleScaleTitle,
            onPressed: () => setState(() => _showLegend = !_showLegend),
          ),
        ],
      ),
      body: locationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '${AppLocalizations.of(context).error}: $e',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        data: (location) {
          final center = LatLng(location.latitude, location.longitude);
          final bortleLevel =
              ref.watch(bortleLevelProvider).valueOrNull ?? BortleLevel.one;

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 9,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_matter/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.waroczyk.cosmic_companion',
                    fallbackUrl:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  if (_showOverlay)
                    Opacity(
                      opacity: 0.85,
                      child: TileLayer(
                        urlTemplate:
                            'https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/'
                            'VIIRS_Black_Marble/default/2016-01-01/'
                            'GoogleMapsCompatible_Level8/{z}/{y}/{x}.png',
                        maxNativeZoom: 8,
                        userAgentPackageName: 'com.waroczyk.cosmic_companion',
                        errorTileCallback: (_, __, ___) {},
                      ),
                    ),
                  // Current location marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 40,
                        height: 40,
                        child: _LocationMarker(bortleLevel: bortleLevel),
                      ),
                    ],
                  ),
                  // Planner (tapped) location marker
                  if (selectedLoc != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLoc,
                          width: 36,
                          height: 36,
                          child: const _PlannerMarker(),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: _BortleBadge(
                  level: bortleLevel,
                  label: l10n.bortleEstimateLabel,
                ),
              ),
              if (_showLegend)
                Positioned(
                  right: 8,
                  top: 8,
                  width: 220,
                  child: BortleLegend(highlighted: bortleLevel),
                ),
              Positioned(
                left: 16,
                right: _showLegend ? 236 : 16,
                bottom: 72,
                child: _DarkSkyTip(tip: l10n.darkSkyTip),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _LocationMarker extends StatelessWidget {
  const _LocationMarker({required this.bortleLevel});

  final BortleLevel bortleLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bortleLevel.color.withAlpha(200),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black54)],
      ),
      child: const Icon(Icons.my_location, size: 18, color: Colors.white),
    );
  }
}

class _PlannerMarker extends StatelessWidget {
  const _PlannerMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(220),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black54)],
      ),
      child: const Icon(Icons.travel_explore, size: 18, color: Colors.white),
    );
  }
}

class _BortleBadge extends StatelessWidget {
  const _BortleBadge({required this.level, required this.label});

  final BortleLevel level;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: level.color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: level.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white70),
              ),
              Text(
                'Bortle ${level.value} — ${level.description}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkSkyTip extends StatelessWidget {
  const _DarkSkyTip({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tip,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white70),
      ),
    );
  }
}
