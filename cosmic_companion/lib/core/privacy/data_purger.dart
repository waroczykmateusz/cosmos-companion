import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// GDPR Right to Erasure — usuwa wszystkie dane użytkownika z urządzenia.
// Drift DB wstrzykiwany będzie po implementacji kroku 5.
final class DataPurger {
  const DataPurger(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> purgeAll() async {
    await _storage.deleteAll();
    // TODO(step-5): db.delete wszystkich tabel user-facing
    // TODO(step-5): Sentry.configureScope((s) => s.clear())
  }
}
