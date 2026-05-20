import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'all_incident_classes.g.dart'; // Generated code part

@JsonSerializable()
class IncidentClass extends Equatable {
  @JsonKey(name: 'class_id')
  final int incidentClassId;
  @JsonKey(name: 'class_name')
  final String incidentClassName;

  const IncidentClass({
    required this.incidentClassId,
    required this.incidentClassName,
  });

  factory IncidentClass.fromJson(Map<String, dynamic> json) =>
      _$IncidentClassFromJson(json);

  Map<String, dynamic> toJson() => _$IncidentClassToJson(this);

  @override
  List<Object?> get props => [incidentClassId, incidentClassName];
}
