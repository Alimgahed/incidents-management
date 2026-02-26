// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_assgien_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MissionAssgienModel _$MissionAssgienModelFromJson(Map<String, dynamic> json) =>
    MissionAssgienModel(
      missionId: (json['mission_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
    );

Map<String, dynamic> _$MissionAssgienModelToJson(
  MissionAssgienModel instance,
) => <String, dynamic>{
  'mission_id': instance.missionId,
  'user_id': instance.userId,
};
