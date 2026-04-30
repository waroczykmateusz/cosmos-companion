import 'package:cosmic_companion/core/theme/theme_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NightModeOverlay extends ConsumerWidget {
  const NightModeOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    if (mode != AppThemeMode.nightRed) return child;

    // Zeruje kanały G i B — zachowuje luminancję czerwonego.
    // Standard w aplikacjach astronomicznych (chroni adaptację oka ~30 min).
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: child,
    );
  }
}
