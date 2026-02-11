import 'package:intl/intl.dart';

extension DurationFormatter on Duration {
  String format() {
    final days = inDays;
    final hours = inHours.remainder(24);
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (days > 0) {
      return '$days يوم ${hours > 0 ? 'و $hours ساعة' : ''}';
    }

    if (hours > 0) {
      return '${_two(hours)}:${_two(minutes)}:${_two(seconds)}';
    }

    return '${_two(minutes)}:${_two(seconds)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}


extension TimeAgoArabic on DateTime {
  static final DateFormat _fullDate = DateFormat('d MMMM y', 'ar');
  static final DateFormat _shortDate = DateFormat('d MMM yyyy', 'ar');

  String timeAgoArabic() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      return _fullDate.format(this); // تاريخ مستقبلي
    }

    if (difference.inSeconds < 60) {
      return 'الآن';
    }

    if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return 'قبل $m ${_pluralMinute(m)}';
    }

    if (difference.inHours < 24) {
      final h = difference.inHours;
      return 'قبل $h ${_pluralHour(h)}';
    }

    if (difference.inDays == 1) {
      return 'أمس';
    }

    if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} ${_pluralDay(difference.inDays)}';
    }

    return _shortDate.format(this);
  }

  String _pluralMinute(int value) =>
      value == 1 ? 'دقيقة' : 'دقائق';

  String _pluralHour(int value) =>
      value == 1 ? 'ساعة' : 'ساعات';

  String _pluralDay(int value) =>
      value == 1 ? 'يوم' : 'أيام';
}
