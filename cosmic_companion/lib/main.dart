import 'package:cosmic_companion/app.dart';
import 'package:cosmic_companion/core/privacy/pii_filter.dart';
import 'package:cosmic_companion/core/privacy/telemetry_consent.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Podaj DSN przez --dart-define=SENTRY_DSN=https://... przy release buildzie.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_sentryDsn.isEmpty) {
    runApp(const ProviderScope(child: CosmicCompanionApp()));
    return;
  }

  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  // PiiFilter ma static final RegExp — nie może być const.
  // ignore: prefer_const_constructors
  final piiFilter = PiiFilter();
  const telemetryConsent = TelemetryConsent(storage);

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = _sentryDsn
        ..beforeSend = (event, hint) async {
          if (!await telemetryConsent.isOptedIn()) return null;
          return piiFilter.scrub(event);
        };
    },
    appRunner: () => runApp(const ProviderScope(child: CosmicCompanionApp())),
  );
}
