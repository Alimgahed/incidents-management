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

/// Desktop: collapsible rail (`260px` expanded <-> `72px` collapsed).
/// [isDrawer]: full-height drawer variant for mobile (`<= 767px`).
Widget buildSidebar(
  BuildContext context, {
  bool isDrawer = false,
  bool isCollapsed = false,
  VoidCallback? onToggleCollapse,
}) {
  final collapsed = isCollapsed && !isDrawer;
  final width = isDrawer
      ? (MediaQuery.sizeOf(context).width * 0.88).clamp(280.0, 340.0)
      : (collapsed ? 72.0 : 260.0);

  return Material(
    color: Colors.transparent,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1628), // Deep navy
            Color(0xFF0F3B6C), // Corporate Deep Navy
            Color(0xFF1E3A5F), // Primary Navy
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarHeader(
            compact: !isDrawer,
            isCollapsed: collapsed,
            onToggleCollapse: onToggleCollapse,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: !collapsed),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: isDrawer ? 12 : 8,
                  horizontal: collapsed ? 8 : 10,
                ),
                children: [
                  _sectionLabel('غرفة العمليات والمتابعة', !collapsed),
                  buildNavItem(
                    context,
                    icon: Icons.space_dashboard_outlined,
                    selectedIcon: Icons.space_dashboard_rounded,
                    label: 'لوحة التحكم',
                    index: 0,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.map_outlined,
                    selectedIcon: Icons.map_rounded,
                    label: 'الخريطة',
                    index: 1,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.bar_chart_outlined,
                    selectedIcon: Icons.bar_chart_rounded,
                    label: 'التقارير',
                    index: 3,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  _sectionLabel('الخرائط الميدانية والأسطول', !collapsed),
                  buildNavItem(
                    context,
                    icon: Icons.water_drop_outlined,
                    selectedIcon: Icons.water_drop_rounded,
                    label: 'خريطة المحابس',
                    index: 8,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.layers_outlined,
                    selectedIcon: Icons.layers_rounded,
                    label: 'خريطة نظم المعلومات (GIS)',
                    index: 9,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.local_shipping_outlined,
                    selectedIcon: Icons.local_shipping_rounded,
                    label: 'تتبع سيارات المياه',
                    index: 10,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.directions_car_outlined,
                    selectedIcon: Icons.directions_car_rounded,
                    label: 'أسطول السيارات',
                    index: 11,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  _sectionLabel('إدارة البلاغات والمهام', !collapsed),
                  buildNavItem(
                    context,
                    icon: Icons.add_circle_outline_rounded,
                    selectedIcon: Icons.add_circle_rounded,
                    label: 'إضافة أزمة',
                    index: 4,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.category_outlined,
                    selectedIcon: Icons.category_rounded,
                    label: 'أنواع الأزمات',
                    index: 5,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.assignment_outlined,
                    selectedIcon: Icons.assignment_rounded,
                    label: 'جميع المهام',
                    index: 6,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  buildNavItem(
                    context,
                    icon: Icons.hub_outlined,
                    selectedIcon: Icons.hub_rounded,
                    label: 'ربط مهام بالأزمة',
                    index: 7,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                  _sectionLabel('إدارة النظام', !collapsed),
                  buildNavItem(
                    context,
                    icon: Icons.groups_outlined,
                    selectedIcon: Icons.groups_rounded,
                    label: 'إدارة المستخدمين',
                    index: 2,
                    isDrawer: isDrawer,
                    isCollapsed: collapsed,
                  ),
                ],
              ),
            ),
          ),
          UserProfileWidget(isCollapsed: collapsed),
        ],
      ),
    ),
  );
}

Widget _sectionLabel(String title, bool show) {
  if (!show) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
    );
  }
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 12, 10, 5),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.52),
      ),
    ),
  );
}

class _SidebarHeader extends StatelessWidget {
  final bool compact;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const _SidebarHeader({
    required this.compact,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'شركة مياه الشرب والصرف الصحي بالمنيا',
              child: Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF1E56A0),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            if (onToggleCollapse != null) ...[
              const SizedBox(height: 8),
              IconButton(
                onPressed: onToggleCollapse,
                tooltip: 'توسيع القائمة الجانبية',
                icon: const Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 16,
        compact ? 14 : 18,
        10,
        12,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFF1E56A0),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'شركة مياه الشرب\nوالصرف الصحي بالمنيا',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
          if (onToggleCollapse != null)
            IconButton(
              onPressed: onToggleCollapse,
              tooltip: 'طي القائمة الجانبية',
              icon: const Icon(
                Icons.keyboard_double_arrow_right_rounded,
                color: Colors.white70,
                size: 20,
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
  bool isCollapsed = false,
}) {
  return BlocBuilder<HomeCubit, HomeStates>(
    buildWhen: (previous, current) => current is HomeChanged,
    builder: (context, state) {
      final cubit = context.read<HomeCubit>();
      final selected = cubit.selectedIndex == index;
      final vertical = isDrawer ? 4.0 : 2.5;

      Widget tile = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => cubit.changeState(index),
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          splashColor: Colors.white.withValues(alpha: 0.12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : (isDrawer ? 14 : 10),
              vertical: isDrawer ? 13 : 10,
            ),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1B64F2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1B64F2)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1B64F2).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isCollapsed
                ? Center(
                    child: Icon(
                      selected ? selectedIcon : icon,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.75),
                      size: 22,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        selected ? selectedIcon : icon,
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.72),
                        size: isDrawer ? 23 : 20,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.82),
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: isDrawer ? 14.5 : 13.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 3,
                        height: selected ? 20 : 0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDA349),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );

      if (isCollapsed) {
        tile = Tooltip(message: label, child: tile);
      }

      return Padding(
        padding: EdgeInsets.symmetric(vertical: vertical),
        child: tile,
      );
    },
  );
}

// ============================================================================
// USER PROFILE
// ============================================================================

class UserProfileWidget extends StatefulWidget {
  final bool isCollapsed;

  const UserProfileWidget({super.key, this.isCollapsed = false});

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

    if (widget.isCollapsed) {
      return Material(
        color: Colors.black.withValues(alpha: 0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          child: Center(
            child: Tooltip(
              message: '$name${role.isNotEmpty ? ' ($role)' : ''}',
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

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
