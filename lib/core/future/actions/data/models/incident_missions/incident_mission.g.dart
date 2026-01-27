// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_mission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidentMission _$IncidentMissionFromJson(Map<String, dynamic> json) =>
    IncidentMission(
      incidentTypeId: (json['incident_type'] as num?)?.toInt(),
      missions: (json['missions'] as List<dynamic>)
          .map((e) => Missions.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$IncidentMissionToJson(IncidentMission instance) =>
    <String, dynamic>{
      'incident_type': instance.incidentTypeId,
      'missions': instance.missions,
    };

Missions _$MissionsFromJson(Map<String, dynamic> json) => Missions(
  missionId: (json['mission_id'] as num?)?.toInt(),
  missionClassName: json['mission_class_name'] as String?,
  missionName: json['mission_name'] as String?,
  order: (json['mission_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$MissionsToJson(Missions instance) => <String, dynamic>{
  'mission_id': instance.missionId,
  'mission_class_name': instance.missionClassName,
  'mission_name': instance.missionName,
  'mission_order': instance.order,
};
