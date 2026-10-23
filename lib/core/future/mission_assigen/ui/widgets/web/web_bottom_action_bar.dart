import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_assign_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_assign_states.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';

class WebBottomActionBar extends StatelessWidget {
  final VoidCallback onAssign;
  final VoidCallback onCancel;

  const WebBottomActionBar({
    super.key,
    required this.onAssign,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
      builder: (context, selState) {
        return BlocBuilder<MissionAssignCubit, MissionAssignState>(
          builder: (context, assignState) {
            final selCubit = context.read<MissionSelectionCubit>();
            final isLoading = assignState is MissionAssignStateLoading;
            final canAssign = selCubit.canAssign;

            // Total users count across missions or active mission
            final activeMissionUsersCount =
                selCubit.activeUsers(selState.activeMissionId).length;
            final totalSelectedCount = selState.missionUserMap.values.fold<int>(
              0,
              (sum, users) => sum + users.length,
            );
            final displayCount = totalSelectedCount > 0 ? totalSelectedCount : activeMissionUsersCount;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  // Action Buttons on left (in RTL: Right)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary "تعيين المهام" button
                      ElevatedButton(
                        onPressed: canAssign && !isLoading ? onAssign : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: const Color(0xFF93C5FD),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withAlpha(200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: canAssign ? 2 : 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    displayCount > 0
                                        ? 'تعيين المهام ($displayCount)'
                                        : 'تعيين المهام',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(width: 12),

                      // "إلغاء" button
                      OutlinedButton(
                        onPressed: isLoading ? null : onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Info message on right (in RTL: Left)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          selCubit.activeMissionIds.length > 1
                              ? 'سيتم تعيين المهام المحددة (${selCubit.activeMissionIds.length} مهام) للمستخدمين الذين تم اختيارهم'
                              : 'سيتم تعيين المهمة المحددة لجميع المستخدمين الذين تم اختيارهم',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
