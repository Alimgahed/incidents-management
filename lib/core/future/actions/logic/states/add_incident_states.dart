import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
part 'add_incident_states.freezed.dart';

@freezed
class AddIncidentStates with _$AddIncidentStates {
  const factory AddIncidentStates.initial() = AddIncidentStatesInitial;
  const factory AddIncidentStates.loading() = AddIncidentStatesLoading;
  const factory AddIncidentStates.success() = AddIncidentStatesSuccess;
  const factory AddIncidentStates.error(ApiErrorModel message) =
      AddIncidentStatesError;
}
