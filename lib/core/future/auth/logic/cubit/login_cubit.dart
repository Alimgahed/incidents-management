import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_model.dart';
import 'package:incidents_managment/core/future/auth/data/repo/login/login.dart';
import 'package:incidents_managment/core/future/auth/logic/state/login_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit({required this.loginRepo}) : super(const LoginState.initial());

  Future<void> login(LoginModel loginModel) async {
    emit(const LoginState.loading());
        
        final response = await loginRepo.login(loginModel);
    response.when(
      success: (data) {
        emit(LoginState.loaded(data));
      },
      error: (e) => emit(LoginState.error(e.error??'error')),
    );
  }
}