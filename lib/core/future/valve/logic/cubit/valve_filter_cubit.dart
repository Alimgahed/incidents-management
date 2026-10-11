import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

part 'valve_filter_state.dart';

class ValveFilterCubit extends Cubit<ValveFilterState> {
  ValveFilterCubit() : super(const ValveFilterState());

  void updateSearchQuery(String? query) {
    emit(state.copyWith(
      searchQuery: query?.isEmpty ?? true ? null : query,
      clearSearchQuery: query?.isEmpty ?? true,
    ));
  }

  void updateStatus(String? status) {
    emit(state.copyWith(status: status, clearStatus: status == null));
  }

  void updateValveTypeId(int? id) {
    emit(state.copyWith(valveTypeId: id, clearValveTypeId: id == null));
  }

  void updateDiameter(int? diameter) {
    emit(state.copyWith(diameter: diameter, clearDiameter: diameter == null));
  }

  void updatePipeDiameter(int? pipeDiameter) {
    emit(state.copyWith(
      pipeDiameter: pipeDiameter,
      clearPipeDiameter: pipeDiameter == null,
    ));
  }

  void updateDirection(String? direction) {
    emit(state.copyWith(direction: direction, clearDirection: direction == null));
  }

  void updateInServiceYear(int? year) {
    emit(state.copyWith(
      inServiceYear: year,
      clearInServiceYear: year == null,
    ));
  }

  void clearFilters() {
    emit(ValveFilterState(searchQuery: state.searchQuery));
  }

  List<ValveModel> filterValves(List<ValveModel> rawValves) {
    final query = state.searchQuery?.toLowerCase();
    if (query == null) return rawValves;

    return rawValves.where((valve) {
      final matchesId = valve.id?.toString().contains(query) ?? false;
      final matchesName =
          valve.valveType?.displayName?.toLowerCase().contains(query) ?? false;
      return matchesId || matchesName;
    }).toList();
  }
}
