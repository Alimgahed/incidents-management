import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';

/// Lists users returned by [AllActiveUserRepo] — no client-side dummy rows.
class ActiveTeamsScreen extends StatelessWidget {
  const ActiveTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<AllActiveUserCubit>();
        cubit.allActiveUsers();
        return cubit;
      },
      child: const _ActiveTeamsBody(),
    );
  }
}

class _ActiveTeamsBody extends StatelessWidget {
  const _ActiveTeamsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الفرق والمستخدمون النشطون',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'البيانات من خادم المؤسسة (المستخدمون الفعّالون).',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<AllActiveUserCubit, AllActiveUserState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const Center(child: CircularProgressIndicator()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    loaded: (users) {
                      if (users.isEmpty) {
                        return _EmptyState(
                          title: 'لا يوجد مستخدمون في القائمة',
                          subtitle: 'تحقق من الصلاحيات أو حالة الخادم.',
                          onRetry: () =>
                              context.read<AllActiveUserCubit>().allActiveUsers(),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<AllActiveUserCubit>().allActiveUsers(),
                        child: ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _UserTile(user: users[index]);
                          },
                        ),
                      );
                    },
                    error: (message) => _EmptyState(
                      title: 'تعذر تحميل القائمة',
                      subtitle: message,
                      onRetry: () =>
                          context.read<AllActiveUserCubit>().allActiveUsers(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final ActiveUser user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user.empName?.trim().isNotEmpty == true
        ? user.empName!
        : (user.username ?? '—');
    final role = user.authorityName ?? '—';
    final group = user.groupName ?? '—';
    final active = user.isActive == true;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: active ? const Color(0xFF1B4F8A) : Colors.grey,
        child: Icon(
          active ? Icons.person : Icons.person_off,
          color: Colors.white,
          size: 22,
        ),
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$role · $group',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: active
          ? const Chip(
              label: Text('نشط', style: TextStyle(fontSize: 12)),
              visualDensity: VisualDensity.compact,
            )
          : const Chip(
              label: Text('غير نشط', style: TextStyle(fontSize: 12)),
              visualDensity: VisualDensity.compact,
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
