import 'package:json_annotation/json_annotation.dart';
part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  final String? username;
  final String? password;
  @JsonKey(name: 'device_token')
  final String? deviceToken;

  LoginModel({this.username, this.password, this.deviceToken});

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
