import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_model.dart';
import 'package:incidents_managment/core/future/auth/data/repo/login/login.dart';
import 'package:incidents_managment/core/future/auth/logic/state/login_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

import 'package:incidents_managment/core/network/fcm_service.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit({required this.loginRepo}) : super(const LoginState.initial());

  Future<void> login(String username, String password) async {
    emit(const LoginState.loading());
    
    try {
      // Fetch FCM token while the loading spinner is active to prevent UI lag
      // Timeout increased to 6 seconds for slow external networks
      final fcmToken = await FcmService.getToken().timeout(
        const Duration(seconds: 6),
        onTimeout: () => null,
      );
      
      final loginModel = LoginModel(
        username: username,
        password: password,
        deviceToken: fcmToken ?? "",
      );
          
      final response = await loginRepo.login(loginModel);
      response.when(
        success: (data) {
          emit(LoginState.loaded(data));
        },
        error: (e) => emit(LoginState.error(e.error ?? 'error')),
      );
    } catch (e) {
      // Catch any unexpected parsing or type errors so the UI doesn't hang indefinitely
      emit(LoginState.error('حدث خطأ غير متوقع: $e'));
    }
  }
}