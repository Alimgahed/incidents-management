import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';
import 'package:incidents_managment/features/valves_map/domain/usecases/get_valves_uc.dart';

part 'valves_map_state.dart';

class ValvesMapCubit extends Cubit<ValvesMapState> {
  final GetValvesUseCase getValvesUseCase;

  ValvesMapCubit(this.getValvesUseCase) : super(const ValvesMapInitial());

  Future<void> loadValves({bool forceRefresh = false}) async {
    if (state is! ValvesMapLoaded) {
      emit(const ValvesMapLoading());
    }

    try {
      final valves = await getValvesUseCase(forceRefresh: forceRefresh);
      emit(ValvesMapLoaded(valves: valves));
    } catch (e) {
      emit(ValvesMapError(message: e.toString()));
    }
  }
}
