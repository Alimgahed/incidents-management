// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      currentUser: json['current_user'] == null
          ? null
          : CurrentUser.fromJson(json['current_user'] as Map<String, dynamic>),
      token: json['token'] as String?,
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'current_user': instance.currentUser,
      'token': instance.token,
    };

CurrentUser _$CurrentUserFromJson(Map<String, dynamic> json) => CurrentUser(
  authorityLevelId: (json['authority_level_id'] as num?)?.toInt(),
  authorityName: json['authority_name'] as String?,
  empCode: json['emp_code'] as String?,
  empName: json['emp_name'] as String?,
  groupId: (json['group_id'] as num?)?.toInt(),
  groupName: json['group_name'] as String?,
  isActive: json['is_active'] as bool?,
  sectorManagementId: (json['sector_management_id'] as num?)?.toInt(),
  sectorManagementName: json['sector_management_name'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  username: json['username'] as String?,
  userClasses: json['user_classes'] as List<dynamic>?,
);

Map<String, dynamic> _$CurrentUserToJson(CurrentUser instance) =>
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
      'user_id': instance.userId,
      'username': instance.username,
      'user_classes': instance.userClasses,
    };
