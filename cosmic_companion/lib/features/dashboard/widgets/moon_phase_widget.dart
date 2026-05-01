import 'dart:math';

import 'package:flutter/material.dart';

/// Renders a to-scale moon phase based on [phaseAngle] (0–360°).
///
/// 0° = new moon, 90° = first quarter, 180° = full moon, 270° = last quarter.
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

  static const _darkColor = Color(0xFF1A1A2E);
  static const _litColor = Color(0xFFEEE8AA);
  static const _glowColor = Color(0x22EEDD88);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final a = phaseAngle * pi / 180.0;
    final cosA = cos(a);

    // ── Outer glow ────────────────────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = _glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(c, r + 2, glowPaint);

    // ── Clip all subsequent drawing to the moon disk ──────────────────────────
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));

    // 1. Base: dark side covers the whole disk
    canvas.drawPaint(Paint()..color = _darkColor);

    // 2. Lit half-circle (right side for waxing, left for waning)
    final isWaxing = phaseAngle <= 180.0;
    final litStartAngle = isWaxing ? -pi / 2 : pi / 2;
    final litHalfPath = Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(
        Rect.fromCircle(center: c, radius: r),
        litStartAngle,
        pi,
        false,
      )
      ..close();
    canvas.drawPath(litHalfPath, Paint()..color = _litColor);

    // 3. Terminator ellipse modifies the lit region
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
        // Crescent: remove inner portion of lit half using dark paint
        final litSideRect = isWaxing
            ? Rect.fromLTRB(c.dx, c.dy - pad, c.dx + pad, c.dy + pad)
            : Rect.fromLTRB(c.dx - pad, c.dy - pad, c.dx, c.dy + pad);
        canvas.save();
        canvas.clipRect(litSideRect);
        canvas.clipPath(Path()..addOval(termRect));
        canvas.drawPaint(Paint()..color = _darkColor);
        canvas.restore();
      } else {
        // Gibbous: fill dark side with lit paint past the half-circle
        final darkSideRect = isWaxing
            ? Rect.fromLTRB(c.dx - pad, c.dy - pad, c.dx, c.dy + pad)
            : Rect.fromLTRB(c.dx, c.dy - pad, c.dx + pad, c.dy + pad);
        canvas.save();
        canvas.clipRect(darkSideRect);
        canvas.clipPath(Path()..addOval(termRect));
        canvas.drawPaint(Paint()..color = _litColor);
        canvas.restore();
      }
    }

    canvas.restore(); // end moon disk clip

    // ── Border ────────────────────────────────────────────────────────────────
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_MoonPhasePainter old) => old.phaseAngle != phaseAngle;
}
