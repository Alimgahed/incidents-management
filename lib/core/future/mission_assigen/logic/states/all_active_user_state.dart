import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';

part 'all_active_user_state.freezed.dart';

@freezed
class AllActiveUserState with _$AllActiveUserState {
  const factory AllActiveUserState.initial() = AllActiveUserStateInitial;
  const factory AllActiveUserState.loading() = AllActiveUserStateLoading;
  const factory AllActiveUserState.loaded(List<ActiveUser> data) =
      AllActiveUserStateLoaded;
  const factory AllActiveUserState.error(String message) =
      AllActiveUserStateError;
}
