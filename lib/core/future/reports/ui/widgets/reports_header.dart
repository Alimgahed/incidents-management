import 'package:flutter/material.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/realtime/services/activity_center_store.dart';
import 'package:incidents_managment/core/realtime/ui/live_activity_center_sheet.dart';
import 'package:incidents_managment/core/security/session_manager.dart';

class ReportsHeader extends StatelessWidget {
  final VoidCallback? onToggleFullscreen;

  const ReportsHeader({
    super.key,
    this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    final user = getIt.isRegistered<SessionManager>()
        ? getIt<SessionManager>().getCurrentUser()
        : null;
    final userName = user?.empName ?? user?.username ?? 'مستخدم النظام';
    final userRole = user?.authorityName ?? 'مسؤول المنظومة';

    final activityStore = getIt.isRegistered<ActivityCenterStore>()
        ? getIt<ActivityCenterStore>()
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side: Title + Company Info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF1B72E8),
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'شركة مياه الشرب والصرف الصحي',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'محافظة المنيا',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 24),
              // Blue Icon + Page Title
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insert_chart_rounded,
                  color: Color(0xFF1B72E8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'تقارير الأزمات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'تحليل شامل لبيانات الأزمات ومؤشرات الأداء',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Left Side: Controls & User Profile
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fullscreen button
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, color: Color(0xFF64748B)),
                  tooltip: 'ملء الشاشة',
                  onPressed: onToggleFullscreen,
                ),
              ),
              const SizedBox(width: 12),

              // Notification bell with unread badge
              StreamBuilder<int>(
                stream: activityStore?.unreadCountStream,
                initialData: activityStore?.unreadCount ?? 0,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF64748B),
                          ),
                          tooltip: 'التنبيهات',
                          onPressed: () => showLiveActivityCenter(context),
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 16),

              // User Profile Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1B72E8),
                      child: Text(
                        userName.isNotEmpty ? userName[0] : 'أ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          userRole,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
