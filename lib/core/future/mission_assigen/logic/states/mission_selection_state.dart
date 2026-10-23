import 'package:equatable/equatable.dart';

class MissionSelectionState extends Equatable {
  final Map<int, Set<dynamic>> missionUserMap;
  final int? activeMissionId;
  final Set<int> selectedMissionIds;
  final String searchQuery;
  final String? selectedAuthority;
  final String? selectedSector;

  const MissionSelectionState({
    this.missionUserMap = const {},
    this.activeMissionId,
    this.selectedMissionIds = const {},
    this.searchQuery = '',
    this.selectedAuthority,
    this.selectedSector,
  });

  MissionSelectionState copyWith({
    Map<int, Set<dynamic>>? missionUserMap,
    int? activeMissionId,
    bool clearActiveMission = false,
    Set<int>? selectedMissionIds,
    String? searchQuery,
    String? selectedAuthority,
    String? selectedSector,
  }) {
    return MissionSelectionState(
      missionUserMap: missionUserMap ?? this.missionUserMap,
      activeMissionId:
          clearActiveMission ? null : (activeMissionId ?? this.activeMissionId),
      selectedMissionIds: selectedMissionIds ?? this.selectedMissionIds,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedAuthority: selectedAuthority ?? this.selectedAuthority,
      selectedSector: selectedSector ?? this.selectedSector,
    );
  }

  @override
  List<Object?> get props => [
        missionUserMap,
        activeMissionId,
        selectedMissionIds,
        searchQuery,
        selectedAuthority,
        selectedSector,
      ];
}
