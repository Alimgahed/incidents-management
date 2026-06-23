import 'package:equatable/equatable.dart';
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
  
  const WebValveMapLoaded({required this.valves});

  @override
  List<Object?> get props => [valves];
}

class WebValveMapError extends WebValveMapState {
  final String message;
  
  const WebValveMapError(this.message);

  @override
  List<Object?> get props => [message];
}
