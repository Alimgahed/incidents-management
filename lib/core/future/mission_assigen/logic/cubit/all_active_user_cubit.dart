import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/repo/all_active_user_repo.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class AllActiveUserCubit extends Cubit<AllActiveUserState> {
  final AllActiveUserRepo allActiveUserRepo;

  List<ActiveUser> _cachedUsers = const [];
  bool _isRefreshing = false;
  Future<void>? _inFlight;

  List<ActiveUser> get cachedUsers => _cachedUsers;
  bool get isRefreshing => _isRefreshing;

  AllActiveUserCubit({required this.allActiveUserRepo})
    : super(const AllActiveUserState.initial());

  Future<void> allActiveUsers({bool forceLoading = false}) {
    final active = _inFlight;
    if (active != null) return active;
    final future = _fetchUsers(forceLoading: forceLoading);
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<void> _fetchUsers({required bool forceLoading}) async {
    if (_cachedUsers.isEmpty || forceLoading) {
      emit(const AllActiveUserState.loading());
    } else {
      _isRefreshing = true;
      emit(AllActiveUserState.loaded(_cachedUsers));
    }

    final result = await allActiveUserRepo.allActiveUsers();
    _isRefreshing = false;
    if (isClosed) return;

    result.when(
      success: (data) {
        _cachedUsers = List.unmodifiable(data);
        emit(AllActiveUserState.loaded(_cachedUsers));
      },
      error: (e) {
        if (_cachedUsers.isNotEmpty && !forceLoading) {
          emit(AllActiveUserState.loaded(_cachedUsers));
        } else {
          emit(AllActiveUserState.error(e.error ?? 'Unknown error'));
        }
      },
    );
  }
}
