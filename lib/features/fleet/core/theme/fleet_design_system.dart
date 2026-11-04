import 'package:flutter/material.dart';

/// Centralized color tokens for the ETIT GPS Fleet Management module.
abstract final class FleetColors {
  // Brand & Primary
  static const Color primaryNavy = Color(0xFF0F3B6C);
  static const Color primaryBlue = Color(0xFF1B4F8A);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color secondaryTeal = Color(0xFF0D9488);

  // Semantic Status — Moving (Green)
  static const Color movingText = Color(0xFF15803D);
  static const Color movingDot = Color(0xFF16A34A);
  static const Color movingCardBg = Color(0xFFEAFBF0);
  static const Color movingBadgeBg = Color(0xFFDCFCE7);
  static const Color movingBorder = Color(0xFFBBF7D0);

  // Semantic Status — Stopped (Amber / Orange)
  static const Color stoppedText = Color(0xFFB45309);
  static const Color stoppedDot = Color(0xFFD97706);
  static const Color stoppedCardBg = Color(0xFFFFF8EB);
  static const Color stoppedBadgeBg = Color(0xFFFEF3C7);
  static const Color stoppedBorder = Color(0xFFFDE68A);

  // Semantic Status — Offline / Disconnected (Red)
  static const Color offlineText = Color(0xFFB91C1C);
  static const Color offlineDot = Color(0xFFDC2626);
  static const Color offlineCardBg = Color(0xFFFEF2F2);
  static const Color offlineBadgeBg = Color(0xFFFEE2E2);
  static const Color offlineBorder = Color(0xFFFECACA);

  // Total KPI Card (Blue)
  static const Color totalIcon = Color(0xFF1D4ED8);
  static const Color totalCardBg = Color(0xFFEAF3FF);
  static const Color totalIconBg = Color(0xFFDBEAFE);
  static const Color totalBorder = Color(0xFFBFDBFE);

  // Surfaces & Borders
  static const Color pageBackground = Color(0xFFF4F7FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color tableHeaderBg = Color(0xFFE8EEF5);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color selectedRowBg = Color(0xFFEFF6FF);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}

/// Centralized spacing tokens.
abstract final class FleetSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
}

/// Centralized border radius tokens.
abstract final class FleetRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double pill = 999.0;
}

/// Centralized typography styles for Arabic RTL fleet surfaces.
abstract final class FleetTextStyles {
  static const TextStyle kpiCount = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: FleetColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle kpiTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle kpiSubtitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: FleetColors.textMuted,
  );

  static const TextStyle tableHeader = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: FleetColors.primaryNavy,
  );

  static const TextStyle plateTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: FleetColors.textPrimary,
  );

  static const TextStyle codeBadge = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    color: FleetColors.textSecondary,
  );

  static const TextStyle cellPrimary = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: FleetColors.textPrimary,
  );

  static const TextStyle cellSecondary = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: FleetColors.textMuted,
  );
}

/// Responsive layout breakpoints for Web, Tablet, and Mobile.
enum FleetDeviceLayout { mobile, tablet, desktop }

abstract final class FleetResponsive {
  static const double mobileMaxWidth = 720.0;
  static const double tabletMaxWidth = 1100.0;

  static FleetDeviceLayout layoutForWidth(double width) {
    if (width < mobileMaxWidth) return FleetDeviceLayout.mobile;
    if (width < tabletMaxWidth) return FleetDeviceLayout.tablet;
    return FleetDeviceLayout.desktop;
  }

  static bool isMobile(double width) => width < mobileMaxWidth;
  static bool isTablet(double width) =>
      width >= mobileMaxWidth && width < tabletMaxWidth;
  static bool isDesktop(double width) => width >= tabletMaxWidth;
}

/// Cached, allocation-free date parser & Arabic formatter for ETIT timestamps.
abstract final class FleetDateFormatter {
  static final Map<String, DateTime?> _parseCache = {};

  static const Map<String, int> _months = {
    'january': 1,
    'february': 2,
    'march': 3,
    'april': 4,
    'may': 5,
    'june': 6,
    'july': 7,
    'august': 8,
    'september': 9,
    'october': 10,
    'november': 11,
    'december': 12,
  };

  static final RegExp _etitDateRegex = RegExp(
    r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?',
  );

  static DateTime? parseEtitDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.trim();
    if (_parseCache.containsKey(clean)) {
      return _parseCache[clean];
    }

    DateTime? parsed = DateTime.tryParse(clean);
    if (parsed == null) {
      final m = _etitDateRegex.firstMatch(clean);
      if (m != null) {
        final day = int.tryParse(m.group(1)!) ?? 1;
        final mon = _months[m.group(2)!.toLowerCase()] ?? 1;
        final year = int.tryParse(m.group(3)!) ?? 2026;
        final hour = int.tryParse(m.group(4)!) ?? 0;
        final min = int.tryParse(m.group(5)!) ?? 0;
        final sec = int.tryParse(m.group(6) ?? '0') ?? 0;
        parsed = DateTime(year, mon, day, hour, min, sec);
      }
    }

    if (_parseCache.length > 500) {
      _parseCache.clear();
    }
    _parseCache[clean] = parsed;
    return parsed;
  }

  static String formatArabicTimestamp(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'غير متوفر';
    final dt = parseEtitDate(raw);
    if (dt == null) return raw;
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'م' : 'ص';
    final timeStr =
        '${hour12.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $amPm';
    if (isToday) return 'اليوم $timeStr';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} $timeStr';
  }

  static String formatRelativeDuration(String? raw, {bool short = false}) {
    final dt = parseEtitDate(raw);
    if (dt == null) return short ? '' : 'غير متوفر';
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) {
      return short ? '${diff.inMinutes} د' : 'منذ ${diff.inMinutes} دقيقة';
    }
    if (diff.inHours < 24) {
      if (short) return '${diff.inHours} س';
      final h = diff.inHours;
      if (h == 1) return 'منذ ساعة';
      if (h == 2) return 'منذ ساعتين';
      if (h <= 10) return 'منذ $h ساعات';
      return 'منذ $h ساعة';
    }
    final d = diff.inDays;
    return short ? '$d ي' : 'منذ $d يوم';
  }

  static String formatSyncTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'م' : 'ص';
    return 'اليوم ${hour12.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} $amPm';
  }
}
