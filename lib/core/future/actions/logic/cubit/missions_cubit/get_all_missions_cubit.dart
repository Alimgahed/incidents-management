import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/get_missions-repo.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AllMissionsCubit extends Cubit<GetAllMissionState> {
  final AllMissionsRepo allMissionsRepo;

  // Cache for original data
  List<AllMissionModel> _allMissions = [];
  bool _isRefreshing = false;

  // Debounce timer for search
  Timer? _debounceTimer;

  // Current search query
  String _currentSearchQuery = '';
  Future<void>? _loadInFlight;

  List<AllMissionModel> get cachedMissions => List.unmodifiable(_allMissions);
  bool get isRefreshing => _isRefreshing;

  AllMissionsCubit({required this.allMissionsRepo})
    : super(const GetAllMissionState.initial());

  Future<void> getAllMissions({bool forceLoading = false}) {
    final inFlight = _loadInFlight;
    if (inFlight != null) return inFlight;
    final request = _loadMissions(forceLoading: forceLoading);
    _loadInFlight = request;
    return request.whenComplete(() => _loadInFlight = null);
  }

  Future<void> _loadMissions({required bool forceLoading}) async {
    if (_allMissions.isEmpty || forceLoading) {
      emit(const GetAllMissionState.loading());
    } else {
      _isRefreshing = true;
      emit(GetAllMissionState.loaded(_allMissions));
    }

    final result = await allMissionsRepo.getAllMissions();
    _isRefreshing = false;
    if (isClosed) return;

    result.when(
      success: (data) {
        _allMissions = data;
        if (_currentSearchQuery.isNotEmpty) {
          _performSearch(_currentSearchQuery);
        } else {
          emit(GetAllMissionState.loaded(data));
        }
      },
      error: (e) {
        if (_allMissions.isNotEmpty && !forceLoading) {
          emit(GetAllMissionState.loaded(_allMissions));
        } else {
          emit(GetAllMissionState.error(e.error ?? 'Unknown error'));
        }
      },
    );
  }

  void searchMissions(String query) {
    _debounceTimer?.cancel();
    _currentSearchQuery = query.trim();

    if (_currentSearchQuery.isEmpty) {
      emit(GetAllMissionState.loaded(_allMissions));
      return;
    }

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
      final classNameMatch = (mission.className ?? '').toLowerCase().contains(
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
