import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mission_assgien_model.g.dart';

@JsonSerializable()
class MissionAssgienModel extends Equatable {
  @JsonKey(name: "mission_id")
  final int missionId;

  @JsonKey(name: "user_id")
  final int userId;

  const MissionAssgienModel({required this.missionId, required this.userId});

  factory MissionAssgienModel.fromJson(Map<String, dynamic> json) =>
      _$MissionAssgienModelFromJson(json);

  Map<String, dynamic> toJson() => _$MissionAssgienModelToJson(this);

  @override
  List<Object?> get props => [missionId, userId];
}
