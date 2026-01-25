// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_mission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllMissionModel _$AllMissionModelFromJson(Map<String, dynamic> json) =>
    AllMissionModel(
      missionId: (json['mission_id'] as num?)?.toInt(),
      missionName: json['mission_name'] as String,
      className: json['class_name'] as String?,
      classId: (json['class_id'] as num).toInt(),
    );

Map<String, dynamic> _$AllMissionModelToJson(AllMissionModel instance) =>
    <String, dynamic>{
      'mission_id': instance.missionId,
      'mission_name': instance.missionName,
      'class_id': instance.classId,
      'class_name': instance.className,
    };
