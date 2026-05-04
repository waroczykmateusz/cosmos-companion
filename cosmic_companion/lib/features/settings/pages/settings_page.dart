import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/auth/pages/privacy_settings_page.dart';
import 'package:cosmic_companion/features/settings/pages/about_page.dart';
import 'package:cosmic_companion/features/settings/pages/equipment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    final profile = switch (auth) {
      Authenticated(:final user) => user,
      Locked(:final user) => user,
      Unauthenticated() => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          if (profile != null) _ProfileHeader(nick: profile.nick),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(l10n.equipmentTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EquipmentPage(),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacySettingsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacySettingsPage(),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AboutPage(),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.lockAction),
            onTap: () => ref.read(localAuthProvider.notifier).lock(),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.nick});

  final String nick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              nick.isNotEmpty ? nick[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 10),
          Text(nick, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
