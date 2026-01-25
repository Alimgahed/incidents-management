import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';

part 'get_all_missions_state.freezed.dart';

@freezed
class GetAllMissionState with _$GetAllMissionState {
  const factory GetAllMissionState.initial() = GetAllMissionStateInitial;
  const factory GetAllMissionState.loading() = GetAllMissionStateLoading;
  const factory GetAllMissionState.loaded(List<AllMissionModel> data) =
      GetAllMissionStateLoaded;
  const factory GetAllMissionState.error(String message) =
      GetAllMissionStateError;
}
