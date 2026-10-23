import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';

enum EmptyStateType {
  noIncidents,
  noSearchResults,
  error,
}

class MobileHomeEmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? errorMessage;
  final VoidCallback onAction;

  const MobileHomeEmptyState({
    super.key,
    required this.type,
    this.errorMessage,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color bgColor;
    String title;
    String message;
    String actionLabel;
    IconData actionIcon;

    switch (type) {
      case EmptyStateType.error:
        icon = Icons.cloud_off_rounded;
        iconColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEE2E2);
        title = 'تعذر الاتصال بالخادم';
        message = errorMessage ??
            'حدث خطأ أثناء تحميل بيانات الأزمات. يرجى التحقق من اتصال الإنترنت والمحاولة مجدداً.';
        actionLabel = 'إعادة المحاولة';
        actionIcon = Icons.refresh_rounded;
        break;

      case EmptyStateType.noSearchResults:
        icon = Icons.search_off_rounded;
        iconColor = const Color(0xFF2563EB);
        bgColor = const Color(0xFFEFF6FF);
        title = 'لا توجد نتائج مطابقة';
        message =
            'لم يتم العثور على أي بلاغات تطابق معايير البحث أو الفلاتر المحددة حالياً.';
        actionLabel = 'إعادة ضبط الفلاتر';
        actionIcon = Icons.filter_alt_off_rounded;
        break;

      case EmptyStateType.noIncidents:
        icon = Icons.verified_user_outlined;
        iconColor = const Color(0xFF1E56A0);
        bgColor = const Color(0xFF1E56A0).withValues(alpha: 0.08);
        title = 'لا توجد أزمات حالية';
        message =
            'جميع قطاعات ومحطات مياه الشرب والصرف الصحي تعمل بحالة استقرار دون بلاغات طارئة مسجلة.';
        actionLabel = 'تحديث البيانات';
        actionIcon = Icons.refresh_rounded;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 44,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 17),
              label: Text(
                actionLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: iconColor,
                side: BorderSide(color: iconColor.withValues(alpha: 0.6), width: 1.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
