import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
part 'add_missions_states.freezed.dart';

@freezed
class AddMissionsState with _$AddMissionsState {
  const factory AddMissionsState.initial() = _addmissionsInitial;
  const factory AddMissionsState.loading() = _addmissionsLoading;
  const factory AddMissionsState.success() = _addmissionsSuccess;
  const factory AddMissionsState.error(ApiErrorModel message) =
      _addmissionsError;
  const factory AddMissionsState.inputChanged({
    int? selectedClassId,
    String? missionName,
    bool? isFormValid,
  }) = _InputChanged;
}
