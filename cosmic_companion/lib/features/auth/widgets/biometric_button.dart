import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/core/error/failures.dart';
import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiometricButton extends ConsumerWidget {
  const BiometricButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      iconSize: 48,
      tooltip: AppLocalizations.of(context).unlockWithBiometric,
      icon: const Icon(Icons.fingerprint, size: 48),
      onPressed: () => _authenticate(context, ref),
    );
  }

  Future<void> _authenticate(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(localAuthProvider.notifier).unlockWithBiometric();
    } on AuthFailure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
