import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/actions/data/models/all_incident_type.dart';

part 'get_all_incident_type_states.freezed.dart';

@freezed
class GetAllIncidentTypeState with _$GetAllIncidentTypeState {
  const factory GetAllIncidentTypeState.initial() =
      GetAllIncidentTypeStateInitial;
  const factory GetAllIncidentTypeState.loading() =
      GetAllIncidentTypeStateLoading;
  const factory GetAllIncidentTypeState.loaded(List<IncidentType> data) =
      GetAllIncidentTypeStateLoaded;
  const factory GetAllIncidentTypeState.error(String message) =
      GetAllIncidentTypeStateError;
}
