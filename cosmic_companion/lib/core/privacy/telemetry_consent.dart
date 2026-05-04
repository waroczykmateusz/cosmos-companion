import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class TelemetryConsent {
  const TelemetryConsent(this._storage);

  final FlutterSecureStorage _storage;
  static const _key = 'telemetry_opt_in';

  Future<bool> isOptedIn() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  Future<void> setOptIn({required bool value}) =>
      _storage.write(key: _key, value: value.toString());
}
