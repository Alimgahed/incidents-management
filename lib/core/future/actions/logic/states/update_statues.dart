import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
part 'update_statues.freezed.dart';

@freezed
class UpdateStatuesStates with _$UpdateStatuesStates {
  const factory UpdateStatuesStates.initial() = UpdateStatuesStatesInitial;
  const factory UpdateStatuesStates.loading() = UpdateStatuesStatesLoading;
  const factory UpdateStatuesStates.success() = UpdateStatuesStatesSuccess;
  const factory UpdateStatuesStates.error(ApiErrorModel message) =
      UpdateStatuesStatesError;
}
