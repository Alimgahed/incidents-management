// ============================================================================
// OPTIMIZED SIDEBAR - Fixed Size with Scroll
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_states.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';

Widget buildSidebar(BuildContext context) {
  return Container(
    width: 60.w,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
      ),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 0)),
      ],
    ),
    child: Column(
      children: [
        _buildHeader(),
        const Divider(color: Colors.white24, height: 1),
        _buildNavigation(context),
        const Spacer(),
        _buildUserProfile(),
      ],
    ),
  );
}

// ============================================================================
// HEADER
// ============================================================================
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.shield, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'إدارة\nالأزمات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildNavigation(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      children: [
        buildNavItem(icon: Icons.dashboard, label: 'لوحة التحكم', index: 0),
        buildNavItem(icon: Icons.map, label: 'عرض الخريطة', index: 1),
        buildNavItem(icon: Icons.people, label: 'الفرق', index: 2),
        buildNavItem(icon: Icons.analytics, label: 'التحليلات', index: 3),
        buildNavItem(
          icon: Icons.add_circle_outline,
          label: 'أضافة أزمة',
          index: 4,
        ),
        buildNavItem(icon: Icons.category, label: 'أنواع الأزمات', index: 5),
        buildNavItem(icon: Icons.list_alt, label: 'جميع المهام', index: 6),
        buildNavItem(
          icon: Icons.category,
          label: 'إضافة مهام الأزمة',
          index: 7,
        ),
      ],
    ),
  );
}

Widget buildNavItem({
  Color? color,
  required IconData icon,
  required String label,
  required int index,
}) {
  color ??= Colors.white.withValues(alpha: 0.3);
  return BlocBuilder<HomeCubit, HomeStates>(
    buildWhen: (previous, current) => current is HomeChanged,
    builder: (context, state) {
      final cubit = context.read<HomeCubit>();
      final bool isSelected = cubit.selectedIndex == index;

      return InkWell(
        onTap: () {
          cubit.changeState(index);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : color ?? Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : color ?? Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? appColor : Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? appColor
                        : Colors.white.withValues(alpha: 0.7),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: isSelected ? 24 : 0,
                decoration: BoxDecoration(
                  color: appColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ============================================================================
// USER PROFILE
// ============================================================================
Widget _buildUserProfile() {
  return const UserProfileWidget();
}

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
    final token = await SharedPreferencesHelper.getData<String>(
        SharedPreferenceKeys.userToken);
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'المسؤول',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'مشرف',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
            color: const Color(0xFF2C5F8D),
            onOpened: _checkLoginStatus, // Refresh state before opening menu
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'الملف الشخصي',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'الإعدادات',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!_isLoggedIn) ...[
                const PopupMenuItem(
                  value: 'registration',
                  child: Row(
                    children: [
                      Icon(Icons.person_add, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'تسجيل مستخدم جديد',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'login',
                  child: Row(
                    children: [
                      Icon(Icons.login, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'تسجيل الدخول',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            onSelected: (value) async {
              switch (value) {
                case 'login':
                  await context.pushNamed(Routes.login);
                  _checkLoginStatus(); // Update if login was successful
                  break;
                case 'profile':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم فتح الملف الشخصي قريباً', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  break;
                case 'registration':
                  context.pushNamed(Routes.registration);
                  break;
                case 'logout':
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            await SharedPreferencesHelper.removeData(
                                SharedPreferenceKeys.userToken);
                            _checkLoginStatus(); // Update state to logged out
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تسجيل الخروج بنجاح', style: TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              context.pushNamedAndRemoveUntil(Routes.login);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  );
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
