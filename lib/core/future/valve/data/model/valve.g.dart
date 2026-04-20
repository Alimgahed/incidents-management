// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valve.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValveModel _$ValveModelFromJson(Map<String, dynamic> json) => ValveModel(
  depth: (json['depth'] as num?)?.toDouble(),
  diameter: (json['diameter'] as num?)?.toInt(),
  direction: json['direction'] as String?,
  id: (json['id'] as num?)?.toInt(),
  inServiceYear: (json['in_service_year'] as num?)?.toInt(),
  lat: (json['lat'] as num?)?.toDouble(),
  long: (json['long'] as num?)?.toDouble(),
  numOfTurns: (json['num_of_turns'] as num?)?.toInt(),
  pipeDiameter: (json['pipe_diameter'] as num?)?.toInt(),
  position: json['position'] as String?,
  status: json['status'] as String?,
  valveType: json['valve_type'] == null
      ? null
      : ValveType.fromJson(json['valve_type'] as Map<String, dynamic>),
  valveTypeId: (json['valve_type_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$ValveModelToJson(ValveModel instance) =>
    <String, dynamic>{
      'depth': instance.depth,
      'diameter': instance.diameter,
      'direction': instance.direction,
      'id': instance.id,
      'in_service_year': instance.inServiceYear,
      'lat': instance.lat,
      'long': instance.long,
      'num_of_turns': instance.numOfTurns,
      'pipe_diameter': instance.pipeDiameter,
      'position': instance.position,
      'status': instance.status,
      'valve_type': instance.valveType,
      'valve_type_id': instance.valveTypeId,
    };

ValveType _$ValveTypeFromJson(Map<String, dynamic> json) => ValveType(
  abbreviation: json['abbreviation'] as String?,
  id: (json['id'] as num?)?.toInt(),
  nameAr: json['name_ar'] as String?,
  nameEn: json['name_en'] as String?,
);

Map<String, dynamic> _$ValveTypeToJson(ValveType instance) => <String, dynamic>{
  'abbreviation': instance.abbreviation,
  'id': instance.id,
  'name_ar': instance.nameAr,
  'name_en': instance.nameEn,
};
