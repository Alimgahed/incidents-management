import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/order_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/add_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/edit_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/add_incident.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/add_missions.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/all_missions.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/edit_missions.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/relation_incident_mission.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/home/ui/screens/home.dart';
import 'package:incidents_managment/core/routing/routes.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.addIncident:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<AddIncidentCubit>()),
              BlocProvider(create: (_) => getIt<MapCubit>()),
              BlocProvider(
                create: (_) =>
                    getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
              ),
            ],
            child: const AddIncidentScreen(),
          ),
        );

      case Routes.addMissions:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<AddMissionCubit>()),
              BlocProvider(
                create: (_) =>
                    getIt<AllIncidentClasses>()..getAllIncidentClasses(),
              ),
            ],
            child: const AddMissions(),
          ),
        );
      case Routes.editMissions:
        final mission = settings.arguments as AllMissionModel?;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<EditMissionsCubit>()),
              BlocProvider(
                create: (_) =>
                    getIt<AllIncidentClasses>()..getAllIncidentClasses(),
              ),
            ],
            child: EditMissions(mission: mission),
          ),
        );
      case Routes.addIncidentType:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<AddIncidentTypeCubit>()),
              BlocProvider(
                create: (_) =>
                    getIt<AllIncidentClasses>()..getAllIncidentClasses(),
              ),
            ],
            child: const AddIncidentType(),
          ),
        );
      case Routes.allMissions:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<AllMissionsCubit>()..getAllMissions(),
              ),
              BlocProvider(create: (_) => getIt<AddMissionCubit>()),
            ],
            child: const AllMissions(),
          ),
        );
      case Routes.addIncidentMission:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => MissionSelectionCubit()),
              BlocProvider(
                create: (_) => getIt<AllMissionsCubit>()..getAllMissions(),
              ),
              BlocProvider(create: (_) => getIt<AddIncidentMissionCubit>()),
              BlocProvider(
                create: (_) =>
                    getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
              ),
            ],
            child: const Addincidentmission(),
          ),
        );
      case Routes.allIncidentType:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
            child: const AllIncidentType(),
          ),
        );
      case Routes.crisisDashboardScreen:
        return MaterialPageRoute(builder: (_) => const CrisisDashboard());

      default:
        return MaterialPageRoute(builder: (_) => const CrisisDashboard());
    }
  }
}
