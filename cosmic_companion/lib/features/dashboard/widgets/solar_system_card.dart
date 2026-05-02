import 'dart:math';

import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Card ─────────────────────────────────────────────────────────────────────

class SolarSystemCard extends ConsumerWidget {
  const SolarSystemCard({super.key});

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
                data: (bodies) => SolarSystemWidget(bodies: bodies),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bare widget ───────────────────────────────────────────────────────────────

class SolarSystemWidget extends StatelessWidget {
  const SolarSystemWidget({required this.bodies, super.key});

  final List<CelestialBody> bodies;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SolarSystemPainter(bodies: bodies));
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _SolarSystemPainter extends CustomPainter {
  _SolarSystemPainter({required this.bodies});

  final List<CelestialBody> bodies;

  // Vertical compression — how "tilted" we view the orbital plane
  static const _tilt = 0.42;

  // Orbital ring radii as fraction of half-canvas
  static const _orbFrac = {
    CelestialBodyId.mercury: 0.14,
    CelestialBodyId.venus: 0.22,
    CelestialBodyId.mars: 0.32,
    CelestialBodyId.jupiter: 0.47,
    CelestialBodyId.saturn: 0.61,
    CelestialBodyId.uranus: 0.75,
    CelestialBodyId.neptune: 0.88,
    CelestialBodyId.pluto: 0.95,
  };

  static const _planetColors = {
    CelestialBodyId.mercury: Color(0xFFAAAAAA),
    CelestialBodyId.venus: Color(0xFFE8D5A3),
    CelestialBodyId.mars: Color(0xFFE64A19),
    CelestialBodyId.jupiter: Color(0xFFCBB89A),
    CelestialBodyId.saturn: Color(0xFFE5D08A),
    CelestialBodyId.uranus: Color(0xFF80DEEA),
    CelestialBodyId.neptune: Color(0xFF4F6FBB),
    CelestialBodyId.pluto: Color(0xFF9E8070),
  };

  static const _planetRadius = {
    CelestialBodyId.mercury: 4.0,
    CelestialBodyId.venus: 7.0,
    CelestialBodyId.mars: 5.0,
    CelestialBodyId.jupiter: 14.0,
    CelestialBodyId.saturn: 11.0,
    CelestialBodyId.uranus: 8.0,
    CelestialBodyId.neptune: 8.0,
    CelestialBodyId.pluto: 3.0,
  };

  static const _planetGlyphs = {
    CelestialBodyId.mercury: '☿',
    CelestialBodyId.venus: '♀',
    CelestialBodyId.mars: '♂',
    CelestialBodyId.jupiter: '♃',
    CelestialBodyId.saturn: '♄',
    CelestialBodyId.uranus: '♅',
    CelestialBodyId.neptune: '♆',
    CelestialBodyId.pluto: '♇',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);

    _drawBackground(canvas, size, c, r);
    _drawOrbits(canvas, c, r);
    _drawSun(canvas, c);
    _drawPlanets(canvas, c, r);
  }

  // ── Background ─────────────────────────────────────────────────────────────

  void _drawBackground(Canvas canvas, Size size, Offset c, double r) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF0D1233), Color(0xFF030614)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final rng = Random(7331);
    for (var i = 0; i < 200; i++) {
      final sx = rng.nextDouble() * size.width;
      final sy = rng.nextDouble() * size.height;
      final sr = rng.nextDouble() * 1.2 + 0.3;
      final alpha = rng.nextDouble() * 0.6 + 0.3;
      canvas.drawCircle(
        Offset(sx, sy),
        sr,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  // ── Orbital rings ──────────────────────────────────────────────────────────

  void _drawOrbits(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (final frac in _orbFrac.values) {
      final orbR = r * frac;
      canvas.drawOval(
        Rect.fromCenter(center: c, width: orbR * 2, height: orbR * 2 * _tilt),
        paint,
      );
    }
  }

  // ── Sun ────────────────────────────────────────────────────────────────────

  void _drawSun(Canvas canvas, Offset c) {
    // Bloom layers
    for (final (rad, alpha) in [
      (44.0, 0.03),
      (32.0, 0.06),
      (22.0, 0.12),
      (14.0, 0.22),
    ]) {
      canvas.drawCircle(
        c,
        rad,
        Paint()
          ..color = const Color(0xFFFFDD44).withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }
    // Core
    canvas.drawCircle(
      c,
      11,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFFFBB), Color(0xFFFFBB00)],
        ).createShader(Rect.fromCircle(center: c, radius: 11)),
    );
  }

  // ── Planets ────────────────────────────────────────────────────────────────

  Offset _planetPos(Offset center, double canvasR, double frac, double lonDeg) {
    final lon = lonDeg * pi / 180;
    final orbR = canvasR * frac;
    return Offset(
      center.dx + orbR * cos(lon),
      center.dy + orbR * sin(lon) * _tilt,
    );
  }

  // z > 0 = in front of plane (draw last); z < 0 = behind (draw first)
  double _zDepth(double frac, double lonDeg) =>
      sin(lonDeg * pi / 180) * frac;

  void _drawPlanets(Canvas canvas, Offset c, double r) {
    final relevant = bodies
        .where((b) => _orbFrac.containsKey(b.id))
        .toList()
      ..sort((a, b) => _zDepth(_orbFrac[a.id]!, a.eclipticLongitude)
          .compareTo(_zDepth(_orbFrac[b.id]!, b.eclipticLongitude)));

    for (final body in relevant) {
      final frac = _orbFrac[body.id]!;
      final color = _planetColors[body.id] ?? Colors.white;
      final pRadius = _planetRadius[body.id] ?? 5.0;
      final glyph = _planetGlyphs[body.id] ?? '★';
      final pos = _planetPos(c, r, frac, body.eclipticLongitude);
      final zDepth = _zDepth(frac, body.eclipticLongitude);

      // Scale slightly with depth (farther = slightly smaller)
      final depthScale = 0.85 + 0.15 * (zDepth + 1) / 2;
      final pr = pRadius * depthScale;

      if (body.id == CelestialBodyId.saturn) {
        _drawSaturnRingBack(canvas, pos, pr);
      }

      // Glow + planet body
      canvas
        ..drawCircle(
          pos,
          pr * 2.8,
          Paint()
            ..color = color.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        )
        ..drawCircle(
          pos,
          pr,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.5, -0.5),
              colors: [
                Color.lerp(color, Colors.white, 0.55)!,
                color,
                Color.lerp(color, Colors.black, 0.45)!,
              ],
              stops: const [0.0, 0.55, 1.0],
            ).createShader(Rect.fromCircle(center: pos, radius: pr)),
        );

      if (body.id == CelestialBodyId.saturn) {
        _drawSaturnRingFront(canvas, pos, pr);
      }

      // Glyph
      final glyphAlpha = 0.75 + 0.25 * (zDepth + 1) / 2;
      _drawText(
        canvas,
        pos + Offset(0, pr + 9),
        glyph,
        TextStyle(
          fontSize: 10,
          color: color.withValues(alpha: glyphAlpha),
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  // Saturn ring — back half (behind planet)
  void _drawSaturnRingBack(Canvas canvas, Offset pos, double pr) {
    final ringPaint = Paint()
      ..color = const Color(0xFFE5D08A).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    final rect = Rect.fromCenter(
      center: pos,
      width: pr * 3.4,
      height: pr * 1.0,
    );
    // back half: pi → 2*pi
    canvas.drawArc(rect, pi, pi, false, ringPaint);
  }

  // Saturn ring — front half (in front of planet)
  void _drawSaturnRingFront(Canvas canvas, Offset pos, double pr) {
    final ringPaint = Paint()
      ..color = const Color(0xFFE5D08A).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    final rect = Rect.fromCenter(
      center: pos,
      width: pr * 3.4,
      height: pr * 1.0,
    );
    // front half: 0 → pi
    canvas.drawArc(rect, 0, pi, false, ringPaint);
  }

  void _drawText(Canvas canvas, Offset center, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_SolarSystemPainter old) => old.bodies != bodies;
}
