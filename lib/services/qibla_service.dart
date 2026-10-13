import 'dart:math' as math;

/// Result of a Qibla calculation.
class QiblaDirection {
  /// Bearing from the user's location to the Kaaba, in degrees
  /// (0 = true North, 90 = East, 180 = South, 270 = West).
  final double bearing;

  /// Distance to the Kaaba in kilometers.
  final double distanceKm;

  const QiblaDirection({
    required this.bearing,
    required this.distanceKm,
  });
}

/// Service that computes the Qibla direction from any coordinate.
///
/// The Kaaba is located at:
///   Latitude  : 21.4225° N
///   Longitude : 39.8262° E
class QiblaService {
  const QiblaService();

  /// Kaaba coordinates.
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// Compute the Qibla direction for the given coordinates.
  QiblaDirection calculate({
    required double latitude,
    required double longitude,
  }) {
    final bearing = _bearingToKaaba(latitude, longitude);
    final distance = _distanceKm(latitude, longitude);
    return QiblaDirection(bearing: bearing, distanceKm: distance);
  }

  // ─────────────────────────────────────────────
  // INTERNAL
  // ─────────────────────────────────────────────

  /// Great-circle initial bearing to the Kaaba, in degrees [0, 360).
  double _bearingToKaaba(double lat, double lng) {
    final phi1 = _toRadians(lat);
    final phi2 = _toRadians(kaabaLat);
    final deltaLambda = _toRadians(kaabaLng - lng);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    final bearing = (_toDegrees(theta) + 360) % 360;
    return bearing;
  }

  /// Haversine distance in kilometers.
  double _distanceKm(double lat, double lng) {
    const earthRadiusKm = 6371.0;

    final phi1 = _toRadians(lat);
    final phi2 = _toRadians(kaabaLat);
    final dPhi = _toRadians(kaabaLat - lat);
    final dLambda = _toRadians(kaabaLng - lng);

    final a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2) *
            math.sin(dLambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double deg) => deg * math.pi / 180.0;
  double _toDegrees(double rad) => rad * 180.0 / math.pi;
}
