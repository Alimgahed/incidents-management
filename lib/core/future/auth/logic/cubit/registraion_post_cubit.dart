import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/auth/data/repo/registration/registration_post.dart';
import 'package:incidents_managment/core/future/auth/logic/state/registeration_post_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class RegistrationPostCubit extends Cubit<RegistrationPostState> {
  final RegistrationPost registrationPost;
  RegistrationPostCubit({required this.registrationPost})
    : super(const RegistrationPostState.initial());
  Future<void> register(ActiveUser user) async {
    emit(const RegistrationPostState.loading());
    
    final response = await registrationPost.register(user);
    response.when(
      success: (data) {
        emit(RegistrationPostState.loaded(data));
      },
      error: (e) => emit(RegistrationPostState.error(e)),
    );
  }
}