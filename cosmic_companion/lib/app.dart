import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/core/routing/app_router.dart';
import 'package:cosmic_companion/core/theme/app_theme.dart';
import 'package:cosmic_companion/core/theme/night_mode_overlay.dart';
import 'package:cosmic_companion/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CosmicCompanionApp extends ConsumerWidget {
  const CosmicCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Cosmic Companion',
      debugShowCheckedModeBanner: false,
      theme: themeMode == AppThemeMode.nightDark
          ? AppTheme.nightDark
          : AppTheme.dark,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => NightModeOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
