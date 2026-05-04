import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

const _appVersion = '0.1.0';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, size: 64),
                const SizedBox(height: 12),
                Text(l10n.appTitle, style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  '${l10n.versionLabel} $_appVersion',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _showComingSoon(context, l10n),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _showComingSoon(context, l10n),
          ),
          const Divider(height: 1),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2026 Mateusz Waroczyk',
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }
}
