import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/edit_mission_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class EditMissionsCubit extends Cubit<AddMissionsState> {
  final EditMissionRepo _repository;

  EditMissionsCubit({required EditMissionRepo repository})
    : _repository = repository,
      super(const AddMissionsState.initial());
  int id = 0;
  int? selectedClassId;
  final TextEditingController missionName = TextEditingController();
  void updateSelectedClass(int? classId) {
    selectedClassId = classId;
    _emitInputState();
  }

  void _emitInputState() {
    emit(
      AddMissionsState.inputChanged(
        selectedClassId: selectedClassId,
        missionName: missionName.text,
        isFormValid: _isDataValid(),
      ),
    );
  }

  bool _isDataValid() {
    return selectedClassId != null &&
        missionName.text.isNotEmpty &&
        missionName.text.trim().isNotEmpty;
  }

  Future<void> saveMission() async {
    if (!_isDataValid()) return;

    emit(const AddMissionsState.loading());

    final response = await _repository.editMission(
      id,
      AllMissionModel(
        missionName: missionName.text.trim(),
        classId: selectedClassId!,
      ),
    );

    response.when(
      success: (data) {
        emit(const AddMissionsState.success());
      },
      error: (apiErrorModel) {
        // Extract the actual error message from your model
        emit(AddMissionsState.error(apiErrorModel));
      },
    );
  }
}
