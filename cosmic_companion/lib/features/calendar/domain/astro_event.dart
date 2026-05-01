import 'package:cosmic_companion/data/models/celestial_body.dart';
import 'package:cosmic_companion/data/models/moon_phase.dart';

enum AstroEventType {
  moonPhase,
  moonIngress,
  planetaryIngress,
}

class AstroEvent {
  const AstroEvent({
    required this.utc,
    required this.type,
    required this.body,
    this.moonPhase,
    this.ingressSign,
  });

  final DateTime utc;
  final AstroEventType type;
  final CelestialBodyId body;

  // moonPhase events
  final MoonPhaseName? moonPhase;

  // ingress events
  final ZodiacSign? ingressSign;
}
