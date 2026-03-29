import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/auth/data/repo/registration/registration_get.dart';
import 'package:incidents_managment/core/future/auth/logic/state/registeration_get_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class RegistrationGetCubit extends Cubit<RegistrationGetState> {
  final RegistrationGet registrationGet;
  RegistrationGetCubit({required this.registrationGet})
    : super(const RegistrationGetState.initial());
  Future<void> getregister() async {
    emit(const RegistrationGetState.loading());
    
    final response = await registrationGet.getregister();
    response.when(
      success: (data) {
        emit(RegistrationGetState.loaded(data));
      },
      error: (e) => emit(RegistrationGetState.error(e.error ?? 'Unknown error')),
    );
  }
}