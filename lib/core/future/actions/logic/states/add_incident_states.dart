import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_incident_states.freezed.dart';

@freezed
abstract class AddIncidentState with _$AddIncidentState {
  const factory AddIncidentState({
    String? selectedTypeId,
    String? selectedTypeName,
    String? selectedSeverity,
    @Default('') String description, // Default value for description
    @Default('') String address, // Default value for address
  }) = _AddIncidentState;

  factory AddIncidentState.initial() => AddIncidentState(
    selectedTypeId: null,
    selectedTypeName: null,
    selectedSeverity: 'متوسطة', // Default severity
    description: '',
    address: '',
  );
}
