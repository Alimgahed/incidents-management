import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';

part 'registeration_post_state.freezed.dart';

@freezed
class RegistrationPostState with _$RegistrationPostState {
  const factory RegistrationPostState.initial() = RegistrationPostStateInitial;
  const factory RegistrationPostState.loading() = RegistrationPostStateLoading;
  const factory RegistrationPostState.loaded(dynamic data) =
      RegistrationPostStateLoaded;
  const factory RegistrationPostState.error(ApiErrorModel message) =
      RegistrationPostStateError;
}
