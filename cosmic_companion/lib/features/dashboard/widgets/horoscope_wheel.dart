import 'dart:math';

import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Public card ──────────────────────────────────────────────────────────────

class HoroscopeWheelCard extends ConsumerWidget {
  const HoroscopeWheelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wheelAsync = ref.watch(horoscopeWheelProvider);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.horoscopeWheelTitle,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1,
              child: wheelAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                data: (bodies) => HoroscopeWheelWidget(bodies: bodies),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bare widget (reusable) ────────────────────────────────────────────────────

class HoroscopeWheelWidget extends StatelessWidget {
  const HoroscopeWheelWidget({required this.bodies, super.key});

  final List<CelestialBody> bodies;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HoroscopeWheelPainter(bodies: bodies),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _HoroscopeWheelPainter extends CustomPainter {
  _HoroscopeWheelPainter({required this.bodies});

  final List<CelestialBody> bodies;

  // Zodiac sign background colors (low opacity, per element)
  static const _signColors = [
    Color(0xFFE53935), // Aries ♈ Fire
    Color(0xFF43A047), // Taurus ♉ Earth
    Color(0xFFFFD600), // Gemini ♊ Air
    Color(0xFF1E88E5), // Cancer ♋ Water
    Color(0xFFFF6F00), // Leo ♌ Fire
    Color(0xFF66BB6A), // Virgo ♍ Earth
    Color(0xFFFFF176), // Libra ♎ Air
    Color(0xFF3949AB), // Scorpio ♏ Water
    Color(0xFFE64A19), // Sagittarius ♐ Fire
    Color(0xFF78909C), // Capricorn ♑ Earth
    Color(0xFF00ACC1), // Aquarius ♒ Air
    Color(0xFF7B1FA2), // Pisces ♓ Water
  ];

  static const _signGlyphs = [
    '♈', '♉', '♊', '♋', '♌', '♍',
    '♎', '♏', '♐', '♑', '♒', '♓',
  ];

  // Ecliptic longitude → canvas angle (Aries 0° at 9-o'clock, CCW)
  static double _toAngle(double lon) => pi - lon * pi / 180.0;

  static String _planetGlyph(CelestialBodyId id) => switch (id) {
        CelestialBodyId.sun => '☉',
        CelestialBodyId.moon => '☽',
        CelestialBodyId.mercury => '☿',
        CelestialBodyId.venus => '♀',
        CelestialBodyId.mars => '♂',
        CelestialBodyId.jupiter => '♃',
        CelestialBodyId.saturn => '♄',
        CelestialBodyId.uranus => '♅',
        CelestialBodyId.neptune => '♆',
        CelestialBodyId.pluto => '♇',
        _ => '★',
      };

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);

    _drawBackground(canvas, c, r);
    _drawZodiacRing(canvas, c, r);
    _drawRingBorders(canvas, c, r);
    _drawAspects(canvas, c, r * 0.55);
    _drawPlanets(canvas, c, r);
  }

  void _drawBackground(Canvas canvas, Offset c, double r) {
    canvas
      ..drawCircle(c, r, Paint()..color = const Color(0xFF12122A))
      ..drawCircle(c, r * 0.62, Paint()..color = const Color(0xFF0A0A1A));
  }

  void _drawZodiacRing(Canvas canvas, Offset c, double r) {
    final outerR = r;
    final innerR = r * 0.78;

    for (var i = 0; i < 12; i++) {
      final startAngle = _toAngle(i * 30.0);
      const sweepAngle = -pi / 6; // 30° CCW

      // Sector fill
      final path = Path()
        ..arcTo(
          Rect.fromCircle(center: c, radius: outerR),
          startAngle,
          sweepAngle,
          false,
        )
        ..arcTo(
          Rect.fromCircle(center: c, radius: innerR),
          startAngle + sweepAngle,
          -sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = _signColors[i].withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      );

      // Glyph at sector midpoint
      final midAngle = startAngle + sweepAngle / 2;
      final glyphR = (outerR + innerR) / 2;
      _drawCenteredText(
        canvas,
        c + Offset(glyphR * cos(midAngle), glyphR * sin(midAngle)),
        _signGlyphs[i],
        const TextStyle(fontSize: 11, color: Colors.white70),
      );
    }
  }

  void _drawRingBorders(Canvas canvas, Offset c, double r) {
    canvas
      // Outer circle
      ..drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      )
      // Zodiac-inner circle
      ..drawCircle(
        c,
        r * 0.78,
        Paint()
          ..color = Colors.white12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      )
      // Aspect-area circle
      ..drawCircle(
        c,
        r * 0.62,
        Paint()
          ..color = Colors.white12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );

    // 12 sign dividers inside zodiac band
    final dividerPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.5;
    for (var i = 0; i < 12; i++) {
      final a = _toAngle(i * 30.0);
      canvas.drawLine(
        c + Offset(r * 0.78 * cos(a), r * 0.78 * sin(a)),
        c + Offset(r * cos(a), r * sin(a)),
        dividerPaint,
      );
    }
  }

  void _drawAspects(Canvas canvas, Offset c, double innerR) {
    for (var i = 0; i < bodies.length; i++) {
      for (var j = i + 1; j < bodies.length; j++) {
        var diff =
            (bodies[j].eclipticLongitude - bodies[i].eclipticLongitude).abs() %
                360;
        if (diff > 180) diff = 360 - diff;

        final style = _aspectStyle(diff);
        if (style == null) continue;

        final ai = _toAngle(bodies[i].eclipticLongitude);
        final aj = _toAngle(bodies[j].eclipticLongitude);
        canvas.drawLine(
          c + Offset(innerR * cos(ai), innerR * sin(ai)),
          c + Offset(innerR * cos(aj), innerR * sin(aj)),
          style,
        );
      }
    }
  }

  // Returns null when no notable aspect exists.
  Paint? _aspectStyle(double diff) {
    if (diff <= 8) {
      return Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..strokeWidth = 1.2;
    }
    if ((diff - 60).abs() <= 4) {
      return Paint()
        ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.45)
        ..strokeWidth = 0.7;
    }
    if ((diff - 90).abs() <= 6) {
      return Paint()
        ..color = const Color(0xFFEF5350).withValues(alpha: 0.65)
        ..strokeWidth = 1.1;
    }
    if ((diff - 120).abs() <= 6) {
      return Paint()
        ..color = const Color(0xFF66BB6A).withValues(alpha: 0.65)
        ..strokeWidth = 1.1;
    }
    if ((diff - 180).abs() <= 8) {
      return Paint()
        ..color = const Color(0xFFFF7043).withValues(alpha: 0.65)
        ..strokeWidth = 1.2;
    }
    return null;
  }

  void _drawPlanets(Canvas canvas, Offset c, double r) {
    final dotR = r * 0.69;
    final glyphR = r * 0.62;

    for (final body in bodies) {
      final a = _toAngle(body.eclipticLongitude);
      final dotPos = c + Offset(dotR * cos(a), dotR * sin(a));
      final color = body.isRetrograde ? const Color(0xFFFFAB40) : Colors.white;

      // Dot
      canvas.drawCircle(dotPos, 3, Paint()..color = color);

      // Glyph shifted slightly inward
      final glyphPos = c + Offset(glyphR * cos(a), glyphR * sin(a));
      _drawCenteredText(
        canvas,
        glyphPos,
        _planetGlyph(body.id),
        TextStyle(
          fontSize: 9,
          color: color.withValues(alpha: 0.9),
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    Offset center,
    String text,
    TextStyle style,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_HoroscopeWheelPainter old) =>
      old.bodies != bodies;
}
