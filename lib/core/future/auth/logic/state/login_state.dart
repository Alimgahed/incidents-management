import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_response_model.dart';
part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.loaded(LoginResponseModel data) = _Loaded;
  const factory LoginState.error(String message) = _Error;
}