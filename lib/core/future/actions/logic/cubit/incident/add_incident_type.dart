import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/data/repos/incident_type_repo/add_incident_type_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_type_states.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AddIncidentTypeCubit extends Cubit<AddIncidentTypeState> {
  final AddIncidentTypeRepo _repository;

  AddIncidentTypeCubit({required AddIncidentTypeRepo repository})
    : _repository = repository,
      super(const AddIncidentTypeState.initial());

  int? _selectedClassId;
  String? _incidentName;

  void updateSelectedClass(int? classId) {
    _selectedClassId = classId;
    _emitInputState();
  }

  void updateIncidentName(String name) {
    _incidentName = name;
    _emitInputState();
  }

  void _emitInputState() {
    emit(
      AddIncidentTypeState.inputChanged(
        selectedClassId: _selectedClassId,
        incidentName: _incidentName,
        isFormValid: _isDataValid(),
      ),
    );
  }

  bool _isDataValid() {
    return _selectedClassId != null &&
        _incidentName != null &&
        _incidentName!.trim().isNotEmpty;
  }

  Future<void> saveIncidentType() async {
    if (!_isDataValid()) return;

    emit(const AddIncidentTypeState.loading());

    final response = await _repository.addIncidentType(
      IncidentType(
        incidentTypeName: _incidentName!.trim(),
        classId: _selectedClassId!,
      ),
    );

    response.when(
      success: (data) {
        emit(const AddIncidentTypeState.success());
      },
      error: (apiErrorModel) {
        // Extract the actual error message from your model
        emit(AddIncidentTypeState.error(apiErrorModel));
      },
    );
  }
}
