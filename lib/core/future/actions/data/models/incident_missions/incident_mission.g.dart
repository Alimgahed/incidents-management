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
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$MissionsToJson(Missions instance) => <String, dynamic>{
  'mission_id': instance.missionId,
  'order': instance.order,
};
