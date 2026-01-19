import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/repos/all_incident_classes_rep.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/add_incident.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/add_incident_type.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/future/actions/data/repos/all_incident_type_repo.dart';

class AppRouter {
  Route generateRoute(RouteSettings? settings) {
    switch (settings?.name) {
      case Routes.addIncident:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<AddIncidentCubit>(create: (_) => AddIncidentCubit()),
              BlocProvider<MapCubit>(create: (_) => MapCubit()),

              BlocProvider<AllIncidentTypeCubit>(
                create: (_) => AllIncidentTypeCubit(
                  allIncidentTypeRepo: getIt<AllIncidentTypeRepo>(),
                )..getAllIncidentTypes(),
              ),
            ],
            child: const AddIncidentScreen(),
          ),
        );

      case Routes.addIncidentType:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => AddIncidentTypeCubit(repository: getIt()),
              ),
              BlocProvider<AllIncidentClasses>(
                create: (_) => AllIncidentClasses(
                  allIncidentClassRepo: getIt<AllIncidentClassRepo>(),
                )..getAllIncidentClasses(),
              ),
            ],
            child: const AddIncidentType(),
          ),
        );

      // case Routes.splash:
      //   return MaterialPageRoute(builder: (_) => const SplashScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings?.name}')),
          ),
        );
    }
  }
}
