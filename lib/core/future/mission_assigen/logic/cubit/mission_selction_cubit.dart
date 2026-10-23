import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';

class MissionSelectionCubit extends Cubit<MissionSelectionState> {
  MissionSelectionCubit() : super(const MissionSelectionState());

  // ─── Active Missions ─────────────────────────────────────────────
  /// Returns all currently selected mission IDs.
  Set<int> get activeMissionIds {
    if (state.selectedMissionIds.isNotEmpty) {
      return state.selectedMissionIds;
    }
    if (state.activeMissionId != null) {
      return {state.activeMissionId!};
    }
    return {};
  }

  bool isMissionSelected(int missionId) {
    if (state.selectedMissionIds.isNotEmpty) {
      return state.selectedMissionIds.contains(missionId);
    }
    return state.activeMissionId == missionId;
  }

  // ─── Mission Selection ───────────────────────────────────────────
  void setActiveMission(int missionId) {
    emit(state.copyWith(
      activeMissionId: missionId,
      selectedMissionIds: {missionId},
    ));
  }

  void toggleMissionSelection(int missionId) {
    final current = Set<int>.from(state.selectedMissionIds);
    // If currently empty and activeMissionId was set, seed current
    if (current.isEmpty && state.activeMissionId != null) {
      current.add(state.activeMissionId!);
    }

    if (current.contains(missionId)) {
      current.remove(missionId);
    } else {
      current.add(missionId);
    }

    if (current.isEmpty) {
      emit(state.copyWith(
        selectedMissionIds: {},
        clearActiveMission: true,
      ));
    } else {
      emit(state.copyWith(
        selectedMissionIds: current,
        activeMissionId: current.last,
      ));
    }
  }

  void selectAllMissions(List<int> allMissionIds) {
    final current = Set<int>.from(state.selectedMissionIds);
    final allSet = allMissionIds.toSet();
    final isAllSelected =
        allSet.isNotEmpty && allSet.every((id) => current.contains(id));

    if (isAllSelected) {
      // Clear selection
      emit(state.copyWith(
        selectedMissionIds: {},
        clearActiveMission: true,
      ));
    } else {
      emit(state.copyWith(
        selectedMissionIds: allSet,
        activeMissionId: allMissionIds.isNotEmpty ? allMissionIds.first : null,
      ));
    }
  }

  void clearMissionSelection() {
    emit(state.copyWith(
      selectedMissionIds: {},
      clearActiveMission: true,
    ));
  }

  // ─── User Toggle ─────────────────────────────────────────────────
  void toggleUser(dynamic user) {
    final targets = activeMissionIds;
    if (targets.isEmpty) return;

    final updatedMap = Map<int, Set<dynamic>>.from(
      state.missionUserMap.map((k, v) => MapEntry(k, Set<dynamic>.from(v))),
    );

    // If user is already present in all targeted missions, remove from all; otherwise add to all
    final inAll =
        targets.every((mId) => (updatedMap[mId] ?? {}).contains(user));

    for (final mId in targets) {
      final set = updatedMap.putIfAbsent(mId, () => {});
      if (inAll) {
        set.remove(user);
      } else {
        set.add(user);
      }
    }

    emit(state.copyWith(missionUserMap: updatedMap));
  }

  // ─── Select / Deselect All Filtered Users ────────────────────────
  void toggleAllUsers(List<dynamic> filteredUsers) {
    final targets = activeMissionIds;
    if (targets.isEmpty || filteredUsers.isEmpty) return;

    final updatedMap = Map<int, Set<dynamic>>.from(
      state.missionUserMap.map((k, v) => MapEntry(k, Set<dynamic>.from(v))),
    );

    final allAssigned = filteredUsers.every(
      (u) => targets.every((mId) => (updatedMap[mId] ?? {}).contains(u)),
    );

    for (final mId in targets) {
      final set = updatedMap.putIfAbsent(mId, () => {});
      if (allAssigned) {
        for (final u in filteredUsers) {
          set.remove(u);
        }
      } else {
        set.addAll(filteredUsers);
      }
    }

    emit(state.copyWith(missionUserMap: updatedMap));
  }

  // ─── Filters ─────────────────────────────────────────────────────
  void updateSearch(String query) => emit(state.copyWith(searchQuery: query));

  void updateAuthority(String? authority) =>
      emit(state.copyWith(selectedAuthority: authority));

  void updateSector(String? sector) =>
      emit(state.copyWith(selectedSector: sector));

  // ─── Reset after success ─────────────────────────────────────────
  void reset() => emit(const MissionSelectionState());

  // ─── Helpers ─────────────────────────────────────────────────────
  Set<dynamic> activeUsers(int? missionId) =>
      missionId != null ? (state.missionUserMap[missionId] ?? {}) : {};

  /// Check whether a user is assigned to all currently targeted missions
  bool isUserSelected(dynamic user) {
    final targets = activeMissionIds;
    if (targets.isEmpty) return false;
    return targets
        .every((mId) => (state.missionUserMap[mId] ?? {}).contains(user));
  }

  /// Check whether a user is assigned to at least one targeted mission
  bool isUserPartiallySelected(dynamic user) {
    final targets = activeMissionIds;
    if (targets.isEmpty) return false;
    return targets
        .any((mId) => (state.missionUserMap[mId] ?? {}).contains(user));
  }

  /// Number of users assigned to all targeted missions from [users]
  int countSelectedUsersInTargets(List<dynamic> users) {
    return users.where((u) => isUserSelected(u)).length;
  }

  int get assignedMissionsCount =>
      state.missionUserMap.values.where((s) => s.isNotEmpty).length;

  bool get canAssign => assignedMissionsCount > 0;
}
