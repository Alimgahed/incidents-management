import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/relation_incident_mission.dart';

class MissionSelectionCubit extends Cubit<MissionSelectionState> {
  MissionSelectionCubit() : super(MissionSelectionState());

  void addMission(int missionId, String missionName) {
    final newSelectedMissions = List<SelectedMission>.from(
      state.selectedMissions,
    );
    final nextOrder = _getNextOrder();
    final uniqueId = '${missionId}_${DateTime.now().millisecondsSinceEpoch}';

    newSelectedMissions.add(
      SelectedMission(
        missionId: missionId,
        missionName: missionName,
        order: nextOrder,
        uniqueId: uniqueId,
      ),
    );

    if (!isClosed) {
      emit(state.copyWith(selectedMissions: newSelectedMissions));
    }
  }

  void removeMission(String uniqueId) {
    final newSelectedMissions = state.selectedMissions
        .where((mission) => mission.uniqueId != uniqueId)
        .toList();

    // Reorder remaining missions
    final reorderedMissions = <SelectedMission>[];
    for (int i = 0; i < newSelectedMissions.length; i++) {
      reorderedMissions.add(newSelectedMissions[i].copyWith(order: i + 1));
    }

    if (!isClosed) {
      emit(state.copyWith(selectedMissions: reorderedMissions));
    }
  }

  void setIncidentClass(int? classId) {
    if (!isClosed) {
      emit(
        state.copyWith(selectedIncidentClassId: classId, selectedMissions: []),
      );
    }
  }

  void setIncidentType(int? typeId) {
    if (!isClosed) {
      emit(state.copyWith(selectedIncidentTypeId: typeId));
    }
  }

  int _getNextOrder() {
    if (state.selectedMissions.isEmpty) return 1;
    return state.selectedMissions
            .map((m) => m.order)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  void reset() {
    if (!isClosed) {
      emit(
        MissionSelectionState(
          selectedIncidentClassId: null,
          selectedIncidentTypeId: null,
          selectedMissions: [],
        ),
      );
    }
  }

  bool canSave() {
    return state.selectedIncidentClassId != null &&
        state.selectedIncidentTypeId != null &&
        state.selectedMissions.isNotEmpty;
  }

  int getMissionCount(int missionId) {
    return state.selectedMissions
        .where((mission) => mission.missionId == missionId)
        .length;
  }
}
