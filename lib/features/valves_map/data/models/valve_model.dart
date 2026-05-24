import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';

/// Valve Model extending ValveEntity to handle JSON serialization.
// ignore: must_be_immutable
class ValveModel extends ValveEntity {
  ValveModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.status,
    required super.zone,
    required super.lastUpdated,
    super.metadata,
  });

  factory ValveModel.fromJson(Map<String, dynamic> json) {
    return ValveModel(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as int? ?? 1,
      zone: json['zone'] as String? ?? 'Unknown',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'zone': zone,
      'lastUpdated': lastUpdated.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ValveModel.fromEntity(ValveEntity entity) {
    return ValveModel(
      id: entity.id,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      status: entity.status,
      zone: entity.zone,
      lastUpdated: entity.lastUpdated,
      metadata: entity.metadata,
    );
  }
}
