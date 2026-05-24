part of 'valves_map_cubit.dart';

abstract class ValvesMapState extends Equatable {
  const ValvesMapState();

  @override
  List<Object?> get props => [];
}

class ValvesMapInitial extends ValvesMapState {
  const ValvesMapInitial();
}

class ValvesMapLoading extends ValvesMapState {
  const ValvesMapLoading();
}

class ValvesMapLoaded extends ValvesMapState {
  final List<ValveEntity> valves;

  const ValvesMapLoaded({required this.valves});

  @override
  List<Object?> get props => [valves];
}

class ValvesMapError extends ValvesMapState {
  final String message;

  const ValvesMapError({required this.message});

  @override
  List<Object?> get props => [message];
}
