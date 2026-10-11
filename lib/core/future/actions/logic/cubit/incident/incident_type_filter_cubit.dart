import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/incident_type_filter_state.dart';

class IncidentTypeFilterCubit extends Cubit<IncidentTypeFilterState> {
  IncidentTypeFilterCubit() : super(const IncidentTypeFilterState());

  void updateFilters({
    String? searchName,
    String? className,
    String? missionCountFilter,
    bool clearClassName = false,
    bool clearMissionCountFilter = false,
  }) {
    emit(state.copyWith(
      searchName: searchName,
      className: className,
      missionCountFilter: missionCountFilter,
      clearClassName: clearClassName,
      clearMissionCountFilter: clearMissionCountFilter,
    ));
  }

  void resetFilters() {
    emit(const IncidentTypeFilterState());
  }

  List<IncidentType> filterIncidentTypes(List<IncidentType> incidentTypes) {
    return incidentTypes.where((type) {
      if (state.searchName.isNotEmpty) {
        final query = state.searchName.toLowerCase();
        final nameMatches = type.incidentTypeName.toLowerCase().contains(query);
        if (!nameMatches) return false;
      }
      
      if (state.className != null && state.className!.isNotEmpty) {
        if (type.className != state.className) return false;
      }

      if (state.missionCountFilter != null && state.missionCountFilter!.isNotEmpty) {
        final count = type.missions?.length ?? 0;
        switch (state.missionCountFilter) {
          case 'بدون مهام (0)':
            if (count != 0) return false;
            break;
          case 'من 1 إلى 5 مهام':
            if (count < 1 || count > 5) return false;
            break;
          case 'أكثر من 5 مهام':
            if (count <= 5) return false;
            break;
        }
      }

      return true;
    }).toList();
  }
}
