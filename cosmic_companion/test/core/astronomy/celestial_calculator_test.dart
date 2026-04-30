import 'dart:math';

import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ZodiacSign.fromEclipticLongitude', () {
    test('maps each 30° sector correctly', () {
      const cases = <(double, ZodiacSign)>[
        (0, ZodiacSign.aries),
        (15, ZodiacSign.aries),
        (29.9, ZodiacSign.aries),
        (30, ZodiacSign.taurus),
        (60, ZodiacSign.gemini),
        (90, ZodiacSign.cancer),
        (120, ZodiacSign.leo),
        (150, ZodiacSign.virgo),
        (180, ZodiacSign.libra),
        (210, ZodiacSign.scorpio),
        (240, ZodiacSign.sagittarius),
        (270, ZodiacSign.capricorn),
        (300, ZodiacSign.aquarius),
        (330, ZodiacSign.pisces),
        (359.9, ZodiacSign.pisces),
      ];
      for (final (lon, expected) in cases) {
        expect(
          ZodiacSign.fromEclipticLongitude(lon),
          expected,
          reason: '$lon° should be $expected',
        );
      }
    });

    test('wraps longitude > 360', () {
      expect(ZodiacSign.fromEclipticLongitude(360), ZodiacSign.aries);
      expect(ZodiacSign.fromEclipticLongitude(390), ZodiacSign.taurus);
    });
  });

  group('MoonPhaseName.fromAngle', () {
    test('returns correct phase at sector boundaries', () {
      const cases = <(double, MoonPhaseName)>[
        (0, MoonPhaseName.newMoon),
        (22.4, MoonPhaseName.newMoon),
        (22.5, MoonPhaseName.waxingCrescent),
        (67.4, MoonPhaseName.waxingCrescent),
        (67.5, MoonPhaseName.firstQuarter),
        (90, MoonPhaseName.firstQuarter),
        (112.4, MoonPhaseName.firstQuarter),
        (112.5, MoonPhaseName.waxingGibbous),
        (157.4, MoonPhaseName.waxingGibbous),
        (157.5, MoonPhaseName.fullMoon),
        (180, MoonPhaseName.fullMoon),
        (202.4, MoonPhaseName.fullMoon),
        (202.5, MoonPhaseName.waningGibbous),
        (247.4, MoonPhaseName.waningGibbous),
        (247.5, MoonPhaseName.lastQuarter),
        (270, MoonPhaseName.lastQuarter),
        (292.4, MoonPhaseName.lastQuarter),
        (292.5, MoonPhaseName.waningCrescent),
        (337.4, MoonPhaseName.waningCrescent),
        (337.5, MoonPhaseName.newMoon),
        (359.9, MoonPhaseName.newMoon),
      ];
      for (final (angle, expected) in cases) {
        expect(
          MoonPhaseName.fromAngle(angle),
          expected,
          reason: '$angle° should be $expected',
        );
      }
    });

    test('wraps angle > 360 via modulo', () {
      expect(MoonPhaseName.fromAngle(360), MoonPhaseName.newMoon);
      expect(MoonPhaseName.fromAngle(450), MoonPhaseName.firstQuarter);
    });
  });

  group('Moon illumination formula', () {
    double illumination(double angle) =>
        (1 - cos(angle * pi / 180)) / 2 * 100;

    test('0% at new moon (0°)', () {
      expect(illumination(0), closeTo(0, 0.001));
    });

    test('50% at first quarter (90°)', () {
      expect(illumination(90), closeTo(50, 0.001));
    });

    test('100% at full moon (180°)', () {
      expect(illumination(180), closeTo(100, 0.001));
    });

    test('50% at last quarter (270°)', () {
      expect(illumination(270), closeTo(50, 0.001));
    });
  });

}

// SwissEph comparison tests live in integration_test/astronomy_integration_test.dart.
// They require sweph.dll (built by CMake for Windows) and are run on-device:
//   flutter test integration_test/astronomy_integration_test.dart
