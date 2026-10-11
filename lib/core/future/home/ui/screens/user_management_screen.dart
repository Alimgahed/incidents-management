import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/user_management_filter_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/widgets/users/user_stats_cards.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/widgets/users/user_filters_panel.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/widgets/users/user_data_table.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/user_management_filter_state.dart';

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
        BlocProvider(
          create: (_) => UserManagementFilterCubit(),
        ),
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
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (users) {
            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('لا يوجد مستخدمين متاحين', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AllActiveUserCubit>().allActiveUsers(),
                      child: const Text('إعادة تحميل'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    UserStatsCards(users: users),
                    const SizedBox(height: 24),

                    // Filters Panel
                    UserFiltersPanel(rawUsers: users),
                    const SizedBox(height: 24),

                    // Data Table (Reactive to Filter Cubit)
                    BlocBuilder<UserManagementFilterCubit, UserManagementFilterState>(
                      builder: (context, filterState) {
                        final filterCubit = context.read<UserManagementFilterCubit>();
                        final filteredUsers = filterCubit.filterUsers(users);

                        return UserDataTable(users: filteredUsers);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('حدث خطأ: $message', style: const TextStyle(fontSize: 16, color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AllActiveUserCubit>().allActiveUsers(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
