import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/add_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/all_missions_mobile.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/all_missions_web.dart';


class AllMissions extends StatelessWidget {
  const AllMissions({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AllMissionsCubit>()..getAllMissions(),
        ),
        BlocProvider(create: (_) => getIt<AddMissionCubit>()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const AllMissionsWeb();
          }
          return const AllMissionsMobile();
        },
      ),
    );
  }
}
