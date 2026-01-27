// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_incident_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentIncidentModel _$CurrentIncidentModelFromJson(
  Map<String, dynamic> json,
) => CurrentIncidentModel(
  currentIncidentId: (json['current_incident_id'] as num?)?.toInt(),
  currentIncidentDescription: json['current_incident_description'] as String?,
  currentIncidentTypeId: (json['current_incident_type_id'] as num?)?.toInt(),
  currentIncidentCreatedBy: (json['current_incident_created_by'] as num?)
      ?.toInt(),
  currentIncidentCreatedAt: json['current_incident_created_at'] == null
      ? null
      : DateTime.parse(json['current_incident_created_at'] as String),
  currentIncidentSeverity: (json['current_incident_severity'] as num?)?.toInt(),
  currentIncidentSeverityUpdateBy:
      (json['current_incident_severity_updated_by'] as num?)?.toInt(),
  currentIncidentSeverityUpdateAt:
      json['current_incident_severity_updated_at'] == null
      ? null
      : DateTime.parse(json['current_incident_severity_updated_at'] as String),
  currentIncidentStatus: (json['current_incident_status'] as num?)?.toInt(),
  currentIncidentStatusUpdatedBy:
      (json['current_incident_status_updated_by'] as num?)?.toInt(),
  currentIncidentStatusUpdatedAt:
      json['current_incident_status_updated_at'] == null
      ? null
      : DateTime.parse(json['current_incident_status_updated_at'] as String),
  currentIncidentXAxis: (json['current_incident_x_axis'] as num?)?.toDouble(),
  currentIncidentYAxis: (json['current_incident_y_axis'] as num?)?.toDouble(),
  currentIncidentNotes: json['current_incident_notes'] as String?,
);

Map<String, dynamic> _$CurrentIncidentModelToJson(
  CurrentIncidentModel instance,
) => <String, dynamic>{
  'current_incident_id': instance.currentIncidentId,
  'current_incident_description': instance.currentIncidentDescription,
  'current_incident_type_id': instance.currentIncidentTypeId,
  'current_incident_created_by': instance.currentIncidentCreatedBy,
  'current_incident_created_at': instance.currentIncidentCreatedAt
      ?.toIso8601String(),
  'current_incident_severity': instance.currentIncidentSeverity,
  'current_incident_severity_updated_by':
      instance.currentIncidentSeverityUpdateBy,
  'current_incident_severity_updated_at': instance
      .currentIncidentSeverityUpdateAt
      ?.toIso8601String(),
  'current_incident_status': instance.currentIncidentStatus,
  'current_incident_status_updated_by': instance.currentIncidentStatusUpdatedBy,
  'current_incident_status_updated_at': instance.currentIncidentStatusUpdatedAt
      ?.toIso8601String(),
  'current_incident_x_axis': instance.currentIncidentXAxis,
  'current_incident_y_axis': instance.currentIncidentYAxis,
  'current_incident_notes': instance.currentIncidentNotes,
};
