import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/repos/all_incident_classes_rep.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AllIncidentClasses extends Cubit<GetAllIncidentClassesState> {
  final AllIncidentClassRepo allIncidentClassRepo;

  AllIncidentClasses({required this.allIncidentClassRepo})
    : super(const GetAllIncidentClassesState.initial());
  Future<void> getAllIncidentClasses() async {
    emit(const GetAllIncidentClassesState.loading());

    final result = await allIncidentClassRepo.getAllIncidentClasses();

    result.when(
      success: (data) => emit(GetAllIncidentClassesState.loaded(data)),
      error: (e) =>
          emit(GetAllIncidentClassesState.error(e.error ?? 'Unknown error')),
    );
  }
}
