import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/valve/data/repo/valve_repo.dart';
import 'package:incidents_managment/core/future/valve/logic/state/web_valve_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class WebValveMapCubit extends Cubit<WebValveMapState> {
  final ValveRepo _valveRepository;

  WebValveMapCubit({
    required ValveRepo valveRepository,
  })  : _valveRepository = valveRepository,
        super(const WebValveMapInitial());

  Future<void> fetchValves() async {
    emit(const WebValveMapLoading());

    try {
      final result = await _valveRepository.allValves();
      result.when(
        success: (valves) {
          emit(WebValveMapLoaded(valves: valves));
        },
        error: (error) {
          emit(WebValveMapError('فشل تحميل بيانات المحابس: $error'));
        },
      );
    } catch (e) {
      emit(WebValveMapError('فشل تحميل بيانات المحابس: $e'));
    }
  }
}
