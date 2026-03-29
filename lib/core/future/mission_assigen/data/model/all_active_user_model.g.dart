// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_active_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveUser _$ActiveUserFromJson(Map<String, dynamic> json) => ActiveUser(
  authorityLevelId: (json['authority_level_id'] as num?)?.toInt(),
  authorityName: json['authority_name'] as String?,
  empCode: json['emp_code'] as String?,
  empName: json['emp_name'] as String?,
  groupId: (json['group_id'] as num?)?.toInt(),
  groupName: json['group_name'] as String?,
  isActive: json['is_active'] as bool?,
  sectorManagementId: (json['sector_management_id'] as num?)?.toInt(),
  sectorManagementName: json['sector_management_name'] as String?,
  userClasses: (json['user_classes'] as List<dynamic>?)
      ?.map((e) => UserClass.fromJson(e as Map<String, dynamic>))
      .toList(),
  userId: (json['user_id'] as num?)?.toInt(),
  username: json['username'] as String?,
  password: json['password'] as String?,
);

Map<String, dynamic> _$ActiveUserToJson(ActiveUser instance) =>
    <String, dynamic>{
      'authority_level_id': instance.authorityLevelId,
      'authority_name': instance.authorityName,
      'emp_code': instance.empCode,
      'emp_name': instance.empName,
      'group_id': instance.groupId,
      'group_name': instance.groupName,
      'is_active': instance.isActive,
      'sector_management_id': instance.sectorManagementId,
      'sector_management_name': instance.sectorManagementName,
      'user_classes': instance.userClasses?.map((e) => e.toJson()).toList(),
      'user_id': instance.userId,
      'username': instance.username,
      'password': instance.password,
    };

UserClass _$UserClassFromJson(Map<String, dynamic> json) => UserClass(
  classId: (json['class_id'] as num?)?.toInt(),
  id: (json['id'] as num?)?.toInt(),
  sectorManagementId: (json['sector_management_id'] as num?)?.toInt(),
  classInfo: json['class'] == null
      ? null
      : ClassInfo.fromJson(json['class'] as Map<String, dynamic>),
  sectorManagement: json['sector_management'] == null
      ? null
      : SectorManagement.fromJson(
          json['sector_management'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserClassToJson(UserClass instance) => <String, dynamic>{
  'class_id': instance.classId,
  'id': instance.id,
  'sector_management_id': instance.sectorManagementId,
  'class': instance.classInfo?.toJson(),
  'sector_management': instance.sectorManagement?.toJson(),
};

ClassInfo _$ClassInfoFromJson(Map<String, dynamic> json) => ClassInfo(
  classId: (json['class_id'] as num?)?.toInt(),
  className: json['class_name'] as String?,
);

Map<String, dynamic> _$ClassInfoToJson(ClassInfo instance) => <String, dynamic>{
  'class_id': instance.classId,
  'class_name': instance.className,
};

SectorManagement _$SectorManagementFromJson(Map<String, dynamic> json) =>
    SectorManagement(
      authorityLevelId: (json['authority_level_id'] as num?)?.toInt(),
      fromXAxis: (json['from_x_axis'] as num?)?.toDouble(),
      fromYAxis: (json['from_y_axis'] as num?)?.toDouble(),
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      parentSectorManagementId: (json['parent_sector_management_id'] as num?)
          ?.toInt(),
      toXAxis: (json['to_x_axis'] as num?)?.toDouble(),
      toYAxis: (json['to_y_axis'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SectorManagementToJson(SectorManagement instance) =>
    <String, dynamic>{
      'authority_level_id': instance.authorityLevelId,
      'from_x_axis': instance.fromXAxis,
      'from_y_axis': instance.fromYAxis,
      'id': instance.id,
      'name': instance.name,
      'parent_sector_management_id': instance.parentSectorManagementId,
      'to_x_axis': instance.toXAxis,
      'to_y_axis': instance.toYAxis,
    };
