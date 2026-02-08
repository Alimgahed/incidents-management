import 'package:flutter/material.dart';
import 'colors.dart'; // Assuming your color constants are in colors.dart

/// =======================
/// SEVERITY COLORS
/// =======================
Color getSeverityColor(int severity) {
  const severityColors = {
    4: warningColor, // High severity - red-ish
    3: infoColor, // Medium-high - blue-ish
    2: buttonColor, // Medium - primary blue
    1: successColor, // Low - green
  };
  return severityColors[severity] ?? successColor;
}

String getSeverityArabic(int severity) {
  const severityLabels = {4: 'حرجة', 3: 'عالية', 2: 'متوسطة', 1: 'منخفضة'};
  return severityLabels[severity] ?? 'منخفضة';
}

/// =======================
/// STATUS COLORS
/// =======================
Color getStatusColor(int status) {
  const statusColors = {
    1: warningColor, // تم التبليغ
    2: buttonColor, // تم الارسال
    3: darkTextSecondary, // قيد التنفيذ
    4: darkDivider, // قيد الانتظار
    5: infoColor, // قيد المراجعة
    6: successColor, // تم حلها
    7: warningColor, // تم الرفض
  };
  return statusColors[status] ?? darkTextSecondary;
}

String getStatusArabic(int status) {
  const statusLabels = {
    1: 'تم التبليغ',
    2: 'تم الارسال',
    3: 'قيد التنفيذ',
    4: 'قيد الانتظار',
    5: 'قيد المراجعة',
    6: 'تم حلها',
    7: 'تم الرفض',
  };
  return statusLabels[status] ?? 'غير معروف';
}

const List<int> allStatuses = [1, 2, 3, 4, 6, 7];

String getStatusArabicLabel(int status) {
  const statusLabels = {
    1: 'تم التبليغ',
    2: 'تم الارسال',
    3: 'قيد التنفيذ',
    4: 'قيد الانتظار',
    6: 'تم حلها',
    7: 'تم الرفض',
  };
  return statusLabels[status] ?? 'غير معروف';
}
