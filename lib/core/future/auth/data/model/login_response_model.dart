import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  @JsonKey(name: 'current_user')
  final CurrentUser? currentUser;
  final String? token;

  LoginResponseModel({this.currentUser, this.token});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

@JsonSerializable()
class CurrentUser {
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
  @JsonKey(name: 'user_id')
  final int? userId;
  final String? username;
  @JsonKey(name: 'user_classes')
  final List<dynamic>? userClasses; // Assuming it can be a list of dynamic items

  CurrentUser({
    this.authorityLevelId,
    this.authorityName,
    this.empCode,
    this.empName,
    this.groupId,
    this.groupName,
    this.isActive,
    this.sectorManagementId,
    this.sectorManagementName,
    this.userId,
    this.username,
    this.userClasses,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserToJson(this);
}
