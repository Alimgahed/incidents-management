import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';

class MissionSelectionCubit extends Cubit<MissionSelectionState> {
  MissionSelectionCubit() : super(MissionSelectionState());

  // ─── Mission Selection ───────────────────────────────────────────
  void setActiveMission(int missionId) {
    emit(state.copyWith(activeMissionId: missionId));
  }

  // ─── User Toggle ─────────────────────────────────────────────────
  void toggleUser(dynamic user) {
    final missionId = state.activeMissionId;
    if (missionId == null) return;

    final updatedMap = Map<int, Set<dynamic>>.from(
      state.missionUserMap.map((k, v) => MapEntry(k, Set<dynamic>.from(v))),
    );

    final set = updatedMap.putIfAbsent(missionId, () => {});
    if (set.contains(user)) {
      set.remove(user);
    } else {
      set.add(user);
    }

    emit(state.copyWith(missionUserMap: updatedMap));
  }

  // ─── Select / Deselect All Filtered Users ────────────────────────
  void toggleAllUsers(List<dynamic> filteredUsers) {
    final missionId = state.activeMissionId;
    if (missionId == null) return;

    final updatedMap = Map<int, Set<dynamic>>.from(
      state.missionUserMap.map((k, v) => MapEntry(k, Set<dynamic>.from(v))),
    );

    final set = updatedMap.putIfAbsent(missionId, () => {});
    if (set.length == filteredUsers.length) {
      set.clear();
    } else {
      set.addAll(filteredUsers);
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

  int get assignedMissionsCount =>
      state.missionUserMap.values.where((s) => s.isNotEmpty).length;

  bool get canAssign => assignedMissionsCount > 0;
}
