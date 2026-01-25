import 'package:json_annotation/json_annotation.dart';
part 'all_mission_model.g.dart'; // Generated code part

@JsonSerializable()
class AllMissionModel {
  @JsonKey(name: 'mission_id')
  int? missionId;
  @JsonKey(name: 'mission_name')
  String missionName;
  @JsonKey(name: 'class_id')
  int classId;
  @JsonKey(name: 'class_name')
  String? className;

  AllMissionModel({
    this.missionId,
    required this.missionName,
    this.className,
    required this.classId,
  });
  factory AllMissionModel.fromJson(Map<String, dynamic> json) =>
      _$AllMissionModelFromJson(json);
  Map<String, dynamic> toJson() => _$AllMissionModelToJson(this);
}
