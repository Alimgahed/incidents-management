import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';

part 'mission_assign_states.freezed.dart';

@freezed
class MissionAssignState with _$MissionAssignState {
  const factory MissionAssignState.initial() = MissionAssignStateInitial;
  const factory MissionAssignState.loading() = MissionAssignStateLoading;
  const factory MissionAssignState.loaded(List<MissionAssgienModel> data) =
      MissionAssignStateLoaded;
  const factory MissionAssignState.error(String message) =
      MissionAssignStateError;
}
