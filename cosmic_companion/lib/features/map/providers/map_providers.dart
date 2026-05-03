import 'package:cosmic_companion/features/dashboard/providers/dashboard_providers.dart';
import 'package:cosmic_companion/features/map/domain/bortle_classifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _classifier = BortleClassifier();

final bortleLevelProvider = FutureProvider.autoDispose<BortleLevel>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  return _classifier.estimate(location.latitude, location.longitude);
});
