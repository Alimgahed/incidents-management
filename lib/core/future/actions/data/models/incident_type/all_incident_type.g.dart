// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_incident_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidentType _$IncidentTypeFromJson(Map<String, dynamic> json) => IncidentType(
  incidentTypeId: (json['incident_type_id'] as num?)?.toInt(),
  className: json['class_name'] as String?,
  incidentTypeName: json['incident_type_name'] as String,
  classId: (json['class_id'] as num).toInt(),
  missions: (json['missions'] as List<dynamic>?)
      ?.map((e) => Missions.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$IncidentTypeToJson(IncidentType instance) =>
    <String, dynamic>{
      'incident_type_id': instance.incidentTypeId,
      'incident_type_name': instance.incidentTypeName,
      'class_name': instance.className,
      'class_id': instance.classId,
      'missions': instance.missions,
    };
