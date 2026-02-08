import 'package:intl/intl.dart';

extension TimeAgoArabic on DateTime {
  String timeAgoArabic() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'قبل ${difference.inMinutes} دقيقة${difference.inMinutes > 1 ? 'ـ' : ''}';
    } else if (difference.inHours < 24) {
      return 'قبل ${difference.inHours} ساعة${difference.inHours > 1 ? 'ـ' : ''}';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} يوم${difference.inDays > 1 ? 'ـ' : ''}';
    } else {
      // Older than a week, show formatted date in Arabic locale
      return DateFormat('d MMM yyyy', 'ar').format(this);
    }
  }
}
