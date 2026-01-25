// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_incident_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidentClass _$IncidentClassFromJson(Map<String, dynamic> json) =>
    IncidentClass(
      incidentClassId: (json['class_id'] as num).toInt(),
      incidentClassName: json['class_name'] as String,
    );

Map<String, dynamic> _$IncidentClassToJson(IncidentClass instance) =>
    <String, dynamic>{
      'class_id': instance.incidentClassId,
      'class_name': instance.incidentClassName,
    };
