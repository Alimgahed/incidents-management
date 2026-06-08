// ============================================================================
// Dashboard sidebar — desktop rail + mobile drawer (Material 3 style)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_states.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/security/session_manager.dart';

/// Desktop: fixed-width rail. [isDrawer]: full-height drawer variant (wider touch targets, section labels).
Widget buildSidebar(BuildContext context, {bool isDrawer = false}) {
  final width = isDrawer
      ? (MediaQuery.sizeOf(context).width * 0.88).clamp(280.0, 360.0)
      : 272.0;

  return Material(
    color: Colors.transparent,
    child: SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628),   // Deep navy
              Color(0xFF0F3460),   // Navy
              Color(0xFF1B4F8A),   // Royal blue
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(4, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SidebarHeader(compact: !isDrawer),
            Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.12)),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: isDrawer ? 12 : 8, horizontal: 8),
                  children: [
                    _sectionLabel('لوحة التشغيل', isDrawer),
                    buildNavItem(
                      context,
                      icon: Icons.space_dashboard_outlined,
                      selectedIcon: Icons.space_dashboard_rounded,
                      label: 'لوحة التحكم',
                      index: 0,
                      isDrawer: isDrawer,
                    ),
                    buildNavItem(
                      context,
                      icon: Icons.map_outlined,
                      selectedIcon: Icons.map_rounded,
                      label: 'الخريطة',
                      index: 1,
                      isDrawer: isDrawer,
                    ),
                    _sectionLabel('الفرق والبيانات', isDrawer),
                    buildNavItem(
                      context,
                      icon: Icons.groups_outlined,
                      selectedIcon: Icons.groups_rounded,
                      label: 'الفرق',
                      index: 2,
                      isDrawer: isDrawer,
                    ),
                    buildNavItem(
                      context,
                      icon: Icons.insights_outlined,
                      selectedIcon: Icons.insights_rounded,
                      label: 'التحليلات',
                      index: 3,
                      isDrawer: isDrawer,
                    ),
                    _sectionLabel('الأزمات والمهام', isDrawer),
                    buildNavItem(
                      context,
                      icon: Icons.add_circle_outline_rounded,
                      selectedIcon: Icons.add_circle_rounded,
                      label: 'إضافة أزمة',
                      index: 4,
                      isDrawer: isDrawer,
                    ),
                    buildNavItem(
                      context,
                      icon: Icons.category_outlined,
                      selectedIcon: Icons.category_rounded,
                      label: 'أنواع الأزمات',
                      index: 5,
                      isDrawer: isDrawer,
                    ),
                    buildNavItem(
                      context,
                      icon: Icons.assignment_outlined,
                      selectedIcon: Icons.assignment_rounded,
                      label: 'جميع المهام',
                      index: 6,
                      isDrawer: isDrawer,
                    ),
                    buildNavItem(
                      context,
                      icon: Icons.hub_outlined,
                      selectedIcon: Icons.hub_rounded,
                      label: 'ربط مهام بالأزمة',
                      index: 7,
                      isDrawer: isDrawer,
                    ),
                  ],
                ),
              ),
            ),
            const UserProfileWidget(),
          ],
        ),
      ),
    ),
  );
}

Widget _sectionLabel(String title, bool show) {
  if (!show) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.45),
      ),
    ),
  );
}

class _SidebarHeader extends StatelessWidget {
  final bool compact;

  const _SidebarHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 16, compact ? 18 : 20, 14, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 38,
              height: 38,
              errorBuilder: (_, _, _) => const Icon(Icons.shield_moon_outlined, color: Colors.white, size: 38),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إدارة الأزمات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'لوحة العمليات',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildNavItem(
  BuildContext context, {
  required IconData icon,
  required IconData selectedIcon,
  required String label,
  required int index,
  bool isDrawer = false,
}) {
  return BlocBuilder<HomeCubit, HomeStates>(
    buildWhen: (previous, current) => current is HomeChanged,
    builder: (context, state) {
      final cubit = context.read<HomeCubit>();
      final selected = cubit.selectedIndex == index;
      final vertical = isDrawer ? 4.0 : 2.0;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: vertical),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => cubit.changeState(index),
            borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.white.withValues(alpha: 0.06),
            splashColor: Colors.white.withValues(alpha: 0.12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isDrawer ? 14 : 10,
                vertical: isDrawer ? 14 : 10,
              ),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? selectedIcon : icon,
                    color: selected ? Colors.white : Colors.white.withValues(alpha: 0.72),
                    size: isDrawer ? 24 : 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.78),
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: isDrawer ? 15 : 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 3,
                    height: selected ? 22 : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDA349),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ============================================================================
// USER PROFILE
// ============================================================================

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({super.key});

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await getIt<SessionManager>().isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt<SessionManager>().getCurrentUser();
    final name = currentUser?.empName ?? currentUser?.username ?? 'مستخدم';
    final role = currentUser?.authorityName ?? '';

    return Material(
      color: Colors.black.withValues(alpha: 0.15),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  if (role.isNotEmpty)
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.white.withValues(alpha: 0.75),
                size: 22,
              ),
              color: const Color(0xFF0F3460),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onOpened: _checkLoginStatus,
              itemBuilder: (context) => [
                _menuRow(Icons.person_outline_rounded, 'الملف الشخصي', 'profile'),
                _menuRow(Icons.settings_outlined, 'الإعدادات', 'settings'),
                if (!_isLoggedIn) ...[
                  _menuRow(Icons.person_add_alt_1_outlined, 'تسجيل مستخدم', 'registration'),
                  _menuRow(Icons.login_rounded, 'تسجيل الدخول', 'login'),
                ] else
                  _menuRow(Icons.logout_rounded, 'تسجيل الخروج', 'logout', danger: true),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'login':
                    await context.pushNamed(Routes.login);
                    _checkLoginStatus();
                    break;
                  case 'profile':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الملف الشخصي — قيد التطوير'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    break;
                  case 'registration':
                    context.pushNamed(Routes.registration);
                    break;
                  case 'settings':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الإعدادات — قيد التطوير'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    break;
                  case 'logout':
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('تسجيل الخروج'),
                        content: const Text('هل أنت متأكد؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('إلغاء'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('خروج'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await getIt<SessionManager>().logout();
                    }
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

PopupMenuItem<String> _menuRow(IconData icon, String text, String value, {bool danger = false}) {
  final c = danger ? Colors.redAccent : Colors.white;
  return PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, color: c, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: c, fontSize: 14))),
      ],
    ),
  );
}
