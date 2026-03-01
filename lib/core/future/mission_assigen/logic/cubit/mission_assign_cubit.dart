import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_assign_states.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/repo/mission_assign_repo.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class MissionAssignCubit extends Cubit<MissionAssignState> {
  final MissionAssignRepo missionAssignRepo;

  MissionAssignCubit({required this.missionAssignRepo})
    : super(const MissionAssignState.initial());

  Future<void> missionUserAssign(
    int currentIncidentMissionId,
    List<MissionAssgienModel> data,
  ) async {
    emit(const MissionAssignState.loading());

    final result = await missionAssignRepo.missionUserAssign(
      currentIncidentMissionId,
      data,
    );

    result.when(
      success: (data) => emit(MissionAssignState.loaded(data)),
      error: (e) => emit(MissionAssignState.error(e)),
    );
  }
}
