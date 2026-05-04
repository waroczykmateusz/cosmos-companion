enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  static MoonPhaseName fromAngle(double angle) {
    final a = angle % 360;
    if (a < 22.5 || a >= 337.5) return MoonPhaseName.newMoon;
    if (a < 67.5) return MoonPhaseName.waxingCrescent;
    if (a < 112.5) return MoonPhaseName.firstQuarter;
    if (a < 157.5) return MoonPhaseName.waxingGibbous;
    if (a < 202.5) return MoonPhaseName.fullMoon;
    if (a < 247.5) return MoonPhaseName.waningGibbous;
    if (a < 292.5) return MoonPhaseName.lastQuarter;
    return MoonPhaseName.waningCrescent;
  }
}

class MoonPhase {
  const MoonPhase({
    required this.name,
    required this.illuminationPercent,
    required this.phaseAngle,
    required this.epoch,
  });

  final MoonPhaseName name;
  final double illuminationPercent; // 0..100
  final double phaseAngle;          // 0..360°
  final DateTime epoch;
}
