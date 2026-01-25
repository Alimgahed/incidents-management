import 'package:json_annotation/json_annotation.dart';

part 'all_incident_classes.g.dart'; // Generated code part

@JsonSerializable()
class IncidentClass {
  @JsonKey(name: 'class_id')
  final int incidentClassId;
  @JsonKey(name: 'class_name')
  final String incidentClassName;

  IncidentClass({
    required this.incidentClassId,
    required this.incidentClassName,
  });

  // Factory method for deserialization
  factory IncidentClass.fromJson(Map<String, dynamic> json) =>
      _$IncidentClassFromJson(json);

  // Method for serialization
  Map<String, dynamic> toJson() => _$IncidentClassToJson(this);
}
