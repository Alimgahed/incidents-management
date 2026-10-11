import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/states/missions_filter_state.dart';

class MissionsFilterCubit extends Cubit<MissionsFilterState> {
  MissionsFilterCubit() : super(const MissionsFilterState());

  void updateFilters({
    String? searchName,
    String? className,
    bool clearClassName = false,
  }) {
    emit(state.copyWith(
      searchName: searchName,
      className: className,
      clearClassName: clearClassName,
    ));
  }

  void resetFilters() {
    emit(const MissionsFilterState());
  }

  List<AllMissionModel> filterMissions(List<AllMissionModel> missions) {
    return missions.where((mission) {
      if (state.searchName.isNotEmpty) {
        final query = state.searchName.toLowerCase().trim();
        final nameMatches = mission.missionName.toLowerCase().contains(query);
        final classMatches = (mission.className ?? '').toLowerCase().contains(query);
        final idMatches = mission.missionId?.toString().contains(query) ?? false;
        if (!nameMatches && !classMatches && !idMatches) return false;
      }

      if (state.className != null && state.className!.isNotEmpty) {
        if (mission.className != state.className) return false;
      }

      return true;
    }).toList();
  }
}
