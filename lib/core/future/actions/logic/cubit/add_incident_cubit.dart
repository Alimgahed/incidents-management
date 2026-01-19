import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';

class AddIncidentCubit extends Cubit<AddIncidentState> {
  AddIncidentCubit() : super(AddIncidentState.initial());

  void setType(String? typeId, String? typeName) {
    emit(state.copyWith(selectedTypeId: typeId, selectedTypeName: typeName));
  }

  void setSeverity(String severity) {
    emit(state.copyWith(selectedSeverity: severity));
  }

  void setDescription(String description) {
    emit(state.copyWith(description: description));
  }

  void setAddress(String address) {
    emit(state.copyWith(address: address));
  }
}
