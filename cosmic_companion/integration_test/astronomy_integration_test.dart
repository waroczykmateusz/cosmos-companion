import 'package:cosmic_companion/core/astronomy/celestial_calculator.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Run with:  flutter test integration_test/astronomy_integration_test.dart
  // Requires sweph.dll built by CMake (flutter build windows).
  // Reference: NASA HORIZONS, Observer-centered IAU76/80 ecliptic-of-date,
  //            apparant position (light-time + aberration).
  group('CelestialCalculator — NASA HORIZONS comparison', () {
    final calculator = CelestialCalculator();
    final testUtc = DateTime.utc(2026, 4, 30, 20);
    const gdansk = GeoLocation(latitude: 54.35, longitude: 18.65);

    testWidgets('Moon ecliptic longitude within 0.01° of HORIZONS',
        (tester) async {
      final body = await calculator.computeBody(
        CelestialBodyId.moon,
        testUtc,
        gdansk,
      );
      // HORIZONS: lon = 222.6631°, lat = −4.5971° (2026-Apr-30 20:00 UT)
      expect(body.eclipticLongitude, closeTo(222.663, 0.01));
      expect(body.eclipticLatitude, closeTo(-4.597, 0.01));
    });

    testWidgets('Moon ZodiacSign is Scorpio at 222.7°', (tester) async {
      final body = await calculator.computeBody(
        CelestialBodyId.moon,
        testUtc,
        gdansk,
      );
      expect(body.zodiacSign, ZodiacSign.scorpio);
      expect(body.signDegree, closeTo(12.7, 0.5));
    });

    testWidgets('Moon alt/az are physically valid', (tester) async {
      final body = await calculator.computeBody(
        CelestialBodyId.moon,
        testUtc,
        gdansk,
      );
      expect(body.altitude, inInclusiveRange(-90, 90));
      expect(body.azimuth, inInclusiveRange(0, 360));
      expect(body.isAboveHorizon, body.altitude > 0);
    });

    testWidgets('computeMoonPhase returns valid phase and illumination',
        (tester) async {
      final phase = await calculator.computeMoonPhase(testUtc);
      expect(phase.illuminationPercent, inInclusiveRange(0, 100));
      expect(phase.phaseAngle, inInclusiveRange(0, 360));
      expect(phase.epoch, testUtc);
      expect(MoonPhaseName.values, contains(phase.name));
    });
  });
}
