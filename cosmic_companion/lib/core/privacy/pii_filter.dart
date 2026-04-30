import 'package:sentry_flutter/sentry_flutter.dart';

final class PiiFilter {
  static const _sensitiveKeys = {
    'email', 'nick', 'username', 'lat', 'lon',
    'latitude', 'longitude', 'location', 'name',
  };

  static final _emailPattern = RegExp(r'[\w.+\-]+@[\w\-]+\.\w+');
  static final _coordPattern = RegExp(r'-?\d{1,3}\.\d{4,}');

  SentryEvent scrub(SentryEvent event) {
    // Czyścimy użytkownika przez pusty obiekt (copyWith(user: null) zachowuje oryginał).
    return event.copyWith(
      user: SentryUser(),
      tags: _scrubTags(event.tags),
    );
  }

  Map<String, String>? _scrubTags(Map<String, String>? tags) {
    if (tags == null) return null;
    return {
      for (final e in tags.entries)
        if (!_sensitiveKeys.contains(e.key.toLowerCase()))
          e.key: _scrubString(e.value),
    };
  }

  String _scrubString(String s) => s
      .replaceAll(_emailPattern, '[email]')
      .replaceAll(_coordPattern, '[location]');
}
