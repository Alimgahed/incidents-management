import 'package:equatable/equatable.dart';

class IncidentTypeFilterState extends Equatable {
  final String searchName;
  final String? className;
  final String? missionCountFilter;

  const IncidentTypeFilterState({
    this.searchName = '',
    this.className,
    this.missionCountFilter,
  });

  IncidentTypeFilterState copyWith({
    String? searchName,
    String? className,
    String? missionCountFilter,
    bool clearClassName = false,
    bool clearMissionCountFilter = false,
  }) {
    return IncidentTypeFilterState(
      searchName: searchName ?? this.searchName,
      className: clearClassName ? null : (className ?? this.className),
      missionCountFilter: clearMissionCountFilter ? null : (missionCountFilter ?? this.missionCountFilter),
    );
  }

  bool get hasActiveFilters =>
      searchName.isNotEmpty ||
      className != null ||
      missionCountFilter != null;

  @override
  List<Object?> get props => [
        searchName,
        className,
        missionCountFilter,
      ];
}
