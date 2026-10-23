import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';
import 'web_user_card.dart';

class WebUsersSection extends StatelessWidget {
  final List<ActiveUser> filteredUsers;
  final int totalCount;
  final VoidCallback onResetFilters;

  const WebUsersSection({
    super.key,
    required this.filteredUsers,
    required this.totalCount,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
      builder: (context, state) {
        final selCubit = context.read<MissionSelectionCubit>();
        final targetMissions = selCubit.activeMissionIds;

        if (targetMissions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'اختر مهمة أو أكثر من القائمة الجانبية للبدء في تعيين المستخدمين',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final targetCount = targetMissions.length;
        final selectedCount = targetCount == 1
            ? selCubit.activeUsers(targetMissions.first).length
            : selCubit.countSelectedUsersInTargets(filteredUsers);
        final isAllSelected = filteredUsers.isNotEmpty &&
            filteredUsers.every((u) => selCubit.isUserSelected(u));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection & Count Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  // Selected Users indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          targetCount > 1
                              ? 'تم اختيار $selectedCount مستخدمين لـ $targetCount مهام'
                              : 'تم اختيار $selectedCount مستخدمين',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Select All Checkbox
                  InkWell(
                    onTap: filteredUsers.isEmpty
                        ? null
                        : () => selCubit.toggleAllUsers(filteredUsers),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
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
                                      size: 13,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'تحديد الكل في هذه الصفحة',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right side items (in RTL: Left)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'إجمالي المستخدمين: $totalCount',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.view_list_rounded,
                                size: 16,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Users Grid
            if (filteredUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'لا يوجد مستخدمين مطابقين لمعايير البحث الحالية',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: onResetFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('إعادة ضبط الفلاتر'),
                      ),
                    ],
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int columns = 4;
                  if (width >= 1350) {
                    columns = 4;
                  } else if (width >= 1000) {
                    columns = 4;
                  } else if (width >= 720) {
                    columns = 3;
                  } else if (width >= 480) {
                    columns = 2;
                  } else {
                    columns = 1;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 195,
                    ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = selCubit.isUserSelected(user);

                      return WebUserCard(
                        user: user,
                        isSelected: isSelected,
                        onToggle: () => selCubit.toggleUser(user),
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
