import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_missions/incident_mission.dart';
import 'package:incidents_managment/core/future/actions/data/repos/incident_missions_repo.dart/incident_missions.dart';
import 'package:incidents_managment/core/future/actions/logic/states/incident_missions_state.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/relation_incident_mission.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';

class AddIncidentMissionCubit extends Cubit<AddincidentMissionsstates> {
  final AddIncidentMissionRepo _repository;

  AddIncidentMissionCubit({required AddIncidentMissionRepo repository})
    : _repository = repository,
      super(const AddincidentMissionsstates.initial());

  void resetState() {
    if (!isClosed) emit(const AddincidentMissionsstates.initial());
  }

  Future<void> saveIncidentMission({
    required MissionSelectionState selectionState,
    required int? incidentTypeId,
  }) async {
    if (isClosed) return;

    // Check if already loading to prevent duplicate requests
    if (state is loadingAddincidentMissionsstates) {
      return;
    }

    emit(const AddincidentMissionsstates.loading());

    try {
      final missionsData = selectionState.selectedMissions
          .map((m) => Missions(missionId: m.missionId, order: m.order))
          .toList();

      final incidentMission = IncidentMission(
        missions: missionsData,
        incidentTypeId: incidentTypeId,
      );

      final response = await _repository.addIncidentMission(incidentMission);

      if (isClosed) return;

      response.when(
        success: (_) {
          if (!isClosed) {
            emit(const AddincidentMissionsstates.success());
          }
        },
        error: (apiErrorModel) {
          if (!isClosed) emit(AddincidentMissionsstates.error(apiErrorModel));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        AddincidentMissionsstates.error(
          ApiErrorModel(error: 'An unexpected error occurred'),
        ),
      );
    }
  }
}
