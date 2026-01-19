import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/future/actions/data/repos/all_incident_type_repo.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AllIncidentTypeCubit extends Cubit<GetAllIncidentTypeState> {
  final AllIncidentTypeRepo allIncidentTypeRepo;

  AllIncidentTypeCubit({required this.allIncidentTypeRepo})
    : super(const GetAllIncidentTypeState.initial());

  Future<void> getAllIncidentTypes() async {
    emit(const GetAllIncidentTypeState.loading());

    final result = await allIncidentTypeRepo.getAllIncidentTypes();

    result.when(
      success: (data) => emit(GetAllIncidentTypeState.loaded(data)),
      error: (e) =>
          emit(GetAllIncidentTypeState.error(e.error ?? 'Unknown error')),
    );
  }
}
