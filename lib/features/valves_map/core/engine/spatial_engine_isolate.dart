import 'package:flutter/foundation.dart';
import 'package:incidents_managment/features/valves_map/core/utils/geo_haversine.dart';
import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';

/// Request payload for the isolate.
class SpatialEngineRequest {
  final double userLat;
  final double userLng;
  final List<ValveEntity> valves;
  final int maxResults;

  const SpatialEngineRequest({
    required this.userLat,
    required this.userLng,
    required this.valves,
    this.maxResults = 5,
  });
}

/// Result payload from the isolate.
class ValveDistanceResult {
  final ValveEntity valve;
  final double distanceInMeters;

  const ValveDistanceResult({
    required this.valve,
    required this.distanceInMeters,
  });
}

/// Engine to calculate closest valves in a background isolate to prevent UI freezing.
class SpatialEngineIsolate {
  /// Entry point for finding the nearest valves.
  static Future<List<ValveDistanceResult>> findNearestValves(
    SpatialEngineRequest request,
  ) async {
    // Spawns an isolate to process the list without freezing the UI thread
    return await compute(_calculateDistances, request);
  }

  /// The heavy function executed inside the isolate.
  static List<ValveDistanceResult> _calculateDistances(
    SpatialEngineRequest request,
  ) {
    if (request.valves.isEmpty) return [];

    final results = <ValveDistanceResult>[];

    for (final valve in request.valves) {
      final distance = GeoHaversine.distanceInMeters(
        request.userLat,
        request.userLng,
        valve.latitude,
        valve.longitude,
      );
      results.add(ValveDistanceResult(valve: valve, distanceInMeters: distance));
    }

    // Sort by distance (ascending)
    results.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

    // Return only the top nearest valves to save memory when passing back to main thread
    if (results.length > request.maxResults) {
      return results.sublist(0, request.maxResults);
    }
    return results;
  }
}
