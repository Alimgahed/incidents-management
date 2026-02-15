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
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/mobile/data/repo/file_upload_repo.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_cubit.dart';
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


  getIt.registerLazySingleton<AddIncidentMissionRepo>(
    () => AddIncidentMissionRepo(apiService: getIt<ApiService>()),
  );

  getIt.registerLazySingleton<AddIncidentTypeRepo>(
    () => AddIncidentTypeRepo(apiService: getIt<ApiService>()),
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
}
