import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';

class WebMissionsSidebar extends StatelessWidget {
  final List<CurrentIncidentWithMissions> missions;
  final CurrentIncidentModel incident;

  const WebMissionsSidebar({
    super.key,
    required this.missions,
    required this.incident,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.assignment_rounded,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'المهام المطلوبة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                      builder: (context, state) {
                        final assignedCount = context
                            .read<MissionSelectionCubit>()
                            .assignedMissionsCount;
                        if (assignedCount == 0) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            '$assignedCount مسندة',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (missions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                    builder: (context, state) {
                      final selCubit = context.read<MissionSelectionCubit>();
                      final validMissionIds = missions
                          .map((m) => m.idCurrentIncidentMission)
                          .whereType<int>()
                          .toList();
                      final isAllSelected =
                          validMissionIds.isNotEmpty &&
                          validMissionIds.every(
                            (id) => selCubit.isMissionSelected(id),
                          );

                      return InkWell(
                        onTap: () =>
                            selCubit.selectAllMissions(validMissionIds),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAllSelected
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isAllSelected
                                  ? const Color(0xFF93C5FD)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isAllSelected
                                      ? const Color(0xFF2563EB)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isAllSelected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFCBD5E1),
                                    width: 1.5,
                                  ),
                                ),
                                child: isAllSelected
                                    ? const Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isAllSelected
                                      ? 'تم تحديد جميع المهام (${validMissionIds.length})'
                                      : 'تحديد جميع المهام (${validMissionIds.length})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isAllSelected
                                        ? const Color(0xFF1D4ED8)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Scrollable Mission List
          Expanded(
            child: missions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'لا توجد مهام مسجلة لهذا البلاغ',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                    builder: (context, state) {
                      final selCubit = context.read<MissionSelectionCubit>();

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        itemCount: missions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final mission = missions[index];
                          final missionId = mission.idCurrentIncidentMission;
                          final isSelected =
                              missionId != null &&
                              selCubit.isMissionSelected(missionId);
                          final assignedUsers = missionId != null
                              ? state.missionUserMap[missionId]
                              : null;
                          final assignedCount = assignedUsers?.length ?? 0;
                          final orderNumber =
                              mission.currentIncidentMissionOrder ??
                              (index + 1);

                          return _MissionSidebarItem(
                            order: orderNumber,
                            title: mission.missionName ?? 'مهمة',
                            isSelected: isSelected,
                            assignedCount: assignedCount,
                            onTap: () {
                              if (missionId != null) {
                                selCubit.toggleMissionSelection(missionId);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MissionSidebarItem extends StatelessWidget {
  final int order;
  final String title;
  final bool isSelected;
  final int assignedCount;
  final VoidCallback onTap;

  const _MissionSidebarItem({
    required this.order,
    required this.title,
    required this.isSelected,
    required this.assignedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFF8FAFC),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFF1F5F9),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Checkbox indicator on right (in RTL)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),

              // Number Badge
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$order',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title and count badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF334155),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (assignedCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$assignedCount مستخدمين',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Left arrow indicator matching web back arrow
              Icon(
                Icons.arrow_back_rounded,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
