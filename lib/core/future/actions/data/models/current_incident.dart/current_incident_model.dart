import 'package:json_annotation/json_annotation.dart';
part 'current_incident_model.g.dart';

@JsonSerializable()
class CurrentIncidentModel {
  @JsonKey(name: 'current_incident_id')
  final int? currentIncidentId;
  @JsonKey(name: 'current_incident_description')
  final String? currentIncidentDescription;
  @JsonKey(name: 'current_incident_type_id')
  final int? currentIncidentTypeId;
  @JsonKey(name: 'current_incident_created_by')
  final int? currentIncidentCreatedBy;
  @JsonKey(name: 'current_incident_created_at')
  final DateTime? currentIncidentCreatedAt;
  @JsonKey(name: 'current_incident_severity')
  final int? currentIncidentSeverity;
  @JsonKey(name: 'current_incident_severity_updated_by')
  final int? currentIncidentSeverityUpdateBy;
  @JsonKey(name: 'current_incident_severity_updated_at')
  final DateTime? currentIncidentSeverityUpdateAt;
  @JsonKey(name: 'current_incident_status')
  final int? currentIncidentStatus;
  @JsonKey(name: 'current_incident_status_updated_by')
  final int? currentIncidentStatusUpdatedBy;
  @JsonKey(name: 'current_incident_status_updated_at')
  final DateTime? currentIncidentStatusUpdatedAt;
  @JsonKey(name: 'current_incident_x_axis')
  final double? currentIncidentXAxis;
  @JsonKey(name: 'current_incident_y_axis')
  final double? currentIncidentYAxis;
  @JsonKey(name: 'current_incident_notes')
  final String? currentIncidentNotes;
  @JsonKey(name: 'missions')
  List<CurrentIncidentWithMissions>? currentIncidentWithMissions;
  @JsonKey(name: 'branch_id')
  final int? branchId;

  CurrentIncidentModel({
    this.currentIncidentId,
    this.currentIncidentDescription,
    this.currentIncidentTypeId,
    this.branchId,
    this.currentIncidentCreatedBy,
    this.currentIncidentCreatedAt,
    this.currentIncidentSeverity,
    this.currentIncidentSeverityUpdateBy,
    this.currentIncidentSeverityUpdateAt,
    this.currentIncidentStatus,
    this.currentIncidentStatusUpdatedBy,
    this.currentIncidentStatusUpdatedAt,
    this.currentIncidentXAxis,
    this.currentIncidentYAxis,
    this.currentIncidentNotes,
  });
  factory CurrentIncidentModel.fromJson(Map<String, dynamic> json) =>
      _$CurrentIncidentModelFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentIncidentModelToJson(this);
}

@JsonSerializable()
class CurrentIncidentWithMissions {
  @JsonKey(name: 'id_current_incident_mission')
  final int? idCurrentIncidentMission;
  @JsonKey(name: 'current_incident_id')
  final int? currentIncidentId;
  @JsonKey(name: 'current_incident_mission_id')
  final int? currentIncidentMissionId;
  @JsonKey(name: 'current_incident_mission_order')
  final int? currentIncidentMissionOrder;
  @JsonKey(name: 'current_incident_mission_status')
  final int? currentIncidentMissionStatus;
  @JsonKey(name: 'current_incident_mission_status_updated_by')
  final int? currentIncidentMissionStatusUpdatedBy;
  @JsonKey(name: 'current_incident_mission_status_updated_at')
  final DateTime? currentIncidentMissionStatusUpdatedAt;
  @JsonKey(name: 'mission_name')
  final String? missionName;

  CurrentIncidentWithMissions({
    this.idCurrentIncidentMission,
    this.currentIncidentId,
    this.currentIncidentMissionId,
    this.currentIncidentMissionOrder,
    this.currentIncidentMissionStatus,
    this.currentIncidentMissionStatusUpdatedBy,
    this.currentIncidentMissionStatusUpdatedAt,
    this.missionName,
  });
  factory CurrentIncidentWithMissions.fromJson(Map<String, dynamic> json) =>
      _$CurrentIncidentWithMissionsFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentIncidentWithMissionsToJson(this);
}
