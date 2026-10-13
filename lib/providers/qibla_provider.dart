import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/qibla_service.dart';
import 'location_provider.dart';

/// Provider for [QiblaService].
final qiblaServiceProvider = Provider<QiblaService>((ref) {
  return const QiblaService();
});

/// The current Qibla direction, derived from the active location.
final qiblaDirectionProvider = Provider<QiblaDirection>((ref) {
  final loc = ref.watch(currentLocationProvider);
  final service = ref.watch(qiblaServiceProvider);
  return service.calculate(
    latitude: loc.latitude,
    longitude: loc.longitude,
  );
});
