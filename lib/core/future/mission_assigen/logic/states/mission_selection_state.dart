import 'package:freezed_annotation/freezed_annotation.dart';
part 'mission_selection_state.freezed.dart';

@freezed
abstract class MissionSelectionState with _$MissionSelectionState {
  const factory MissionSelectionState({
    @Default({}) Map<int, Set<dynamic>> missionUserMap,
    int? activeMissionId,
    @Default('') String searchQuery,
    @Default(null) String? selectedAuthority,
    @Default(null) String? selectedSector,
  }) = _MissionSelectionState;
}
