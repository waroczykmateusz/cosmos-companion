import 'package:cosmic_companion/core/auth/auth_state.dart';
import 'package:cosmic_companion/core/di/providers.dart';
import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/features/auth/pages/privacy_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
      body: profile == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProfileHeader(nick: profile.nick),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l10n.privacySettingsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacySettingsPage(),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Zablokuj'),
                  onTap: () =>
                      ref.read(localAuthProvider.notifier).lock(),
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
            radius: 40,
            child: Text(
              nick.isNotEmpty ? nick[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 12),
          Text(nick, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
