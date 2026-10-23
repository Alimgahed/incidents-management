import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/realtime/services/activity_center_store.dart';
import 'package:incidents_managment/core/realtime/ui/live_activity_center_sheet.dart';
import 'package:incidents_managment/core/security/session_manager.dart';

class MobileHomeHeader extends StatelessWidget {
  final List<CurrentIncidentModel> incidents;

  const MobileHomeHeader({super.key, required this.incidents});

  String _formatArabicHeaderDate() {
    final now = DateTime.now();
    const arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final dayName = arabicDays[(now.weekday - 1) % 7];
    final monthName = arabicMonths[(now.month - 1) % 12];
    return '$dayName - ${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt.isRegistered<SessionManager>()
        ? getIt<SessionManager>().getCurrentUser()
        : null;
    final rawName = currentUser?.empName?.trim().isNotEmpty == true
        ? currentUser!.empName!.trim()
        : (currentUser?.username?.trim().isNotEmpty == true
              ? currentUser!.username!.trim()
              : null);
    final userGreeting = rawName != null ? 'مرحباً، $rawName' : 'أهلاً بعودتك';
    final userRole = currentUser?.authorityName?.trim().isNotEmpty == true
        ? currentUser!.authorityName!.trim()
        : 'منظومة الطوارئ والأزمات';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F3B6C),
        image: DecorationImage(
          image: AssetImage('assets/images/header_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A2240).withValues(alpha: 0.94),
              const Color(0xFF0F3866).withValues(alpha: 0.88),
              const Color(0xFF164780).withValues(alpha: 0.97),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Company Branding on Right, Alert Action on Left (RTL)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Official Company Logo
                    Container(
                      width: 44,
                      height: 44,
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
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.water_drop_rounded,
                                color: appColor,
                                size: 24,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'منظومة إدارة الأزمات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'شركة مياه الشرب والصرف الصحي بالمنيا',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Notification Button with Dynamic Activity Center Badge
                    StreamBuilder<int>(
                      stream: getIt.isRegistered<ActivityCenterStore>()
                          ? getIt<ActivityCenterStore>().unreadCountStream
                          : null,
                      initialData: getIt.isRegistered<ActivityCenterStore>()
                          ? getIt<ActivityCenterStore>().unreadCount
                          : 0,
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        return GestureDetector(
                          onTap: () => showLiveActivityCenter(context),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      unreadCount > 99
                                          ? '99+'
                                          : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Bottom Row: User greeting & Date/Time chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // User Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                userRole,
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userGreeting,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Date chip (Glassmorphic)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wb_sunny_rounded,
                            color: Color(0xFFFBBF24),
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatArabicHeaderDate(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
