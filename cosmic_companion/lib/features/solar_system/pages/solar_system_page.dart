import 'dart:math';

import 'package:cosmic_companion/core/localization/app_localizations.dart';
import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/dashboard/widgets/body_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Orbital constants ─────────────────────────────────────────────────────────

// Sidereal periods [days]
const _periods = {
  CelestialBodyId.mercury: 87.97,
  CelestialBodyId.venus: 224.70,
  CelestialBodyId.mars: 686.97,
  CelestialBodyId.jupiter: 4332.59,
  CelestialBodyId.saturn: 10759.22,
  CelestialBodyId.uranus: 30688.5,
  CelestialBodyId.neptune: 60182.0,
  CelestialBodyId.pluto: 90560.0,
};

const _moonPeriod = 27.32; // days

// Visual orbital radii as fraction of canvas half-size (log-scale)
const _orbFrac = {
  CelestialBodyId.mercury: 0.13,
  CelestialBodyId.venus: 0.20,
  CelestialBodyId.mars: 0.30,
  CelestialBodyId.jupiter: 0.45,
  CelestialBodyId.saturn: 0.59,
  CelestialBodyId.uranus: 0.73,
  CelestialBodyId.neptune: 0.86,
  CelestialBodyId.pluto: 0.93,
};

const _earthOrbFrac = 0.25;
const _moonOrbitPx = 20.0; // exaggerated Moon orbit radius (px)
const _tilt = 0.42;         // vertical perspective compression

const _planetR = {
  CelestialBodyId.mercury: 4.0,
  CelestialBodyId.venus: 7.0,
  CelestialBodyId.mars: 5.0,
  CelestialBodyId.jupiter: 14.0,
  CelestialBodyId.saturn: 11.0,
  CelestialBodyId.uranus: 8.0,
  CelestialBodyId.neptune: 8.0,
  CelestialBodyId.pluto: 3.0,
};

const _planetColors = {
  CelestialBodyId.mercury: Color(0xFFAAAAAA),
  CelestialBodyId.venus: Color(0xFFE8D5A3),
  CelestialBodyId.mars: Color(0xFFE64A19),
  CelestialBodyId.jupiter: Color(0xFFCBB89A),
  CelestialBodyId.saturn: Color(0xFFE5D08A),
  CelestialBodyId.uranus: Color(0xFF80DEEA),
  CelestialBodyId.neptune: Color(0xFF4F6FBB),
  CelestialBodyId.pluto: Color(0xFF9E8070),
};

const _planetGlyphs = {
  CelestialBodyId.mercury: '☿',
  CelestialBodyId.venus: '♀',
  CelestialBodyId.mars: '♂',
  CelestialBodyId.jupiter: '♃',
  CelestialBodyId.saturn: '♄',
  CelestialBodyId.uranus: '♅',
  CelestialBodyId.neptune: '♆',
  CelestialBodyId.pluto: '♇',
};

const _planetNames = {
  CelestialBodyId.mercury: 'Merkury',
  CelestialBodyId.venus: 'Wenus',
  CelestialBodyId.mars: 'Mars',
  CelestialBodyId.jupiter: 'Jowisz',
  CelestialBodyId.saturn: 'Saturn',
  CelestialBodyId.uranus: 'Uran',
  CelestialBodyId.neptune: 'Neptun',
  CelestialBodyId.pluto: 'Pluton',
};

// ── Helpers ───────────────────────────────────────────────────────────────────

Offset _projPos(Offset center, double canvasR, double frac, double lonDeg) {
  final lon = lonDeg * pi / 180;
  final orbR = canvasR * frac;
  return Offset(center.dx + orbR * cos(lon), center.dy + orbR * sin(lon) * _tilt);
}

double _zDepth(double frac, double lonDeg) => sin(lonDeg * pi / 180) * frac;

// ── Page ─────────────────────────────────────────────────────────────────────

class SolarSystemPage extends ConsumerStatefulWidget {
  const SolarSystemPage({super.key});

  @override
  ConsumerState<SolarSystemPage> createState() => _SolarSystemPageState();
}

class _SolarSystemPageState extends ConsumerState<SolarSystemPage>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ticker;
  final TransformationController _transformCtrl = TransformationController();

  bool _initialized = false;
  List<CelestialBody> _bodies = [];

  final Map<CelestialBodyId, double> _lons = {}; // animated longitudes
  double _sunLon = 0;
  double _moonLon = 0;

  double _speed = 10; // simulation days per real second
  bool _playing = true;
  DateTime _lastTick = DateTime.now();

  // Canvas-space positions (updated each build, used for hit-testing)
  final Map<CelestialBodyId, Offset> _positions = {};
  Offset? _earthPos;
  Offset? _moonPos;

  // Selection
  CelestialBodyId? _selectedPlanet;
  bool _earthSelected = false;
  bool _moonSelected = false;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..repeat()
      ..addListener(_onTick);
  }

  void _onTick() {
    if (!_playing || !_initialized) return;
    final now = DateTime.now();
    final elapsedSec = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    final delta = elapsedSec * _speed; // days this frame
    setState(() {
      for (final entry in _periods.entries) {
        _lons[entry.key] =
            (_lons[entry.key]! + 360.0 / entry.value * delta) % 360;
      }
      _sunLon = (_sunLon + 360.0 / 365.25 * delta) % 360;
      _moonLon = (_moonLon + 360.0 / _moonPeriod * delta) % 360;
    });
  }

  void _initFromBodies(List<CelestialBody> bodies) {
    if (_initialized) return;
    _initialized = true;
    _bodies = bodies;
    _lastTick = DateTime.now();

    for (final b in bodies) {
      if (_periods.containsKey(b.id)) _lons[b.id] = b.eclipticLongitude;
    }
    _sunLon = bodies
        .firstWhere((b) => b.id == CelestialBodyId.sun,
            orElse: () => bodies.first)
        .eclipticLongitude;
    _moonLon = bodies
        .firstWhere((b) => b.id == CelestialBodyId.moon,
            orElse: () => bodies.first)
        .eclipticLongitude;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _transformCtrl.dispose();
    super.dispose();
  }

  // Compute canvas-space positions from current animation state.
  void _computePositions(Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);

    for (final entry in _lons.entries) {
      final frac = _orbFrac[entry.key];
      if (frac != null) {
        _positions[entry.key] = _projPos(c, r, frac, entry.value);
      }
    }
    final earthLon = (_sunLon + 180) % 360;
    _earthPos = _projPos(c, r, _earthOrbFrac, earthLon);

    final mRad = _moonLon * pi / 180;
    _moonPos = _earthPos! +
        Offset(_moonOrbitPx * cos(mRad), _moonOrbitPx * sin(mRad) * _tilt);
  }

  void _handleTap(TapUpDetails details) {
    // Convert screen position → canvas coordinates via inverse transform.
    final screenPos = details.localPosition;
    final mat = _transformCtrl.value.clone()..invert();
    final s = mat.storage;
    final cx = s[0] * screenPos.dx + s[4] * screenPos.dy + s[12];
    final cy = s[1] * screenPos.dx + s[5] * screenPos.dy + s[13];
    final canvasPos = Offset(cx, cy);

    // Priority: Moon → Earth → Planets
    if (_moonPos != null && (_moonPos! - canvasPos).distance < 20) {
      setState(() {
        _selectedPlanet = null;
        _earthSelected = false;
        _moonSelected = true;
      });
      _showInfo(CelestialBodyId.moon);
      return;
    }
    if (_earthPos != null && (_earthPos! - canvasPos).distance < 22) {
      setState(() {
        _selectedPlanet = null;
        _earthSelected = true;
        _moonSelected = false;
      });
      return; // Earth has no CelestialBody from provider — just highlight
    }

    CelestialBodyId? closest;
    var closestD = 30.0;
    for (final e in _positions.entries) {
      final d = (e.value - canvasPos).distance;
      if (d < closestD) {
        closestD = d;
        closest = e.key;
      }
    }
    setState(() {
      _selectedPlanet = closest;
      _earthSelected = false;
      _moonSelected = false;
    });
    if (closest != null) _showInfo(closest);
  }

  void _showInfo(CelestialBodyId id) {
    final body = _bodies.firstWhere(
      (b) => b.id == id,
      orElse: () => _bodies.first,
    );
    showBodyDetailSheet(context, body);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wheelAsync = ref.watch(horoscopeWheelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF07091A),
        foregroundColor: Colors.white70,
        title: Text(
          l10n.solarSystemTitle,
          style: const TextStyle(color: Colors.white, letterSpacing: 0.5),
        ),
        actions: [
          // Speed selector
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed, color: Colors.white70),
            tooltip: 'Prędkość symulacji',
            onSelected: (v) {
              setState(() {
                _speed = v;
                _lastTick = DateTime.now();
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 1,   child: Text('1 dzień / s')),
              PopupMenuItem(value: 10,  child: Text('10 dni / s')),
              PopupMenuItem(value: 30,  child: Text('30 dni / s')),
              PopupMenuItem(value: 365, child: Text('1 rok / s')),
            ],
          ),
          // Play / Pause
          IconButton(
            icon: Icon(
              _playing ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: Colors.white70,
            ),
            onPressed: () => setState(() {
              _playing = !_playing;
              _lastTick = DateTime.now();
            }),
          ),
        ],
      ),
      body: wheelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.white)),
        ),
        data: (bodies) {
          _initFromBodies(bodies);
          return _buildViewer();
        },
      ),
    );
  }

  Widget _buildViewer() {
    return GestureDetector(
      onTapUp: _handleTap,
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        minScale: 0.35,
        maxScale: 8,
        child: LayoutBuilder(
          builder: (_, constraints) {
            final size = constraints.biggest;
            _computePositions(size);
            return CustomPaint(
              size: size,
              painter: _SolarSystemPainter(
                lons: Map.from(_lons),
                sunLon: _sunLon,
                moonLon: _moonLon,
                selectedPlanet: _selectedPlanet,
                earthSelected: _earthSelected,
                moonSelected: _moonSelected,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _SolarSystemPainter extends CustomPainter {
  _SolarSystemPainter({
    required this.lons,
    required this.sunLon,
    required this.moonLon,
    required this.selectedPlanet,
    required this.earthSelected,
    required this.moonSelected,
  });

  final Map<CelestialBodyId, double> lons;
  final double sunLon;
  final double moonLon;
  final CelestialBodyId? selectedPlanet;
  final bool earthSelected;
  final bool moonSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);

    _drawBg(canvas, size, c, r);
    _drawAsteroidBelt(canvas, c, r);
    _drawKuiperBelt(canvas, c, r);
    _drawAllOrbits(canvas, c, r);
    _drawSun(canvas, c, r);
    _drawEarthSystem(canvas, c, r);
    _drawPlanets(canvas, c, r);
  }

  // ── Background ────────────────────────────────────────────────────────────

  void _drawBg(Canvas canvas, Size size, Offset c, double r) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF0E1535), Color(0xFF020510)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    final rng = Random(2025);
    for (var i = 0; i < 350; i++) {
      final sx = rng.nextDouble() * size.width;
      final sy = rng.nextDouble() * size.height;
      final sr = rng.nextDouble() * 1.4 + 0.2;
      final alpha = rng.nextDouble() * 0.65 + 0.2;
      canvas.drawCircle(
        Offset(sx, sy),
        sr,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  // ── Belts ─────────────────────────────────────────────────────────────────

  void _drawAsteroidBelt(Canvas canvas, Offset c, double r) {
    final rng = Random(42);
    for (var i = 0; i < 280; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = r * (0.35 + rng.nextDouble() * 0.08);
      canvas.drawCircle(
        Offset(c.dx + dist * cos(angle), c.dy + dist * sin(angle) * _tilt),
        rng.nextDouble() * 1.3 + 0.3,
        Paint()
          ..color = Colors.grey.withValues(alpha: rng.nextDouble() * 0.35 + 0.1),
      );
    }
    _label(canvas, c + Offset(0, r * 0.40 * _tilt + 8),
        'Pas Asteroid', Colors.grey.shade600, 8);
  }

  void _drawKuiperBelt(Canvas canvas, Offset c, double r) {
    final rng = Random(77);
    for (var i = 0; i < 180; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = r * (0.96 + rng.nextDouble() * 0.06);
      if (dist > r) continue;
      canvas.drawCircle(
        Offset(c.dx + dist * cos(angle), c.dy + dist * sin(angle) * _tilt),
        rng.nextDouble() * 0.9 + 0.2,
        Paint()
          ..color = const Color(0xFF7090AA).withValues(alpha: rng.nextDouble() * 0.3 + 0.08),
      );
    }
  }

  // ── Orbits ────────────────────────────────────────────────────────────────

  void _drawAllOrbits(Canvas canvas, Offset c, double r) {
    _drawOrbit(canvas, c, r * _earthOrbFrac, highlighted: earthSelected);
    for (final entry in _orbFrac.entries) {
      _drawOrbit(
        canvas, c, r * entry.value,
        highlighted: selectedPlanet == entry.key,
      );
    }
  }

  void _drawOrbit(Canvas canvas, Offset c, double orbR,
      {bool highlighted = false}) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: orbR * 2, height: orbR * 2 * _tilt),
      Paint()
        ..color = highlighted
            ? Colors.white.withValues(alpha: 0.50)
            : Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlighted ? 1.0 : 0.5,
    );
  }

  // ── Sun ───────────────────────────────────────────────────────────────────

  void _drawSun(Canvas canvas, Offset c, double r) {
    final sR = r * 0.055;
    for (final (bR, alpha) in [
      (sR * 5.5, 0.018), (sR * 4.0, 0.035), (sR * 2.8, 0.08),
      (sR * 1.8, 0.18),
    ]) {
      canvas.drawCircle(
        c, bR,
        Paint()
          ..color = const Color(0xFFFFDD44).withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sR * 2.5),
      );
    }
    canvas.drawCircle(
      c, sR,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFFFCC), Color(0xFFFFBB00)],
        ).createShader(Rect.fromCircle(center: c, radius: sR)),
    );
    _label(canvas, c + Offset(0, sR + 14), '☉  Słońce',
        const Color(0xFFFFDD88), 10);
  }

  // ── Earth + Moon ──────────────────────────────────────────────────────────

  void _drawEarthSystem(Canvas canvas, Offset c, double r) {
    final earthLon = (sunLon + 180) % 360;
    final ep = _projPos(c, r, _earthOrbFrac, earthLon);

    // Moon orbit ring (tiny)
    canvas.drawOval(
      Rect.fromCenter(
          center: ep, width: _moonOrbitPx * 2, height: _moonOrbitPx * 2 * _tilt),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4,
    );

    // Moon
    final mRad = moonLon * pi / 180;
    final mp = ep +
        Offset(_moonOrbitPx * cos(mRad), _moonOrbitPx * sin(mRad) * _tilt);
    const moonR = 2.8;

    canvas.drawCircle(mp, moonR,
        Paint()..color = const Color(0xFFCCCCCC));
    if (moonSelected) _selectionRing(canvas, mp, moonR + 4);
    _label(canvas, mp + const Offset(0, moonR + 8), '☽', Colors.grey.shade400, 10);

    // Earth glow
    const earthR = 6.5;
    const earthColor = Color(0xFF4FC3F7);
    canvas
      ..drawCircle(
        ep, earthR * 2.8,
        Paint()
          ..color = earthColor.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      )
      ..drawCircle(
        ep, earthR,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.4),
            colors: [
              Color.lerp(earthColor, Colors.white, 0.5)!,
              earthColor,
              Color.lerp(earthColor, Colors.black, 0.4)!,
            ],
            stops: const [0, 0.5, 1],
          ).createShader(Rect.fromCircle(center: ep, radius: earthR)),
      );

    if (earthSelected) _selectionRing(canvas, ep, earthR + 6);
    _label(canvas, ep + const Offset(0, earthR + 12), '♁  Ziemia',
        earthColor, 9.5);
  }

  // ── Planets ───────────────────────────────────────────────────────────────

  void _drawPlanets(Canvas canvas, Offset c, double r) {
    final sorted = _orbFrac.keys
        .where(lons.containsKey)
        .toList()
      ..sort((a, b) => _zDepth(_orbFrac[a]!, lons[a]!)
          .compareTo(_zDepth(_orbFrac[b]!, lons[b]!)));

    for (final id in sorted) {
      final lon = lons[id]!;
      final frac = _orbFrac[id]!;
      final color = _planetColors[id] ?? Colors.white;
      final depth = (_zDepth(frac, lon) + 1) / 2; // 0–1
      final pR = (_planetR[id] ?? 5.0) * (0.85 + 0.15 * depth);
      final pos = _projPos(c, r, frac, lon);
      final glyph = _planetGlyphs[id] ?? '★';
      final name = _planetNames[id] ?? '';
      final isSelected = selectedPlanet == id;

      if (id == CelestialBodyId.saturn) _drawSaturnRingBack(canvas, pos, pR);

      canvas
        ..drawCircle(
          pos, pR * 2.8,
          Paint()
            ..color = color.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        )
        ..drawCircle(
          pos, pR,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.4, -0.4),
              colors: [
                Color.lerp(color, Colors.white, 0.55)!,
                color,
                Color.lerp(color, Colors.black, 0.45)!,
              ],
              stops: const [0, 0.5, 1],
            ).createShader(Rect.fromCircle(center: pos, radius: pR)),
        );

      if (id == CelestialBodyId.saturn) _drawSaturnRingFront(canvas, pos, pR);
      if (isSelected) _selectionRing(canvas, pos, pR + 6);

      _label(
        canvas,
        pos + Offset(0, pR + 11),
        '$glyph  $name',
        color.withValues(alpha: 0.88),
        9,
      );
    }
  }

  void _drawSaturnRingBack(Canvas canvas, Offset pos, double pr) {
    canvas.drawArc(
      Rect.fromCenter(center: pos, width: pr * 3.5, height: pr * 1.0),
      pi, pi, false,
      Paint()
        ..color = const Color(0xFFE5D08A).withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  void _drawSaturnRingFront(Canvas canvas, Offset pos, double pr) {
    canvas.drawArc(
      Rect.fromCenter(center: pos, width: pr * 3.5, height: pr * 1.0),
      0, pi, false,
      Paint()
        ..color = const Color(0xFFE5D08A).withValues(alpha: 0.88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  void _selectionRing(Canvas canvas, Offset pos, double r) {
    canvas.drawCircle(
      pos, r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _label(
      Canvas canvas, Offset center, String text, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_SolarSystemPainter old) =>
      old.lons != lons ||
      old.sunLon != sunLon ||
      old.moonLon != moonLon ||
      old.selectedPlanet != selectedPlanet ||
      old.earthSelected != earthSelected ||
      old.moonSelected != moonSelected;
}
