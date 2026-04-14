// lib/services/proximity_service.dart

import 'dart:math';

import 'package:incidents_managment/core/future/valve/data/model/valve.dart';


class ProximityResult {
  final ValveModel valve;
  final double distanceMeters;

  const ProximityResult({required this.valve, required this.distanceMeters});
}

class ProximityService {
  static const double _alarmRadiusMeters = 100.0;

  /// Returns the nearest valve and its distance.
  ProximityResult checkProximity({
    required double userLat,
    required double userLng,
    required List<ValveModel> valves,
  }) {
    ValveModel? nearestValve;
    double minDistance = double.infinity;

    for (final valve in valves) {
      // Fast bypass: Simple lat/lng bounding box check before expensive trig.
      // We only skip if DISTANCE is definitely > 1000m for this sweep, 
      // unless we want to always know the absolute nearest.
      // Let's use a larger bypass (0.01 degrees ~= 1km) to still catch nearby ones for adaptive GPS.
      final latDiff = (userLat - valve.latitude).abs();
      final lngDiff = (userLng - valve.longitude).abs();
      if (latDiff > 0.1 || lngDiff > 0.1) continue; // Skip if > 10km away

      final dist = _haversineMeters(
        userLat, userLng,
        valve.latitude, valve.longitude,
      );
      
      if (dist < minDistance) {
        minDistance = dist;
        nearestValve = valve;
      }
    }

    // fallback to first valve if none found within 10km (though rare)
    if (nearestValve == null && valves.isNotEmpty) {
      nearestValve = valves.first;
      minDistance = _haversineMeters(userLat, userLng, nearestValve.latitude, nearestValve.longitude);
    }

    return ProximityResult(
      valve: nearestValve ?? valves.first,
      distanceMeters: minDistance,
    );
  }

  bool isWithinAlarmRadius(double distance) => distance <= _alarmRadiusMeters;

  /// Haversine formula — returns distance in metres between two WGS-84 coords.
  double _haversineMeters(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double r = 6371000; // Earth radius in metres
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRad(double degrees) => degrees * pi / 180;
}