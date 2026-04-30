// Stub — placeholder pod astronomy_engine_dart (git dependency TBD).
// Docelowo: rise/set/transit times + precyzyjne alt/az dla obserwatora.
// Obecnie SwissEph pokrywa te potrzeby przez swe_azalt + swe_rise_trans.
abstract final class AstronomyEngineService {
  static Future<void> ensureInitialized() async {}
}
