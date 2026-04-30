import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/core/error/failures.dart';
import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/auth/widgets/biometric_button.dart';
import 'package:cosmic_companion/features/auth/widgets/pin_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockScreenPage extends ConsumerStatefulWidget {
  const LockScreenPage({super.key});

  @override
  ConsumerState<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends ConsumerState<LockScreenPage> {
  String _pin = '';
  String? _error;
  bool _loading = false;

  void _onDigit(String d) {
    if (_loading || _pin.length >= 6) return;
    setState(() {
      _pin += d;
      _error = null;
    });
  }

  void _onBackspace() {
    if (_loading || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _tryUnlock() async {
    if (_loading || _pin.length < 4) return;
    setState(() => _loading = true);
    try {
      await ref.read(localAuthProvider.notifier).unlockWithPin(_pin);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _pin = '';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    final nick = auth is Locked ? auth.user.nick : null;
    final biometricEnabled = auth is Locked && auth.user.biometricEnabled;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.lockScreenTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (nick != null) ...[
                const SizedBox(height: 8),
                Text(nick, style: Theme.of(context).textTheme.titleMedium),
              ],
              const SizedBox(height: 32),
              _PinDots(length: _pin.length),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              if (_loading)
                const CircularProgressIndicator()
              else ...[
                PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
                const SizedBox(height: 16),
                if (_pin.length >= 4)
                  FilledButton(
                    onPressed: _tryUnlock,
                    child: Text(l10n.ok),
                  ),
                if (biometricEnabled) ...[
                  const SizedBox(height: 16),
                  const BiometricButton(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        6,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < length
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
