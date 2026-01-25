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
  final int? order;
  Missions({this.missionId, this.order});

  // Factory method for deserialization
  factory Missions.fromJson(Map<String, dynamic> json) =>
      _$MissionsFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$MissionsToJson(this);
}
