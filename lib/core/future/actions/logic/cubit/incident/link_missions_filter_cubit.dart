import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/states/link_missions_filter_state.dart';

class LinkMissionsFilterCubit extends Cubit<LinkMissionsFilterState> {
  LinkMissionsFilterCubit() : super(const LinkMissionsFilterState());

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
    emit(const LinkMissionsFilterState());
  }

  List<AllMissionModel> filterMissions(List<AllMissionModel> allMissions) {
    return allMissions.where((mission) {
      if (state.searchName.isNotEmpty) {
        final query = state.searchName.toLowerCase();
        final nameMatches = mission.missionName.toLowerCase().contains(query);
        if (!nameMatches) return false;
      }
      
      if (state.className != null && state.className!.isNotEmpty) {
        if (mission.className != state.className) return false;
      }

      return true;
    }).toList();
  }
}
