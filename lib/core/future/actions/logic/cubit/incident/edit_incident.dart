import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/states/edit_incident.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:latlong2/latlong.dart';

class EditIncidentCubit extends Cubit<EditIncidentStates> {
  final EditIncidentRepo editIncidentRepo;

  EditIncidentCubit({required this.editIncidentRepo})
    : super(const EditIncidentStates.initial());

  Future<void> submitIncident({
    required int id,
    required int typeId,
    required int status,
    required int severity,
    String? description,
    LatLng? location,
    required int branchId,
    String? notes,
  }) async {
    emit(const EditIncidentStates.loading());

    final model = CurrentIncidentModel(
      currentIncidentTypeId: typeId,
      currentIncidentDescription: description,
      currentIncidentXAxis: location?.latitude ?? 0,
      currentIncidentYAxis: location?.longitude ?? 0,
      currentIncidentStatus: status,
      currentIncidentSeverity: severity,
      branchId: branchId,
      currentIncidentNotes: notes,
    );

    final result = await editIncidentRepo.editIncident(model, id);

    result.when(
      success: (_) => emit(const EditIncidentStates.success()),
      error: (e) => emit(EditIncidentStates.error(e)),
    );
  }
}
