import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/logic/states/update_statues.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class UpdateStatuesCubit extends Cubit<UpdateStatuesStates> {
  final UpdateStatuesRepo updateStatuesRepo;

  UpdateStatuesCubit({required this.updateStatuesRepo})
    : super(const UpdateStatuesStates.initial());

  Future<void> updateStatues({
    required int incidentid,
    required int missionid,
    required int statusid,
    required int orderid,
  }) async {
    emit(const UpdateStatuesStates.loading());

    final model = CurrentIncidentWithMissions(
      currentIncidentMissionStatus: statusid,
    );

    final result = await updateStatuesRepo.updateStatues(
      model,
      incidentid,
      missionid,
      orderid,
    );

    result.when(
      success: (_) => emit(const UpdateStatuesStates.success()),
      error: (e) => emit(UpdateStatuesStates.error(e)),
    );
  }
}
