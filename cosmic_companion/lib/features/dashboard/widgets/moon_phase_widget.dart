import 'dart:math';

import 'package:flutter/material.dart';

/// Renders a realistic moon phase with 3-D sphere shading and lunar maria.
///
/// [phaseAngle]: 0° = new moon, 90° = first quarter, 180° = full moon,
///               270° = last quarter.
class MoonPhaseWidget extends StatelessWidget {
  const MoonPhaseWidget({
    required this.phaseAngle,
    required this.illuminationPercent,
    this.size = 72,
    super.key,
  });

  final double phaseAngle;
  final double illuminationPercent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _MoonPhasePainter(phaseAngle: phaseAngle),
        ),
        const SizedBox(height: 4),
        Text(
          '${illuminationPercent.round()}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFEEE8AA),
              ),
        ),
      ],
    );
  }
}

class _MoonPhasePainter extends CustomPainter {
  _MoonPhasePainter({required this.phaseAngle});

  final double phaseAngle;

  static const _darkSide = Color(0xFF060B18);
  static const _litBase = Color(0xFFCEC4A0);
  static const _litBright = Color(0xFFF0E8C8);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final a = phaseAngle * pi / 180.0;
    final cosA = cos(a);
    final isWaxing = phaseAngle <= 180.0;
    final moonRect = Rect.fromCircle(center: c, radius: r);

    // ── Outer glow ─────────────────────────────────────────────────────
    canvas.drawCircle(
      c,
      r + 7,
      Paint()
        ..color = const Color(0x18EEE8AA)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));

    // 1. Dark base
    canvas.drawPaint(Paint()..color = _darkSide);

    // 2. Lit half — warm gradient from terminator to limb
    final litGrad = LinearGradient(
      begin: isWaxing ? Alignment.centerRight : Alignment.centerLeft,
      end: isWaxing ? Alignment.centerLeft : Alignment.centerRight,
      colors: const [_litBright, _litBase],
      stops: const [0.0, 0.8],
    ).createShader(moonRect);

    final litStartAngle = isWaxing ? -pi / 2 : pi / 2;
    final litPath = Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(moonRect, litStartAngle, pi, false)
      ..close();
    canvas.drawPath(litPath, Paint()..shader = litGrad);

    // 3. Terminator ellipse
    final termR = cosA.abs() * r;
    if (termR > 0.5) {
      final termRect = Rect.fromCenter(
        center: c,
        width: termR * 2,
        height: r * 2,
      );
      final pad = r + 2;
      final terminatorOnLitSide = cosA > 0;

      if (terminatorOnLitSide) {
        // Crescent: erase inner lit area
        final litSideRect = isWaxing
            ? Rect.fromLTRB(c.dx, c.dy - pad, c.dx + pad, c.dy + pad)
            : Rect.fromLTRB(c.dx - pad, c.dy - pad, c.dx, c.dy + pad);
        canvas.save();
        canvas.clipRect(litSideRect);
        canvas.clipPath(Path()..addOval(termRect));
        canvas.drawPaint(Paint()..color = _darkSide);
        canvas.restore();
      } else {
        // Gibbous: extend lit area into dark half
        final darkSideRect = isWaxing
            ? Rect.fromLTRB(c.dx - pad, c.dy - pad, c.dx, c.dy + pad)
            : Rect.fromLTRB(c.dx, c.dy - pad, c.dx + pad, c.dy + pad);
        canvas.save();
        canvas.clipRect(darkSideRect);
        canvas.clipPath(Path()..addOval(termRect));
        canvas.drawPaint(Paint()..shader = litGrad);
        canvas.restore();
      }
    }

    // 4. Soft terminator haze
    if (termR > 2) {
      final hazeRect = Rect.fromCenter(
        center: c,
        width: termR * 2,
        height: r * 2,
      );
      final hazeHalf = 10.0.clamp(2.0, r * 0.15);
      canvas.drawOval(
        hazeRect,
        Paint()
          ..color = _darkSide.withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, hazeHalf),
      );
    }

    // 5. Lunar maria — simplified dark patches for texture
    _drawMaria(canvas, c, r);

    // 6. 3-D sphere shading: directional highlight + limb darkening
    final hx = isWaxing ? 0.30 : -0.30;
    final sphereGrad = RadialGradient(
      center: Alignment(hx, -0.28),
      radius: 0.88,
      colors: const [
        Color(0x38FFFFFF), // specular highlight
        Color(0x00000000), // transparent mid
        Color(0x72000000), // limb darkening
      ],
      stops: const [0.0, 0.38, 1.0],
    ).createShader(moonRect);
    canvas.drawCircle(c, r, Paint()..shader = sphereGrad);

    // 7. Earthshine — faint blue wash on dark side
    canvas.drawCircle(c, r, Paint()..color = const Color(0x0A3355AA));

    canvas.restore(); // end moon disk clip

    // 8. Thin rim
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0x28FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  void _drawMaria(Canvas canvas, Offset c, double r) {
    final p = Paint()..color = const Color(0x1E000000);
    // Mare Serenitatis + Tranquillitatis
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(r * 0.10, -r * 0.08),
          width: r * 0.50,
          height: r * 0.40),
      p,
    );
    // Mare Imbrium
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(-r * 0.18, -r * 0.24),
          width: r * 0.34,
          height: r * 0.30),
      p,
    );
    // Oceanus Procellarum
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(-r * 0.28, r * 0.04),
          width: r * 0.26,
          height: r * 0.46),
      p,
    );
    // Mare Nubium
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(-r * 0.08, r * 0.36),
          width: r * 0.28,
          height: r * 0.20),
      p,
    );
    // Mare Crisium
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(r * 0.38, -r * 0.20),
          width: r * 0.16,
          height: r * 0.13),
      p,
    );
  }

  @override
  bool shouldRepaint(_MoonPhasePainter old) => old.phaseAngle != phaseAngle;
}
