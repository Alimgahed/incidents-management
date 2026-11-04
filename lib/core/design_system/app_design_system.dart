import 'package:flutter/material.dart';

// =============================================================================
// GLOBAL DESIGN SYSTEM — TOKENS, BREAKPOINTS & STATE FEEDBACK WIDGETS
// =============================================================================

/// Unified color tokens across Web, Tablet, and Mobile modules.
abstract final class AppColors {
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryDark = Color(0xFF0F3B6C);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color accent = Color(0xFF1B64F2);

  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFEAFBF1);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFF8EB);

  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFDF0F0);

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoBg = Color(0xFFEAF6FF);

  // Shimmer palette
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color shimmerSurface = Color(0xFFF1F5F9);
}

/// Centralized semantic status & severity color helper across the platform.
abstract final class AppStatusColors {
  static Color forStatusId(int? statusId) {
    switch (statusId) {
      case 1: // قيد الانتظار / بلاغ جديد
        return AppColors.warning;
      case 2: // جاري العمل
        return AppColors.accent;
      case 3: // تم الحل / مكتمل
        return AppColors.success;
      case 4: // مغلق / ملغي
        return AppColors.textSecondary;
      default:
        return AppColors.info;
    }
  }

  static Color bgForStatusId(int? statusId) {
    switch (statusId) {
      case 1:
        return AppColors.warningBg;
      case 2:
        return AppColors.primaryLight;
      case 3:
        return AppColors.successBg;
      case 4:
        return AppColors.surfaceSubtle;
      default:
        return AppColors.infoBg;
    }
  }

  static Color forSeverityId(int? severityId) {
    switch (severityId) {
      case 1: // منخفضة
        return AppColors.success;
      case 2: // متوسطة
        return AppColors.warning;
      case 3: // عالية
      case 4: // حرجة
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  static Color bgForSeverityId(int? severityId) {
    switch (severityId) {
      case 1:
        return AppColors.successBg;
      case 2:
        return AppColors.warningBg;
      case 3:
      case 4:
        return AppColors.errorBg;
      default:
        return AppColors.infoBg;
    }
  }
}

/// Consistent spacing scale (4px baseline grid).
abstract final class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

/// Consistent border radius scale.
abstract final class AppRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double pill = 999.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderPill = BorderRadius.all(
    Radius.circular(pill),
  );
}

/// Elevation & shadow presets.
abstract final class AppShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F0F172A), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

/// Standard animation durations across the application.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration shimmerCycle = Duration(milliseconds: 1350);
}

/// Responsive layout breakpoints and adaptive helpers for Mobile, Tablet, and Web.
abstract final class AppBreakpoints {
  static const double mobileMax = 767.0;
  static const double tabletMax = 1199.0;
  static const double desktopMin = 1200.0;

  static bool isMobileWidth(double width) => width <= mobileMax;
  static bool isTabletWidth(double width) =>
      width > mobileMax && width <= tabletMax;
  static bool isDesktopWidth(double width) => width >= desktopMin;

  static bool isMobile(BuildContext context) =>
      isMobileWidth(MediaQuery.sizeOf(context).width);

  static bool isTablet(BuildContext context) =>
      isTabletWidth(MediaQuery.sizeOf(context).width);

  static bool isDesktop(BuildContext context) =>
      isDesktopWidth(MediaQuery.sizeOf(context).width);

  static int adaptiveGridColumns(
    double width, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int wideDesktop = 4,
  }) {
    if (width >= 1500) return wideDesktop;
    if (width >= desktopMin) return desktop;
    if (width > mobileMax) return tablet;
    return mobile;
  }
}

/// Standardized Arabic-first typography hierarchy.
abstract final class AppTextStyles {
  static const String fontFamily = 'Cairo';

  static const TextStyle headingXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textHint,
    height: 1.35,
  );
}

// =============================================================================
// REUSABLE STATE FEEDBACK WIDGETS (EMPTY, ERROR, INLINE REFRESH BANNER)
// =============================================================================

/// Unified, accessible empty state widget with optional action button.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xxl),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 52 : 68,
                height: compact ? 52 : 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: compact ? 26 : 34,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
              Text(
                title,
                style: compact
                    ? AppTextStyles.headingMd
                    : AppTextStyles.headingLg,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySm,
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Unified, accessible error state widget with retry action.
class AppErrorState extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final bool compact;

  const AppErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xxl),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.error.withValues(alpha: 0.28)),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 52 : 68,
                height: compact ? 52 : 68,
                decoration: const BoxDecoration(
                  color: AppColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: compact ? 26 : 34,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
              Text(
                title ?? 'تعذر تحميل البيانات',
                style: compact
                    ? AppTextStyles.headingMd
                    : AppTextStyles.headingLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Non-blocking inline refresh indicator shown at the top of a screen while
/// preserving existing data during background refreshes.
class AppInlineRefreshBanner extends StatelessWidget {
  final bool isRefreshing;
  final String? label;

  const AppInlineRefreshBanner({
    super.key,
    required this.isRefreshing,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRefreshing) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 2.5,
          child: LinearProgressIndicator(
            backgroundColor: Color(0xFFE2E8F0),
            color: AppColors.accent,
          ),
        ),
        if (label != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            color: AppColors.infoBg,
            child: Text(
              label!,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// REUSABLE ENTERPRISE UI COMPONENTS
// =============================================================================

/// Standardized responsive page container with optional max-width constraint.
class AppPageContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const AppPageContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
          vertical: isMobile ? AppSpacing.md : AppSpacing.lg,
        );

    Widget content = Padding(padding: effectivePadding, child: child);
    if (maxWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: content,
        ),
      );
    }
    return content;
  }
}

/// Standardized workspace/section header with icon, title, subtitle, back button, and actions.
class AppWorkspaceHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final String? backTooltip;

  const AppWorkspaceHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.onBack,
    this.backTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              tooltip: backTooltip ?? 'رجوع',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceSubtle,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderSm,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.headingMd),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.bodySm),
                ],
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions!,
            ),
        ],
      ),
    );
  }
}

/// Standardized KPI summary card used across dashboards and modules.
class AppKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.accent,
    this.subtitle,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.08) : AppColors.surface,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      value,
                      style: AppTextStyles.headingLg.copyWith(color: color),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}

/// Standardized RTL search input with clear button.
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'بحث...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMd,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller!.clear();
                    onChanged?.call('');
                    onClear?.call();
                  },
                  icon: const Icon(Icons.close_rounded, size: 16),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceSubtle,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.borderSm,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderSm,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.borderSm,
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Standardized primary/secondary action button with built-in loading state.
class AppActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;

  const AppActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.accent;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isOutlined ? effectiveColor : Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(color: effectiveColor.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        ),
        child: child,
      );
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
      ),
      child: child,
    );
  }
}
