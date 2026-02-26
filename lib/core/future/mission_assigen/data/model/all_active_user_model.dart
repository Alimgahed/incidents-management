import 'package:json_annotation/json_annotation.dart';

part 'all_active_user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ActiveUser {
  @JsonKey(name: 'authority_level_id')
  final int? authorityLevelId;

  @JsonKey(name: 'authority_name')
  final String? authorityName;

  @JsonKey(name: 'emp_code')
  final String? empCode;

  @JsonKey(name: 'emp_name')
  final String? empName;

  @JsonKey(name: 'group_id')
  final int? groupId;

  @JsonKey(name: 'group_name')
  final String? groupName;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  @JsonKey(name: 'sector_management_id')
  final int? sectorManagementId;

  @JsonKey(name: 'sector_management_name')
  final String? sectorManagementName;

  @JsonKey(name: 'user_classes')
  final List<UserClass>? userClasses;

  @JsonKey(name: 'user_id')
  final int? userId;

  @JsonKey(name: 'username')
  final String? username;

  ActiveUser({
    this.authorityLevelId,
    this.authorityName,
    this.empCode,
    this.empName,
    this.groupId,
    this.groupName,
    this.isActive,
    this.sectorManagementId,
    this.sectorManagementName,
    this.userClasses,
    this.userId,
    this.username,
  });

  factory ActiveUser.fromJson(Map<String, dynamic> json) =>
      _$ActiveUserFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveUserToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserClass {
  @JsonKey(name: 'class_id')
  final int? classId;

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'sector_management_id')
  final int? sectorManagementId;

  /// 🔥 nested object اسمه "class" في الـ API
  @JsonKey(name: 'class')
  final ClassInfo? classInfo;

  @JsonKey(name: 'sector_management')
  final SectorManagement? sectorManagement;

  UserClass({
    this.classId,
    this.id,
    this.sectorManagementId,
    this.classInfo,
    this.sectorManagement,
  });

  factory UserClass.fromJson(Map<String, dynamic> json) =>
      _$UserClassFromJson(json);

  Map<String, dynamic> toJson() => _$UserClassToJson(this);
}

@JsonSerializable()
class ClassInfo {
  @JsonKey(name: 'class_id')
  final int? classId;

  @JsonKey(name: 'class_name')
  final String? className;

  ClassInfo({this.classId, this.className});

  factory ClassInfo.fromJson(Map<String, dynamic> json) =>
      _$ClassInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ClassInfoToJson(this);
}

@JsonSerializable()
class SectorManagement {
  @JsonKey(name: 'authority_level_id')
  final int? authorityLevelId;

  @JsonKey(name: 'from_x_axis')
  final double? fromXAxis;

  @JsonKey(name: 'from_y_axis')
  final double? fromYAxis;

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'parent_sector_management_id')
  final int? parentSectorManagementId;

  @JsonKey(name: 'to_x_axis')
  final double? toXAxis;

  @JsonKey(name: 'to_y_axis')
  final double? toYAxis;

  SectorManagement({
    this.authorityLevelId,
    this.fromXAxis,
    this.fromYAxis,
    this.id,
    this.name,
    this.parentSectorManagementId,
    this.toXAxis,
    this.toYAxis,
  });

  factory SectorManagement.fromJson(Map<String, dynamic> json) =>
      _$SectorManagementFromJson(json);

  Map<String, dynamic> toJson() => _$SectorManagementToJson(this);
}
