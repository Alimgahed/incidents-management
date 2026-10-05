import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/add_incident/add_incdient_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AddIncidentCubit extends Cubit<AddIncidentStates> {
  final AddIncdientRepo addIncdientRepo;
  bool lastSubmissionQueued = false;

  AddIncidentCubit({required this.addIncdientRepo})
    : super(const AddIncidentStates.initial());

  Future<void> submitIncident({required CurrentIncidentModel model}) async {
    if (state.maybeWhen(loading: () => true, orElse: () => false)) return;
    emit(const AddIncidentStates.loading());

    final result = await addIncdientRepo.addIncdient(model);

    result.when(
      success: (data) {
        lastSubmissionQueued = data is Map && data['__offline'] == true;
        emit(const AddIncidentStates.success());
      },
      error: (e) => emit(AddIncidentStates.error(e)),
    );
  }
}
