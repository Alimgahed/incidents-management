import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/user_management_filter_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/user_management_filter_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/widgets/users/user_data_table.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/widgets/users/user_filters_panel.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/widgets/users/user_stats_cards.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/shimmer/screen_shimmers.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = getIt<AllActiveUserCubit>();
            cubit.allActiveUsers();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => UserManagementFilterCubit()),
      ],
      child: const _UserManagementBody(),
    );
  }
}

class _UserManagementBody extends StatelessWidget {
  const _UserManagementBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllActiveUserCubit, AllActiveUserState>(
      builder: (context, state) {
        final userCubit = context.read<AllActiveUserCubit>();
        return state.when(
          initial: () => const UserManagementScreenShimmer(),
          loading: () => const UserManagementScreenShimmer(),
          loaded: (users) {
            if (users.isEmpty) {
              return AppEmptyState(
                icon: Icons.group_off_rounded,
                title: 'لا يوجد مستخدمين متاحين',
                subtitle: 'لم يتم العثور على مستخدمين مسجلين في النظام حالياً.',
                actionLabel: 'إعادة تحميل',
                onAction: () => userCubit.allActiveUsers(forceLoading: true),
              );
            }

            return Column(
              children: [
                AppInlineRefreshBanner(isRefreshing: userCubit.isRefreshing),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      AppBreakpoints.isMobile(context)
                          ? AppSpacing.md
                          : AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'دليل المستخدمين والصلاحيات',
                                    style: AppTextStyles.headingMd,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'إجمالي المسجلين بالمنظومة: ${users.length} مستخدم نشط',
                                    style: AppTextStyles.bodySm,
                                  ),
                                ],
                              ),
                            ),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                AppActionButton(
                                  label: 'تحديث',
                                  icon: Icons.refresh_rounded,
                                  isOutlined: true,
                                  onPressed: () =>
                                      userCubit.allActiveUsers(forceLoading: true),
                                ),
                                AppActionButton(
                                  label: 'تسجيل مستخدم جديد',
                                  icon: Icons.person_add_alt_1_rounded,
                                  onPressed: () async {
                                    await Navigator.of(
                                      context,
                                    ).pushNamed(Routes.registration);
                                    if (context.mounted) {
                                      userCubit.allActiveUsers(
                                        forceLoading: true,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        UserStatsCards(users: users),
                        const SizedBox(height: AppSpacing.xl),
                        UserFiltersPanel(rawUsers: users),
                        const SizedBox(height: AppSpacing.xl),
                        BlocBuilder<
                          UserManagementFilterCubit,
                          UserManagementFilterState
                        >(
                          builder: (context, filterState) {
                            final filterCubit = context
                                .read<UserManagementFilterCubit>();
                            final filteredUsers = filterCubit.filterUsers(
                              users,
                            );

                            return UserDataTable(users: filteredUsers);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          error: (message) => AppErrorState(
            title: 'حدث خطأ أثناء تحميل المستخدمين',
            message: message,
            onRetry: () => userCubit.allActiveUsers(forceLoading: true),
          ),
        );
      },
    );
  }
}
