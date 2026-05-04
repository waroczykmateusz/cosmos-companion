import 'package:cosmic_companion/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NightModeButton extends ConsumerWidget {
  const NightModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final icon = switch (mode) {
      AppThemeMode.normal => Icons.dark_mode_outlined,
      AppThemeMode.nightDark => Icons.brightness_2,
      AppThemeMode.nightRed => Icons.wb_sunny_outlined,
    };
    return IconButton(
      icon: Icon(icon),
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
    );
  }
}
