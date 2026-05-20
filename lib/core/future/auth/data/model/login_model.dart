import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel extends Equatable {
  final String? username;
  final String? password;
  @JsonKey(name: 'device_token')
  final String? deviceToken;

  const LoginModel({this.username, this.password, this.deviceToken});

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);

  @override
  List<Object?> get props => [username, password, deviceToken];
}
