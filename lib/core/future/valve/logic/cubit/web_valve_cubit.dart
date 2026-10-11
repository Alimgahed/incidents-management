import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/valve/data/model/all_valves_response.dart';
import 'package:incidents_managment/core/future/valve/data/repo/valve_repo.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/valve_filter_cubit.dart';
import 'package:incidents_managment/core/future/valve/logic/state/web_valve_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class WebValveMapCubit extends Cubit<WebValveMapState> {
  final ValveRepo _valveRepository;
  Timer? _boundsDebounce;
  MapBounds? _bounds;
  ValveFilterState _filters = const ValveFilterState();
  int _requestId = 0;

  WebValveMapCubit({
    required ValveRepo valveRepository,
  })  : _valveRepository = valveRepository,
        super(const WebValveMapInitial());

  Future<void> fetchValves({bool showFullLoading = true}) async {
    await _loadValves(showFullLoading: showFullLoading);
  }

  void applyFilters(ValveFilterState filters) {
    _filters = filters;
    _loadValves(showFullLoading: state is! WebValveMapLoaded);
  }

  void updateMapBounds(MapBounds bounds) {
    _bounds = bounds;
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadValves(showFullLoading: state is! WebValveMapLoaded);
    });
  }

  Future<void> _loadValves({required bool showFullLoading}) async {
    final requestId = ++_requestId;
    final previousLoaded = switch (state) {
      final WebValveMapLoaded loaded => loaded,
      _ => null,
    };

    if (showFullLoading && previousLoaded == null) {
      emit(const WebValveMapLoading());
    } else if (previousLoaded != null) {
      emit(previousLoaded.copyWith(isRefreshing: true, bounds: _bounds));
    }

    try {
      final result = await _valveRepository.allValves(
        bounds: _bounds,
        valveTypeId: _filters.valveTypeId,
        status: _filters.status,
        diameter: _filters.diameter,
        pipeDiameter: _filters.pipeDiameter,
        direction: _filters.direction,
        inServiceYear: _filters.inServiceYear,
      );
      if (isClosed || requestId != _requestId) return;

      result.when(
        success: (response) {
          emit(WebValveMapLoaded(
            valves: response.data,
            filters: response.filters ?? const ValveFilterOptions(),
            pagination: response.pagination ?? const ValvePagination(),
            bounds: _bounds,
            isRefreshing: false,
          ));
        },
        error: (error) {
          if (previousLoaded != null) {
            emit(previousLoaded.copyWith(isRefreshing: false));
          } else {
            emit(WebValveMapError('فشل تحميل بيانات المحابس: $error'));
          }
        },
      );
    } catch (e) {
      if (isClosed || requestId != _requestId) return;
      if (previousLoaded != null) {
        emit(previousLoaded.copyWith(isRefreshing: false));
      } else {
        emit(WebValveMapError('فشل تحميل بيانات المحابس: $e'));
      }
    }
  }

  @override
  Future<void> close() {
    _boundsDebounce?.cancel();
    return super.close();
  }
}
