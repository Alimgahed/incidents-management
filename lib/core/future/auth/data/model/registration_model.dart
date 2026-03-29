import 'package:json_annotation/json_annotation.dart';
part 'registration_model.g.dart';
@JsonSerializable()
class RegistrationModel {
  @JsonKey(name: 'auth_levels')
  final List<AuthLevel> authLevels;

  final List<Group> groups;
  final List<Sector> sectors;

  RegistrationModel({
    required this.authLevels,
    required this.groups,
    required this.sectors,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationModelToJson(this);
}

@JsonSerializable()
class AuthLevel {
  final int id;
  final String description;

  AuthLevel({required this.id, required this.description});

  factory AuthLevel.fromJson(Map<String, dynamic> json) =>
      _$AuthLevelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthLevelToJson(this);
}

@JsonSerializable()
class Group {
  @JsonKey(name: 'group_id')
  final int groupId;

  @JsonKey(name: 'group_name')
  final String groupName;

  @JsonKey(name: 'group_notification')
  final String groupNotification;

  Group({
    required this.groupId,
    required this.groupName,
    required this.groupNotification,
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class Sector {
  final int id;
  final String name;

  @JsonKey(name: 'authority_level_id')
  final int? authorityLevelId;

  @JsonKey(name: 'parent_sector_management_id')
  final int? parentSectorManagementId;

  @JsonKey(name: 'from_x_axis')
  final double? fromXAxis;

  @JsonKey(name: 'from_y_axis')
  final double? fromYAxis;

  @JsonKey(name: 'to_x_axis')
  final double? toXAxis;

  @JsonKey(name: 'to_y_axis')
  final double? toYAxis;

  Sector({
    required this.id,
    required this.name,
    this.authorityLevelId,
    this.parentSectorManagementId,
    this.fromXAxis,
    this.fromYAxis,
    this.toXAxis,
    this.toYAxis,
  });

  factory Sector.fromJson(Map<String, dynamic> json) => _$SectorFromJson(json);

  Map<String, dynamic> toJson() => _$SectorToJson(this);
}
