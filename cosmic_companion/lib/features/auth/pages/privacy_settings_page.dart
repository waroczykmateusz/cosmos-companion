import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacySettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TelemetryTile(l10n: l10n),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              l10n.deleteAllData,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmDelete(context, ref, l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAllData),
        content: Text(l10n.deleteAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(dataPurgerProvider).purgeAll();
    await ref.read(localAuthProvider.notifier).signOut();
  }
}

class _TelemetryTile extends ConsumerStatefulWidget {
  const _TelemetryTile({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_TelemetryTile> createState() => _TelemetryTileState();
}

class _TelemetryTileState extends ConsumerState<_TelemetryTile> {
  bool? _optedIn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result =
        await ref.read(telemetryConsentProvider).isOptedIn();
    if (mounted) setState(() => _optedIn = result);
  }

  Future<void> _toggle(bool value) async {
    await ref.read(telemetryConsentProvider).setOptIn(value: value);
    if (mounted) setState(() => _optedIn = value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.l10n.telemetryLabel),
      subtitle: Text(widget.l10n.telemetryDescription),
      value: _optedIn ?? false,
      onChanged: _optedIn == null ? null : _toggle,
    );
  }
}
