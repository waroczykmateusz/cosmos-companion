import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/core/error/failures.dart';
import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/auth/widgets/pin_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Step { nick, pin, pinConfirm, biometric }

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  _Step _step = _Step.nick;
  final _nickController = TextEditingController();
  String _pin = '';
  String _pinConfirm = '';
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  void _onDigit(String d) {
    setState(() {
      _error = null;
      if (_step == _Step.pin && _pin.length < 6) {
        _pin += d;
      } else if (_step == _Step.pinConfirm && _pinConfirm.length < 6) {
        _pinConfirm += d;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_step == _Step.pin && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_step == _Step.pinConfirm && _pinConfirm.isNotEmpty) {
        _pinConfirm = _pinConfirm.substring(0, _pinConfirm.length - 1);
      }
    });
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context);
    switch (_step) {
      case _Step.nick:
        if (_nickController.text.trim().isEmpty) return;
        setState(() => _step = _Step.pin);
      case _Step.pin:
        if (_pin.length < 4) return;
        setState(() {
          _step = _Step.pinConfirm;
          _pinConfirm = '';
        });
      case _Step.pinConfirm:
        if (_pinConfirm.length < 4) return;
        if (_pin != _pinConfirm) {
          setState(() {
            _error = l10n.pinMismatch;
            _pinConfirm = '';
          });
          return;
        }
        setState(() => _step = _Step.biometric);
      case _Step.biometric:
        await _finish(biometric: true);
    }
  }

  Future<void> _finish({required bool biometric}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(localAuthProvider.notifier).createProfile(
            nick: _nickController.text.trim(),
            pin: _pin,
            biometricEnabled: biometric,
          );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildStep(context, l10n),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppLocalizations l10n) {
    return switch (_step) {
      _Step.nick => _NickStep(
          controller: _nickController,
          onNext: _next,
          l10n: l10n,
        ),
      _Step.pin => _PinStep(
          title: l10n.pinSetupTitle,
          pin: _pin,
          error: _error,
          onDigit: _onDigit,
          onBackspace: _onBackspace,
          onConfirm: _pin.length >= 4 ? _next : null,
          l10n: l10n,
        ),
      _Step.pinConfirm => _PinStep(
          title: l10n.pinConfirmTitle,
          pin: _pinConfirm,
          error: _error,
          onDigit: _onDigit,
          onBackspace: _onBackspace,
          onConfirm: _pinConfirm.length >= 4 ? _next : null,
          l10n: l10n,
        ),
      _Step.biometric => _BiometricStep(
          onEnable: () => _finish(biometric: true),
          onSkip: () => _finish(biometric: false),
          l10n: l10n,
        ),
    };
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _NickStep extends StatelessWidget {
  const _NickStep({
    required this.controller,
    required this.onNext,
    required this.l10n,
  });

  final TextEditingController controller;
  final VoidCallback onNext;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingTitle,
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.onboardingNickLabel,
            hintText: l10n.onboardingNickHint,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onNext(),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: onNext, child: Text(l10n.next)),
      ],
    );
  }
}

class _PinStep extends StatelessWidget {
  const _PinStep({
    required this.title,
    required this.pin,
    required this.onDigit,
    required this.onBackspace,
    required this.l10n,
    this.error,
    this.onConfirm,
  });

  final String title;
  final String pin;
  final String? error;
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onConfirm;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 32),
        _PinDots(length: pin.length),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 32),
        PinKeypad(onDigit: onDigit, onBackspace: onBackspace),
        const SizedBox(height: 16),
        if (onConfirm != null)
          FilledButton(onPressed: onConfirm, child: Text(l10n.confirm)),
      ],
    );
  }
}

class _BiometricStep extends StatelessWidget {
  const _BiometricStep({
    required this.onEnable,
    required this.onSkip,
    required this.l10n,
  });

  final VoidCallback onEnable;
  final VoidCallback onSkip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.fingerprint, size: 80),
        const SizedBox(height: 24),
        Text(
          l10n.biometricSetupTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(l10n.biometricSetupMessage, textAlign: TextAlign.center),
        const SizedBox(height: 40),
        FilledButton(onPressed: onEnable, child: Text(l10n.yes)),
        const SizedBox(height: 12),
        TextButton(onPressed: onSkip, child: Text(l10n.skip)),
      ],
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
