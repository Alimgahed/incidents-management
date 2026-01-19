import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';

part 'add_incident_type_states.freezed.dart';

@freezed
class AddIncidentTypeState with _$AddIncidentTypeState {
  const factory AddIncidentTypeState.initial() = _Initial;
  const factory AddIncidentTypeState.loading() = _Loading;
  const factory AddIncidentTypeState.success() = _Success;
  const factory AddIncidentTypeState.error(ApiErrorModel message) = _Error;

  // State to track form validation or input changes
  const factory AddIncidentTypeState.inputChanged({
    int? selectedClassId,
    String? incidentName,
    bool? isFormValid,
  }) = _InputChanged;
}
