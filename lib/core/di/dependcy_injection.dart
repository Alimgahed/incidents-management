import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:incidents_managment/core/future/actions/data/repos/add_incident/add_incdient_repo.dart';
import 'package:incidents_managment/core/future/actions/data/repos/classes_repo/all_incident_classes_rep.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/data/repos/incident_missions_repo.dart/incident_missions.dart';
import 'package:incidents_managment/core/future/actions/data/repos/incident_type_repo/add_incident_type_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/update_statues.dart';
import 'package:incidents_managment/core/future/auth/data/repo/login/login.dart';
import 'package:incidents_managment/core/future/auth/data/repo/registration/registration_get.dart';
import 'package:incidents_managment/core/future/auth/data/repo/registration/registration_post.dart';
import 'package:incidents_managment/core/future/auth/logic/cubit/login_cubit.dart';
import 'package:incidents_managment/core/future/auth/logic/cubit/registraion_post_cubit.dart';
import 'package:incidents_managment/core/future/auth/logic/cubit/registration_get_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/repo/all_active_user_repo.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/repo/mission_assign_repo.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_assign_cubit.dart';
import 'package:incidents_managment/core/future/mobile/data/repo/file_upload_repo.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_cubit.dart';
import 'package:incidents_managment/core/future/valve/data/repo/valve_repo.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/alarm_service.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/service.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/valve_cubit.dart';
import 'package:incidents_managment/future/actions/data/repos/all_incident_type_repo.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/add_mission_repo.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/edit_mission_repo.dart';
import 'package:incidents_managment/core/future/actions/data/repos/missions_repo/get_missions-repo.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/add_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/edit_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/network/dio_factory.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  // Core Services
  Dio dio = DioFactory.getDioInstance();
  getIt.registerLazySingleton<ApiService>(() => ApiService(dio));

  // Repositories - LazySingleton is correct for repos
  getIt.registerLazySingleton<AllIncidentClassRepo>(
    () => AllIncidentClassRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<EditIncidentRepo>(
    () => EditIncidentRepo(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AllActiveUserRepo>(
    () => AllActiveUserRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<MissionAssignRepo>(
    () => MissionAssignRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AddIncidentMissionRepo>(
    () => AddIncidentMissionRepo(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AddIncidentTypeRepo>(
    () => AddIncidentTypeRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<RegistrationGet>(
    () => RegistrationGet(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AddMissionRepo>(
    () => AddMissionRepo(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AllMissionsRepo>(
    () => AllMissionsRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AddIncdientRepo>(
    () => AddIncdientRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<UpdateStatuesRepo>(
    () => UpdateStatuesRepo(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<EditMissionRepo>(
    () => EditMissionRepo(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AllIncidentTypeRepo>(
    () => AllIncidentTypeRepo(apiService: getIt<ApiService>()),
  );

  // Cubits - ALL should be Factory to get fresh instances
  // ⚠️ FIXED: Changed from LazySingleton to Factory
  getIt.registerFactory<AddIncidentMissionCubit>(
    () => AddIncidentMissionCubit(repository: getIt<AddIncidentMissionRepo>()),
  );
  getIt.registerFactory<RegistrationGetCubit>(
    () => RegistrationGetCubit(registrationGet: getIt<RegistrationGet>()),
  );
  getIt.registerFactory<RegistrationPostCubit>(
    () => RegistrationPostCubit(registrationPost: getIt<RegistrationPost>()),
  );
  getIt.registerFactory<ValveProximityCubit>(
    () => ValveProximityCubit(
      valveRepository: getIt<ValveRepo>(),
      proximityService: getIt<ProximityService>(),
      alarmService: getIt<AlarmService>(),
    ),
  );

  getIt.registerLazySingleton<ValveRepo>(
    () => ValveRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ProximityService>(() => ProximityService());
  getIt.registerLazySingleton<AlarmService>(() => AlarmService());

  getIt.registerFactory<AllIncidentTypeCubit>(
    () =>
        AllIncidentTypeCubit(allIncidentTypeRepo: getIt<AllIncidentTypeRepo>()),
  );
  getIt.registerFactory<IncidentMapCubit>(() => IncidentMapCubit());

  getIt.registerFactory<EditMissionsCubit>(
    () => EditMissionsCubit(repository: getIt<EditMissionRepo>()),
  );
  getIt.registerFactory<FileUploadCubit>(
    () => FileUploadCubit(repository: getIt<FileUploadRepository>()),
  );

  getIt.registerFactory<AddIncidentCubit>(
    () => AddIncidentCubit(addIncdientRepo: getIt<AddIncdientRepo>()),
  );
  getIt.registerFactory<AllMissionsCubit>(
    () => AllMissionsCubit(allMissionsRepo: getIt<AllMissionsRepo>()),
  );

  getIt.registerFactory<AddMissionCubit>(
    () => AddMissionCubit(repository: getIt<AddMissionRepo>()),
  );

  getIt.registerFactory<AddIncidentTypeCubit>(
    () => AddIncidentTypeCubit(repository: getIt<AddIncidentTypeRepo>()),
  );
  getIt.registerFactory<UpdateStatuesCubit>(
    () => UpdateStatuesCubit(updateStatuesRepo: getIt<UpdateStatuesRepo>()),
  );
  getIt.registerFactory<EditIncidentCubit>(
    () => EditIncidentCubit(editIncidentRepo: getIt<EditIncidentRepo>()),
  );

  getIt.registerFactory<MapCubit>(() => MapCubit());
  getIt.registerFactory<AllIncidentClasses>(
    () =>
        AllIncidentClasses(allIncidentClassRepo: getIt<AllIncidentClassRepo>()),
  );
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(loginRepo: getIt<LoginRepo>()),
  );
  getIt.registerLazySingleton<LoginRepo>(
    () => LoginRepo(apiService: getIt<ApiService>()),
  );
  getIt.registerFactory<AllActiveUserCubit>(
    () => AllActiveUserCubit(allActiveUserRepo: getIt<AllActiveUserRepo>()),
  );
  getIt.registerFactory<MissionAssignCubit>(
    () => MissionAssignCubit(missionAssignRepo: getIt<MissionAssignRepo>()),
  );
  getIt.registerLazySingleton<RegistrationPost>(
    () => RegistrationPost(apiService: getIt<ApiService>()),
  );
}
