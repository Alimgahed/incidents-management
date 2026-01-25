import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/get_missions-repo.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'dart:async';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';

class AllMissionsCubit extends Cubit<GetAllMissionState> {
  final AllMissionsRepo allMissionsRepo;

  // Cache for original data
  List<AllMissionModel> _allMissions = [];

  // Debounce timer for search
  Timer? _debounceTimer;

  // Current search query
  String _currentSearchQuery = '';

  AllMissionsCubit({required this.allMissionsRepo})
    : super(const GetAllMissionState.initial());

  Future<void> getAllMissions() async {
    emit(const GetAllMissionState.loading());

    final result = await allMissionsRepo.getAllMissions();

    result.when(
      success: (data) {
        _allMissions = data;
        _currentSearchQuery = '';
        emit(GetAllMissionState.loaded(data));
      },
      error: (e) => emit(GetAllMissionState.error(e.error ?? 'Unknown error')),
    );
  }

  void searchMissions(String query) {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Update current query
    _currentSearchQuery = query.trim();

    // If query is empty, show all missions
    if (_currentSearchQuery.isEmpty) {
      emit(GetAllMissionState.loaded(_allMissions));
      return;
    }

    // Debounce search - wait 300ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_currentSearchQuery);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      emit(GetAllMissionState.loaded(_allMissions));
      return;
    }

    final lowercaseQuery = query.toLowerCase();

    final filteredMissions = _allMissions.where((mission) {
      final missionNameMatch = mission.missionName.toLowerCase().contains(
        lowercaseQuery,
      );
      final classNameMatch = mission.className!.toLowerCase().contains(
        lowercaseQuery,
      );
      final missionIdMatch = mission.missionId.toString().contains(query);

      return missionNameMatch || classNameMatch || missionIdMatch;
    }).toList();

    emit(GetAllMissionState.loaded(filteredMissions));
  }

  void clearSearch() {
    _currentSearchQuery = '';
    _debounceTimer?.cancel();
    emit(GetAllMissionState.loaded(_allMissions));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
