import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

class MapFilterState extends Equatable {
  final String searchQuery;
  final int? branchId;
  final int? severityId;
  final int? statusId;
  final String? typeName; // Type usually string in currentIncidentTypeName

  const MapFilterState({
    this.searchQuery = '',
    this.branchId,
    this.severityId,
    this.statusId,
    this.typeName,
  });

  MapFilterState copyWith({
    String? searchQuery,
    int? Function()? branchId,
    int? Function()? severityId,
    int? Function()? statusId,
    String? Function()? typeName,
  }) {
    return MapFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      branchId: branchId != null ? branchId() : this.branchId,
      severityId: severityId != null ? severityId() : this.severityId,
      statusId: statusId != null ? statusId() : this.statusId,
      typeName: typeName != null ? typeName() : this.typeName,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        branchId,
        severityId,
        statusId,
        typeName,
      ];
}

class MapFilterCubit extends Cubit<MapFilterState> {
  MapFilterCubit() : super(const MapFilterState());

  void updateSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateBranch(int? branchId) {
    emit(state.copyWith(branchId: () => branchId));
  }

  void updateSeverity(int? severityId) {
    emit(state.copyWith(severityId: () => severityId));
  }

  void updateStatus(int? statusId) {
    emit(state.copyWith(statusId: () => statusId));
  }

  void updateType(String? typeName) {
    emit(state.copyWith(typeName: () => typeName));
  }

  void clearFilters() {
    emit(const MapFilterState());
  }

  /// Filters the incoming list of incidents based on the current state.
  List<CurrentIncidentModel> filterIncidents(
      List<CurrentIncidentModel> incidents) {
    return incidents.where((incident) {
      if (state.branchId != null && incident.branchId != state.branchId) {
        return false;
      }
      if (state.severityId != null &&
          incident.currentIncidentSeverity != state.severityId) {
        return false;
      }
      if (state.statusId != null &&
          incident.currentIncidentStatus != state.statusId) {
        return false;
      }
      if (state.typeName != null &&
          incident.currentIncidentTypeName != state.typeName) {
        return false;
      }
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        final matchDesc = incident.currentIncidentDescription?.toLowerCase().contains(query) ?? false;
        final matchId = incident.currentIncidentId?.toString().contains(query) ?? false;
        final matchAddress = incident.address?.toLowerCase().contains(query) ?? false;
        if (!matchDesc && !matchId && !matchAddress) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
