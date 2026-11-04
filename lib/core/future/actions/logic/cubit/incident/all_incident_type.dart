import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/future/actions/data/repos/all_incident_type_repo.dart';

class AllIncidentTypeCubit extends Cubit<GetAllIncidentTypeState> {
  final AllIncidentTypeRepo allIncidentTypeRepo;

  List<IncidentType> _cachedTypes = const [];
  bool _isRefreshing = false;
  Future<void>? _inFlight;

  List<IncidentType> get cachedTypes => _cachedTypes;
  bool get isRefreshing => _isRefreshing;

  AllIncidentTypeCubit({required this.allIncidentTypeRepo})
    : super(const GetAllIncidentTypeState.initial());

  Future<void> getAllIncidentTypes({bool forceLoading = false}) {
    final active = _inFlight;
    if (active != null) return active;
    final future = _fetchTypes(forceLoading: forceLoading);
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<void> _fetchTypes({required bool forceLoading}) async {
    if (_cachedTypes.isEmpty || forceLoading) {
      emit(const GetAllIncidentTypeState.loading());
    } else {
      _isRefreshing = true;
      emit(GetAllIncidentTypeState.loaded(_cachedTypes));
    }

    final result = await allIncidentTypeRepo.getAllIncidentTypes();
    _isRefreshing = false;
    if (isClosed) return;

    result.when(
      success: (data) {
        _cachedTypes = List.unmodifiable(data);
        emit(GetAllIncidentTypeState.loaded(_cachedTypes));
      },
      error: (e) {
        if (_cachedTypes.isNotEmpty && !forceLoading) {
          emit(GetAllIncidentTypeState.loaded(_cachedTypes));
        } else {
          emit(GetAllIncidentTypeState.error(e.error ?? 'Unknown error'));
        }
      },
    );
  }
}
