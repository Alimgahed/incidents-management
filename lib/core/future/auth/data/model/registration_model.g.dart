// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationModel _$RegistrationModelFromJson(Map<String, dynamic> json) =>
    RegistrationModel(
      authLevels: (json['auth_levels'] as List<dynamic>)
          .map((e) => AuthLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      groups: (json['groups'] as List<dynamic>)
          .map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      sectors: (json['sectors'] as List<dynamic>)
          .map((e) => Sector.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RegistrationModelToJson(RegistrationModel instance) =>
    <String, dynamic>{
      'auth_levels': instance.authLevels,
      'groups': instance.groups,
      'sectors': instance.sectors,
    };

AuthLevel _$AuthLevelFromJson(Map<String, dynamic> json) => AuthLevel(
  id: (json['id'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$AuthLevelToJson(AuthLevel instance) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
};

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  groupId: (json['group_id'] as num).toInt(),
  groupName: json['group_name'] as String,
  groupNotification: json['group_notification'] as String,
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'group_id': instance.groupId,
  'group_name': instance.groupName,
  'group_notification': instance.groupNotification,
};

Sector _$SectorFromJson(Map<String, dynamic> json) => Sector(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  authorityLevelId: (json['authority_level_id'] as num?)?.toInt(),
  parentSectorManagementId: (json['parent_sector_management_id'] as num?)
      ?.toInt(),
  fromXAxis: (json['from_x_axis'] as num?)?.toDouble(),
  fromYAxis: (json['from_y_axis'] as num?)?.toDouble(),
  toXAxis: (json['to_x_axis'] as num?)?.toDouble(),
  toYAxis: (json['to_y_axis'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SectorToJson(Sector instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'authority_level_id': instance.authorityLevelId,
  'parent_sector_management_id': instance.parentSectorManagementId,
  'from_x_axis': instance.fromXAxis,
  'from_y_axis': instance.fromYAxis,
  'to_x_axis': instance.toXAxis,
  'to_y_axis': instance.toYAxis,
};
