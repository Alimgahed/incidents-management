import 'dart:math' as math;

/// Optimized Haversine Formula for fast distance calculation.
class GeoHaversine {
  static const double _earthRadiusKm = 6371.0;

  /// Calculates the distance between two coordinates in meters.
  /// Extremely optimized to avoid unnecessary object allocations.
  static double distanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return _earthRadiusKm * c * 1000.0;
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
}
