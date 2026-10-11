import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/helpers/routing.dart';

class MissionsGrid extends StatelessWidget {
  final List<AllMissionModel> missions;

  const MissionsGrid({super.key, required this.missions});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'لا توجد مهام تطابق الفلتر',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return _EnterpriseMissionCard(mission: mission);
          },
        );
      },
    );
  }
}

class _EnterpriseMissionCard extends StatelessWidget {
  final AllMissionModel mission;

  const _EnterpriseMissionCard({required this.mission});

  Color _getColorForClass(String? className) {
    if (className == null) return Colors.grey;
    if (className.contains('مياه')) return Colors.blue;
    if (className.contains('صرف')) return Colors.purple;
    if (className.contains('كهرباء') || className.contains('طاقة')) return Colors.red;
    if (className.contains('طرق')) return Colors.green;
    if (className.contains('أمن')) return Colors.teal;
    if (className.contains('اتصالات') || className.contains('معلومات')) return Colors.orange;
    if (className.contains('صحة') || className.contains('سلامة')) return Colors.blueAccent;
    return const Color(0xFF1B4F8A);
  }

  IconData _getIconForClass(String? className) {
    if (className == null) return Icons.assignment_outlined;
    if (className.contains('مياه')) return Icons.water_drop;
    if (className.contains('صرف')) return Icons.plumbing;
    if (className.contains('كهرباء') || className.contains('طاقة')) return Icons.bolt;
    if (className.contains('طرق')) return Icons.add_road;
    if (className.contains('أمن')) return Icons.security;
    if (className.contains('اتصالات')) return Icons.cell_tower;
    if (className.contains('معلومات') || className.contains('سيرفر')) return Icons.dns;
    if (className.contains('صحة') || className.contains('سلامة')) return Icons.medical_services;
    return Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForClass(mission.className);
    final icon = _getIconForClass(mission.className);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          final result = await context.pushNamed(
            Routes.editMissions,
            arguments: mission,
          );
          if (result == true && context.mounted) {
            context.read<AllMissionsCubit>().getAllMissions();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon container with thematic colors
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              // Name and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mission.missionName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mission.className != null && mission.className!.isNotEmpty
                                ? mission.className!
                                : 'بدون تصنيف',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action / edit icon
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                tooltip: 'تعديل المهمة',
                onPressed: () async {
                  final result = await context.pushNamed(
                    Routes.editMissions,
                    arguments: mission,
                  );
                  if (result == true && context.mounted) {
                    context.read<AllMissionsCubit>().getAllMissions();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
