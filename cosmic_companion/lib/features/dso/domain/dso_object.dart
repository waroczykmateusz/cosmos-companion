enum DsoType {
  galaxy,
  openCluster,
  globularCluster,
  emissionNebula,
  reflectionNebula,
  darkNebula,
  planetaryNebula,
  supernovaRemnant,
}

enum ObservingSeason { spring, summer, autumn, winter }

class DsoObject {
  const DsoObject({
    required this.id,
    required this.namePl,
    required this.nameEn,
    required this.catalogName,
    required this.type,
    required this.raHours,
    required this.decDeg,
    required this.magnitude,
    required this.angularSizeArcmin,
    required this.bestSeason,
  });

  final String id;
  final String namePl;
  final String nameEn;
  final String catalogName;
  final DsoType type;
  final double raHours;
  final double decDeg;
  final double magnitude;
  final double angularSizeArcmin;
  final ObservingSeason bestSeason;
}
