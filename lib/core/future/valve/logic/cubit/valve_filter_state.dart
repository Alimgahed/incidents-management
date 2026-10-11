part of 'valve_filter_cubit.dart';

class ValveFilterState extends Equatable {
  final String? searchQuery;
  final String? status;
  final int? valveTypeId;
  final int? diameter;
  final int? pipeDiameter;
  final String? direction;
  final int? inServiceYear;

  const ValveFilterState({
    this.searchQuery,
    this.status,
    this.valveTypeId,
    this.diameter,
    this.pipeDiameter,
    this.direction,
    this.inServiceYear,
  });

  ValveFilterState copyWith({
    String? searchQuery,
    bool clearSearchQuery = false,
    String? status,
    bool clearStatus = false,
    int? valveTypeId,
    bool clearValveTypeId = false,
    int? diameter,
    bool clearDiameter = false,
    int? pipeDiameter,
    bool clearPipeDiameter = false,
    String? direction,
    bool clearDirection = false,
    int? inServiceYear,
    bool clearInServiceYear = false,
  }) {
    return ValveFilterState(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      valveTypeId: clearValveTypeId ? null : (valveTypeId ?? this.valveTypeId),
      diameter: clearDiameter ? null : (diameter ?? this.diameter),
      pipeDiameter:
          clearPipeDiameter ? null : (pipeDiameter ?? this.pipeDiameter),
      direction: clearDirection ? null : (direction ?? this.direction),
      inServiceYear:
          clearInServiceYear ? null : (inServiceYear ?? this.inServiceYear),
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        status,
        valveTypeId,
        diameter,
        pipeDiameter,
        direction,
        inServiceYear,
      ];
}
