import 'package:json_annotation/json_annotation.dart';
part 'incident_mission.g.dart';

@JsonSerializable()
class IncidentMission {
  @JsonKey(name: 'incident_type')
  final int? incidentTypeId;
  @JsonKey(name: 'missions')
  final List<Missions> missions;
  IncidentMission({this.incidentTypeId, required this.missions});

  // Factory method for deserialization
  factory IncidentMission.fromJson(Map<String, dynamic> json) =>
      _$IncidentMissionFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$IncidentMissionToJson(this);
}

@JsonSerializable()
class Missions {
  @JsonKey(name: 'mission_id')
  final int? missionId;
  @JsonKey(name: 'mission_class_name')
  final String? missionClassName;
  @JsonKey(name: 'mission_name')
  final String? missionName;
  @JsonKey(name: 'mission_order')
  final int? order;
  Missions({
    this.missionId,
    this.missionClassName,
    this.missionName,
    this.order,
  });
  // Factory method for deserialization
  factory Missions.fromJson(Map<String, dynamic> json) =>
      _$MissionsFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$MissionsToJson(this);
}
