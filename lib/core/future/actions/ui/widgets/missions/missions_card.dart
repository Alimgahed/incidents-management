import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';

class MissionCard extends StatelessWidget {
  final AllMissionModel mission;
  final int index;

  const MissionCard({super.key, required this.mission, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: appColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.tag_sharp)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.missionName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'التصنيف: ${mission.className}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: appColor, size: 22),
                  onPressed: () {
                    _editMission(context, mission);
                  },
                  tooltip: 'تعديل',
                  splashRadius: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _editMission(BuildContext context, AllMissionModel mission) async {
  final result = await context.pushNamed(
    Routes.editMissions,
    arguments: mission,
  );

  if (result == true && context.mounted) {
    context.read<AllMissionsCubit>().getAllMissions();
  }
}
