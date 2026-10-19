import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/security/session_manager.dart';

class MobileMoreServicesScreen extends StatelessWidget {
  const MobileMoreServicesScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text(
              'تسجيل الخروج',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من المنظومة؟',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await getIt<SessionManager>().logout();

              if (context.mounted) {
                context.pushNamedAndRemoveUntil(
                  Routes.login,
                  predicate: (route) => false,
                );
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: MobileSystemBars.lightAppBar,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text(
              'المزيد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: primaryTextColor,
                  size: 24,
                ),
                tooltip: 'رجوع',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFE5E7EB)),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // 1. الخرائط والعمليات الميدانية
              _buildSectionTitle('الخرائط والعمليات الميدانية'),
              _buildServiceTile(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'خريطة المحابس والشبكات',
                subtitle: 'استعراض مواقع المحابس والمسافات التشغيلية الميدانية',
                onTap: () => context.pushNamed(Routes.valveMap),
              ),
              _buildServiceTile(
                icon: Icons.map_rounded,
                iconColor: const Color(0xFF2563EB),
                title: 'خريطة البلاغات الميدانية',
                subtitle: 'استعراض البلاغات الجغرافية المباشرة ونقاط التجمع',
                onTap: () => context.pushNamed(Routes.incidentMap),
              ),

              const SizedBox(height: 14),

              // 2. إدارة الأزمات والبلاغات
              _buildSectionTitle('إدارة الأزمات والبلاغات'),
              _buildServiceTile(
                icon: Icons.add_circle_outline_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'إضافة بلاغ أزمة جديد',
                subtitle: 'تسجيل بلاغ طوارئ جديد مع الموقع الجغرافي والبيانات',
                onTap: () => context.pushNamed(Routes.addIncidentMobile),
              ),
              _buildServiceTile(
                icon: Icons.category_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'أنواع وتصنيفات الأزمات',
                subtitle: 'استعراض وتعديل تصنيفات الأزمات ودرجات الحرج',
                onTap: () => context.pushNamed(Routes.allIncidentType),
              ),
              _buildServiceTile(
                icon: Icons.playlist_add_rounded,
                iconColor: const Color(0xFF0D9488),
                title: 'إضافة نوع أزمة جديد',
                subtitle: 'تعريف تصنيف بلاغ جديد في المنظومة',
                onTap: () => context.pushNamed(Routes.addIncidentType),
              ),

              const SizedBox(height: 14),

              // 3. خطط التدخل والمهام
              _buildSectionTitle('خطط التدخل والمهام'),
              _buildServiceTile(
                icon: Icons.assignment_rounded,
                iconColor: const Color(0xFF7C3AED),
                title: 'سجل جميع المهام',
                subtitle: 'استعراض ومتابعة مهام التدخل السريع وفرق العمل',
                onTap: () => context.pushNamed(Routes.allMissions),
              ),
              _buildServiceTile(
                icon: Icons.hub_outlined,
                iconColor: const Color(0xFFD97706),
                title: 'ربط مهام بنوع الأزمة',
                subtitle: 'تحديد خطوات الاستجابة المعيارية لكل نوع بلاغ',
                onTap: () => context.pushNamed(Routes.addIncidentMission),
              ),
              _buildServiceTile(
                icon: Icons.add_task_rounded,
                iconColor: const Color(0xFF4F46E5),
                title: 'إضافة مهمة جديدة',
                subtitle: 'إنشاء مهمة عمل قياسية جديدة وتوصيفها',
                onTap: () => context.pushNamed(Routes.addMissions),
              ),

              const SizedBox(height: 14),

              // 4. إدارة الحساب والنظام
              _buildSectionTitle('إدارة الحساب والنظام'),
              _buildServiceTile(
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFFDC2626),
                title: 'تسجيل الخروج',
                subtitle: 'إنهاء الجلسة الحالية والخروج بأمان من المنظومة',
                isDestructive: true,
                onTap: () => _handleLogout(context),
              ),

              const SizedBox(height: 24),

              // Footer Branding (Clean circular logo, no square background)
              Center(
                child: Column(
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
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.water_drop_rounded,
                                color: appColor,
                                size: 26,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'شركة مياه الشرب والصرف الصحي بالمنيا',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'منظومة إدارة الأزمات والطوارئ - الإصدار 1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryTextColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: primaryTextColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDestructive
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Leading Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDestructive
                              ? const Color(0xFFDC2626)
                              : primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation indicator chevron pointing forward in RTL (left)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: secondaryTextColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
