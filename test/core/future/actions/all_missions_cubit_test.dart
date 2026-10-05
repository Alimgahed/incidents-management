import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/get_missions-repo.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

void main() {
  late Dio dio;
  late _FakeMissionsRepo repository;
  late AllMissionsCubit cubit;

  setUp(() {
    dio = Dio();
    repository = _FakeMissionsRepo(apiService: ApiService(dio));
    cubit = AllMissionsCubit(allMissionsRepo: repository);
  });

  tearDown(() async {
    await cubit.close();
    dio.close(force: true);
  });

  test(
    'coalesces concurrent loads and exposes loading then loaded states',
    () async {
      final completer = Completer<ApiResult<List<AllMissionModel>>>();
      repository.nextResult = completer.future;
      final first = cubit.getAllMissions();
      final second = cubit.getAllMissions();

      expect(repository.calls, 1);
      expect(cubit.state, isA<GetAllMissionStateLoading>());
      completer.complete(
        ApiResult.success([
          AllMissionModel(missionId: 7, missionName: 'Pump repair', classId: 2),
        ]),
      );
      await Future.wait([first, second]);

      expect(cubit.state, isA<GetAllMissionStateLoaded>());
      expect(
        (cubit.state as GetAllMissionStateLoaded).data.single.missionId,
        7,
      );
    },
  );

  test('search tolerates null class names and can be cleared', () async {
    await cubit.getAllMissions();
    cubit.searchMissions('plumbing');
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final filtered = cubit.state as GetAllMissionStateLoaded;
    expect(filtered.data.single.missionId, 2);
    cubit.searchMissions('not found');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final noMatches = cubit.state as GetAllMissionStateLoaded;
    expect(noMatches.data, isEmpty);
    cubit.clearSearch();
    expect((cubit.state as GetAllMissionStateLoaded).data, hasLength(2));
  });

  test('reports repository errors and allows a later retry', () async {
    repository.nextResult = Future.value(
      ApiResult<List<AllMissionModel>>.error(
        ApiErrorModel(error: 'network unavailable'),
      ),
    );
    await cubit.getAllMissions();
    expect(cubit.state, isA<GetAllMissionStateError>());

    repository.nextResult = Future.value(ApiResult.success(const []));
    await cubit.getAllMissions();
    expect(cubit.state, isA<GetAllMissionStateLoaded>());
    expect((cubit.state as GetAllMissionStateLoaded).data, isEmpty);
    expect(repository.calls, 2);
  });
}

class _FakeMissionsRepo extends AllMissionsRepo {
  _FakeMissionsRepo({required super.apiService});

  int calls = 0;
  Future<ApiResult<List<AllMissionModel>>>? nextResult;

  @override
  Future<ApiResult<List<AllMissionModel>>> getAllMissions() {
    calls++;
    return nextResult ??
        Future.value(
          ApiResult.success([
            AllMissionModel(
              missionId: 1,
              missionName: 'Water network response',
              classId: 1,
              className: null,
            ),
            AllMissionModel(
              missionId: 2,
              missionName: 'Repair valves',
              classId: 2,
              className: 'Plumbing',
            ),
          ]),
        );
  }
}
