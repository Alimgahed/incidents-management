import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/actions/data/models/all_incident_classes.dart';
part 'all_incident_classes.freezed.dart';

@freezed
class GetAllIncidentClassesState with _$GetAllIncidentClassesState {
  const factory GetAllIncidentClassesState.initial() =
      GetAllIncidentClassesStateInitial;
  const factory GetAllIncidentClassesState.loading() =
      GetAllIncidentClassesStateLoading;
  const factory GetAllIncidentClassesState.loaded(List<IncidentClass> data) =
      GetAllIncidentClassesStateLoaded;
  const factory GetAllIncidentClassesState.error(String message) =
      GetAllIncidentClassesStateError;
}
