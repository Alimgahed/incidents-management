import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';

part 'mission_assign_states.freezed.dart';

@freezed
class MissionAssignState with _$MissionAssignState {
  const factory MissionAssignState.initial() = MissionAssignStateInitial;
  const factory MissionAssignState.loading() = MissionAssignStateLoading;
  const factory MissionAssignState.loaded(dynamic data) =
      MissionAssignStateLoaded;
  const factory MissionAssignState.error(ApiErrorModel message) =
      MissionAssignStateError;
}
