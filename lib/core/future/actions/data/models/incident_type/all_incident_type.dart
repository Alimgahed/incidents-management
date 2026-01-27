import 'package:incidents_managment/core/future/actions/data/models/incident_missions/incident_mission.dart';
import 'package:json_annotation/json_annotation.dart';

part 'all_incident_type.g.dart'; // Generated code part

@JsonSerializable()
class IncidentType {
  @JsonKey(name: 'incident_type_id')
  final int? incidentTypeId;
  @JsonKey(name: 'incident_type_name')
  final String incidentTypeName;
  @JsonKey(name: 'class_name')
  final String? className;
  @JsonKey(name: 'class_id')
  final int classId;
  @JsonKey(name: 'missions')
  final List<Missions>? missions;

  IncidentType({
    this.incidentTypeId,
    this.className,
    required this.incidentTypeName,
    required this.classId,
    this.missions,
  });

  // Factory method for deserialization
  factory IncidentType.fromJson(Map<String, dynamic> json) =>
      _$IncidentTypeFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$IncidentTypeToJson(this);
}
