import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';

part 'incident_missions_state.freezed.dart';

@freezed
class AddincidentMissionsstates with _$AddincidentMissionsstates {
  const factory AddincidentMissionsstates.initial() =
      initialAddincidentMissionsstates;
  const factory AddincidentMissionsstates.loading() =
      loadingAddincidentMissionsstates;
  const factory AddincidentMissionsstates.success() =
      successAddincidentMissionsstates;
  const factory AddincidentMissionsstates.error(ApiErrorModel message) =
      errorAddincidentMissionsstates;
}
