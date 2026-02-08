import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
part 'edit_incident.freezed.dart';

@freezed
class EditIncidentStates with _$EditIncidentStates {
  const factory EditIncidentStates.initial() = EditIncidentStatesInitial;
  const factory EditIncidentStates.loading() = EditIncidentStatesLoading;
  const factory EditIncidentStates.success() = EditIncidentStatesSuccess;
  const factory EditIncidentStates.error(ApiErrorModel message) =
      EditIncidentStatesError;
}
