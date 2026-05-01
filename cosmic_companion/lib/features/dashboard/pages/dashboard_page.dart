import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/calendar/pages/calendar_page.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dashboard/widgets/moon_card.dart';
import 'package:cosmic_companion/features/dashboard/widgets/night_mode_button.dart';
import 'package:cosmic_companion/features/dashboard/widgets/seeing_indicator.dart';
import 'package:cosmic_companion/features/dashboard/widgets/zodiac_card.dart';
import 'package:cosmic_companion/features/map/pages/light_pollution_map_page.dart';
import 'package:cosmic_companion/features/settings/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          const NightModeButton(),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CalendarPage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LightPollutionMapPage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsPage(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(currentLocationProvider)
            ..invalidate(moonPhaseProvider)
            ..invalidate(moonBodyProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            MoonCard(),
            SizedBox(height: 12),
            ZodiacCard(),
            SizedBox(height: 12),
            SeeingIndicator(),
          ],
        ),
      ),
    );
  }
}
