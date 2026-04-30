import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { normal, nightDark, nightRed }

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.normal);

  void toggle() {
    state = switch (state) {
      AppThemeMode.normal => AppThemeMode.nightDark,
      AppThemeMode.nightDark => AppThemeMode.nightRed,
      AppThemeMode.nightRed => AppThemeMode.normal,
    };
  }

  // Setter would require a getter; StateNotifier exposes state directly.
  // ignore: use_setters_to_change_properties
  void setMode(AppThemeMode mode) => state = mode;
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(),
);
