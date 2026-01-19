// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_incident_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidentType _$IncidentTypeFromJson(Map<String, dynamic> json) => IncidentType(
  incidentTypeId: (json['incident_type_id'] as num?)?.toInt(),
  incidentTypeName: json['incident_type_name'] as String,
  classId: (json['class_id'] as num).toInt(),
);

Map<String, dynamic> _$IncidentTypeToJson(IncidentType instance) =>
    <String, dynamic>{
      'incident_type_id': instance.incidentTypeId,
      'incident_type_name': instance.incidentTypeName,
      'class_id': instance.classId,
    };
