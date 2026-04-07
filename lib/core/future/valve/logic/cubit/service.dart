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

  /// Returns the nearest valve within the alarm radius, or null if none.
  ProximityResult? checkProximity({
    required double userLat,
    required double userLng,
    required List<ValveModel> valves,
  }) {
    ProximityResult? nearest;

    for (final valve in valves) {
      final dist = _haversineMeters(
        userLat, userLng,
        valve.latitude, valve.longitude,
      );
      if (dist <= _alarmRadiusMeters) {
        if (nearest == null || dist < nearest.distanceMeters) {
          nearest = ProximityResult(valve: valve, distanceMeters: dist);
        }
      }
    }

    return nearest;
  }

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