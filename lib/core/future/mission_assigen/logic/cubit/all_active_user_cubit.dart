import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/repo/all_active_user_repo.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AllActiveUserCubit extends Cubit<AllActiveUserState> {
  final AllActiveUserRepo allActiveUserRepo;

  AllActiveUserCubit({required this.allActiveUserRepo})
    : super(const AllActiveUserState.initial()) {
    print("Cubit CREATED");
  }

  Future<void> allActiveUsers() async {
    print("allActiveUsers");
    emit(const AllActiveUserState.loading());

    final result = await allActiveUserRepo.allActiveUsers();

    result.when(
      success: (data) => emit(AllActiveUserState.loaded(data)),
      error: (e) => emit(AllActiveUserState.error(e.error ?? 'Unknown error')),
    );
  }
}
