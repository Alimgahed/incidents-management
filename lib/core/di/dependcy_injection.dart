import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:incidents_managment/core/future/actions/data/repos/add_incident_type_repo.dart';
import 'package:incidents_managment/core/future/actions/data/repos/all_incident_classes_rep.dart';
import 'package:incidents_managment/core/future/actions/data/repos/all_incident_type_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/all_incident_type.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/network/dio_factory.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  // Core Services
  Dio dio = DioFactory.getDioInstance();
  getIt.registerLazySingleton(() => ApiService(dio));

  // ⭐ Register UserService as singleton

  // Initialize UserService (load user from storage)

  getIt.registerLazySingleton(() => AllIncidentTypeRepo(apiService: getIt()));

  getIt.registerLazySingleton(() => AllIncidentClassRepo(apiService: getIt()));
  getIt.registerLazySingleton(() => AddIncidentTypeRepo(apiService: getIt()));

  // Repositories
  // getIt.registerLazySingleton(() => LoginRepo(apiService: getIt()));

  getIt.registerFactory(
    () => AllIncidentTypeCubit(allIncidentTypeRepo: getIt()),
  );

  getIt.registerFactory(() => AddIncidentTypeCubit(repository: getIt()));
  getIt.registerFactory(
    () => AllIncidentClasses(allIncidentClassRepo: getIt()),
  );

  // // ⭐⭐⭐ Cubits - Register LoginCubit as Factory
  // getIt.registerFactory(() => AddClientCubit(addClientRepo: getIt()));
}
