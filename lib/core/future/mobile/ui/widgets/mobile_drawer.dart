import 'package:flutter/material.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';

class MobileDrawer extends StatefulWidget {
  const MobileDrawer({super.key});

  @override
  State<MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<MobileDrawer> {
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
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      label: 'لوحة التحكم',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.map_rounded,
                      label: 'خريطة المحابس',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(Routes.valveMap);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'إضافة أزمة',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(Routes.addIncidentMobile);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.category_rounded,
                      label: 'أنواع الأزمات',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(Routes.allIncidentType);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.list_alt_rounded,
                      label: 'جميع المهام',
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(Routes.allMissions);
                      },
                    ),
                    const Divider(color: Colors.white24),
                    if (!_isLoggedIn) ...[
                      _buildDrawerItem(
                        icon: Icons.person_add_rounded,
                        label: 'إنشاء حساب',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(Routes.registration);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.login_rounded,
                        label: 'تسجيل الدخول',
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(Routes.login);
                        },
                      ),
                    ] else ...[
                      _buildDrawerItem(
                        icon: Icons.logout_rounded,
                        label: 'تسجيل الخروج',
                        color: Colors.redAccent.shade100,
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'إدارة الأزمات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color.withOpacity(0.8), size: 24),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      hoverColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'المسؤول',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'مشرف النظام',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('خروج'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SharedPreferencesHelper.removeData(SharedPreferenceKeys.userToken);
      if (context.mounted) {
        context.pushNamedAndRemoveUntil(Routes.login);
      }
    }
  }
}
