import 'package:equatable/equatable.dart';
import 'package:incidents_managment/core/future/valve/data/model/all_valves_response.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

abstract class WebValveMapState extends Equatable {
  const WebValveMapState();

  @override
  List<Object?> get props => [];
}

class WebValveMapInitial extends WebValveMapState {
  const WebValveMapInitial();
}

class WebValveMapLoading extends WebValveMapState {
  const WebValveMapLoading();
}

class WebValveMapLoaded extends WebValveMapState {
  final List<ValveModel> valves;
  final ValveFilterOptions filters;
  final ValvePagination pagination;
  final MapBounds? bounds;
  final bool isRefreshing;

  const WebValveMapLoaded({
    required this.valves,
    this.filters = const ValveFilterOptions(),
    this.pagination = const ValvePagination(),
    this.bounds,
    this.isRefreshing = false,
  });

  WebValveMapLoaded copyWith({
    List<ValveModel>? valves,
    ValveFilterOptions? filters,
    ValvePagination? pagination,
    MapBounds? bounds,
    bool? isRefreshing,
  }) {
    return WebValveMapLoaded(
      valves: valves ?? this.valves,
      filters: filters ?? this.filters,
      pagination: pagination ?? this.pagination,
      bounds: bounds ?? this.bounds,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [valves, filters, pagination, bounds, isRefreshing];
}

class WebValveMapError extends WebValveMapState {
  final String message;

  const WebValveMapError(this.message);

  @override
  List<Object?> get props => [message];
}
