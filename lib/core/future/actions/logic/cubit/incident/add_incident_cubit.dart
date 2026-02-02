import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/add_incident/add_incdient_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:latlong2/latlong.dart';

class AddIncidentCubit extends Cubit<AddIncidentStates> {
  final AddIncdientRepo addIncdientRepo;

  AddIncidentCubit({required this.addIncdientRepo})
    : super(const AddIncidentStates.initial());

  Future<void> submitIncident({
    required int typeId,
    required int severity,
    required String description,
    required LatLng location,
    required int branchId,
  }) async {
    emit(const AddIncidentStates.loading());

    final model = CurrentIncidentModel(
      currentIncidentTypeId: typeId,
      currentIncidentDescription: description,
      currentIncidentXAxis: location.latitude,
      currentIncidentYAxis: location.longitude,
      currentIncidentStatus: 1, // تم التبليغ
      currentIncidentSeverity: severity,
      branchId: branchId,
      currentIncidentNotes: "تم انقطاع المياة",
    );

    final result = await addIncdientRepo.addIncdient(model);

    result.when(
      success: (_) => emit(const AddIncidentStates.success()),
      error: (e) => emit(AddIncidentStates.error(e)),
    );
  }
}
