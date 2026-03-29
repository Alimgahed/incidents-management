import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/auth/data/model/registration_model.dart';

part 'registeration_get_state.freezed.dart';

@freezed
class RegistrationGetState with _$RegistrationGetState {
  const factory RegistrationGetState.initial() = RegistrationGetStateInitial;
  const factory RegistrationGetState.loading() = RegistrationGetStateLoading;
  const factory RegistrationGetState.loaded(RegistrationModel data) =
      RegistrationGetStateLoaded;
  const factory RegistrationGetState.error(String message) =
      RegistrationGetStateError;
}
