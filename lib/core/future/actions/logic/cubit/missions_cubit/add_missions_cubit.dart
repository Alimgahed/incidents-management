import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/add_mission_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AddMissionCubit extends Cubit<AddMissionsState> {
  final AddMissionRepo _repository;

  AddMissionCubit({required AddMissionRepo repository})
    : _repository = repository,
      super(const AddMissionsState.initial());

  int? _selectedClassId;
  String? _missionName;

  void updateSelectedClass(int? classId) {
    _selectedClassId = classId;
    _emitInputState();
  }

  void updateMissionName(String name) {
    _missionName = name;
    _emitInputState();
  }

  void _emitInputState() {
    emit(
      AddMissionsState.inputChanged(
        selectedClassId: _selectedClassId,
        missionName: _missionName,
        isFormValid: _isDataValid(),
      ),
    );
  }

  bool _isDataValid() {
    return _selectedClassId != null &&
        _missionName != null &&
        _missionName!.trim().isNotEmpty;
  }

  Future<void> saveMission() async {
    if (!_isDataValid()) return;

    emit(const AddMissionsState.loading());

    final response = await _repository.addMission(
      AllMissionModel(
        missionName: _missionName!.trim(),
        classId: _selectedClassId!,
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
