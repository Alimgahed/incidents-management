import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'incident_mission.g.dart';

@JsonSerializable()
class IncidentMission extends Equatable {
  @JsonKey(name: 'incident_type')
  final int? incidentTypeId;
  @JsonKey(name: 'missions')
  final List<Missions> missions;

  const IncidentMission({this.incidentTypeId, required this.missions});

  factory IncidentMission.fromJson(Map<String, dynamic> json) =>
      _$IncidentMissionFromJson(json);

  Map<String, dynamic> toJson() => _$IncidentMissionToJson(this);

  @override
  List<Object?> get props => [incidentTypeId, missions];
}

@JsonSerializable()
class Missions extends Equatable {
  @JsonKey(name: 'mission_id')
  final int? missionId;
  @JsonKey(name: 'mission_class_name')
  final String? missionClassName;
  @JsonKey(name: 'mission_name')
  final String? missionName;
  @JsonKey(name: 'mission_order')
  final int? order;

  const Missions({
    this.missionId,
    this.missionClassName,
    this.missionName,
    this.order,
  });

  factory Missions.fromJson(Map<String, dynamic> json) =>
      _$MissionsFromJson(json);

  Map<String, dynamic> toJson() => _$MissionsToJson(this);

  @override
  List<Object?> get props => [missionId, missionClassName, missionName, order];
}
