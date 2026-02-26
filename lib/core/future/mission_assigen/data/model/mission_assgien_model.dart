import 'package:json_annotation/json_annotation.dart';

part 'mission_assgien_model.g.dart';

@JsonSerializable()
class MissionAssgienModel {
  @JsonKey(name: "mission_id")
  final int missionId;

  @JsonKey(name: "user_id")
  final int userId;

  MissionAssgienModel({required this.missionId, required this.userId});

  /// from json
  factory MissionAssgienModel.fromJson(Map<String, dynamic> json) =>
      _$MissionAssgienModelFromJson(json);

  /// to json
  Map<String, dynamic> toJson() => _$MissionAssgienModelToJson(this);
}
