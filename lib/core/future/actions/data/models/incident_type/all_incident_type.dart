import 'package:json_annotation/json_annotation.dart';

part 'all_incident_type.g.dart'; // Generated code part

@JsonSerializable()
class IncidentType {
  @JsonKey(name: 'incident_type_id')
  final int? incidentTypeId;
  @JsonKey(name: 'incident_type_name')
  final String incidentTypeName;
  @JsonKey(name: 'class_id')
  final int classId;
  @JsonKey(name: 'mission_id')
  final int? missionId;

  IncidentType({
    this.incidentTypeId,
    required this.incidentTypeName,
    required this.classId,
    this.missionId,
  });

  // Factory method for deserialization
  factory IncidentType.fromJson(Map<String, dynamic> json) =>
      _$IncidentTypeFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$IncidentTypeToJson(this);
}
