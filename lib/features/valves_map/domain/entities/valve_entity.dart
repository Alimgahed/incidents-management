import 'package:equatable/equatable.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Valve Entity representing the core domain object for a valve.
/// Uses Equatable for performance optimization in Blocs/Selectors.
/// Implements ClusterItem to be compatible with google_maps_cluster_manager.
class ValveEntity extends Equatable with ClusterItem {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int status;
  final String zone;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  ValveEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.zone,
    required this.lastUpdated,
    this.metadata = const {},
  });

  @override
  LatLng get location => LatLng(latitude, longitude);

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        status,
        zone,
        lastUpdated,
        metadata,
      ];
}
