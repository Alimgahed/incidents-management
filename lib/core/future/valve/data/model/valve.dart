// lib/models/valve_model.dart

import 'package:incidents_managment/core/future/valve/logic/state/valve_state.dart';

class ValveModel extends ProximityState {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;

  const ValveModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  factory ValveModel.fromJson(Map<String, dynamic> json) => ValveModel(
        id: json['id'] as String,
        name: json['name'] as String,
        latitude: (json['lat'] as num).toDouble(),
        longitude: (json['lng'] as num).toDouble(),
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': latitude,
        'lng': longitude,
        'description': description,
      };

  @override
  List<Object?> get props => [id, name, latitude, longitude, description];
}