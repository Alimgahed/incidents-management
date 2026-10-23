// lib/services/proximity_service.dart

import 'dart:math';

import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

class ProximityResult {
  final ValveModel valve;
  final double distanceMeters;
  final bool isCritical;

  const ProximityResult({
    required this.valve,
    required this.distanceMeters,
    this.isCritical = false,
  });
}

class ProximityService {
  static const double defaultAlarmRadiusMeters = 50.0;
  static const double criticalAlarmRadiusMeters = 0.5; // Half a meter (0.5m)

  final double alarmRadiusMeters;

  const ProximityService({this.alarmRadiusMeters = defaultAlarmRadiusMeters});

  /// Returns the nearest valve and its distance.
  ProximityResult? checkProximity({
    required double userLat,
    required double userLng,
    required List<ValveModel> valves,
  }) {
    final validValves = valves
        .where((v) => v.lat != null && v.long != null && v.lat != 0 && v.long != 0)
        .toList();
    if (validValves.isEmpty) return null;

    ValveModel? nearestValve;
    double minDistance = double.infinity;

    for (final valve in validValves) {
      final latDiff = (userLat - valve.lat!).abs();
      final lngDiff = (userLng - valve.long!).abs();
      if (latDiff > 0.1 || lngDiff > 0.1) continue; // Skip if > 10km away

      final dist = _haversineMeters(
        userLat,
        userLng,
        valve.lat!,
        valve.long!,
      );

      if (dist < minDistance) {
        minDistance = dist;
        nearestValve = valve;
      }
    }

    // fallback if all valves were > 10km away
    if (nearestValve == null && validValves.isNotEmpty) {
      nearestValve = validValves.first;
      minDistance = _haversineMeters(
        userLat,
        userLng,
        nearestValve.lat!,
        nearestValve.long!,
      );
    }

    if (nearestValve == null) return null;

    final isCritical = minDistance <= criticalAlarmRadiusMeters;

    return ProximityResult(
      valve: nearestValve,
      distanceMeters: minDistance,
      isCritical: isCritical,
    );
  }

  bool isWithinAlarmRadius(double distance) => distance <= alarmRadiusMeters;

  bool isWithinCriticalRadius(double distance) => distance <= criticalAlarmRadiusMeters;

  /// Haversine formula — returns distance in metres between two WGS-84 coords.
  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371000; // Earth radius in metres
    final double dLat = _toRad(lat2 - lat1);
    final double dLon = _toRad(lon2 - lon1);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRad(double degrees) => degrees * pi / 180;
}
