import 'package:flutter/material.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';

// =============================================================================
// LEVEL 1 — REUSABLE SHIMMER PRIMITIVES
// =============================================================================

/// Coordinates a single shared shimmer animation across all descendant
/// shimmer primitives so even complex screens only tick one controller.
/// Automatically respects `MediaQuery.maybeDisableAnimationsOf(context)`.
class AppShimmerScope extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmerScope({
    super.key,
    required this.child,
    this.baseColor = AppColors.shimmerBase,
    this.highlightColor = AppColors.shimmerHighlight,
    this.duration = AppDurations.shimmerCycle,
  });

  static Animation<double>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedShimmerScope>()
        ?.animation;
  }

  @override
  State<AppShimmerScope> createState() => _AppShimmerScopeState();
}

class _AppShimmerScopeState extends State<AppShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.value = 0.5;
      }
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      return _InheritedShimmerScope(
        animation: _controller,
        baseColor: widget.baseColor,
        highlightColor: widget.highlightColor,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _controller.value * 2.4 - 0.7;
            return LinearGradient(
              begin: Alignment(-1.0 + slide, -0.2),
              end: Alignment(0.2 + slide, 0.2),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: _InheritedShimmerScope(
        animation: _controller,
        baseColor: widget.baseColor,
        highlightColor: widget.highlightColor,
        child: widget.child,
      ),
    );
  }
}

class _InheritedShimmerScope extends InheritedWidget {
  final Animation<double> animation;
  final Color baseColor;
  final Color highlightColor;

  const _InheritedShimmerScope({
    required this.animation,
    required this.baseColor,
    required this.highlightColor,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _InheritedShimmerScope oldWidget) {
    return baseColor != oldWidget.baseColor ||
        highlightColor != oldWidget.highlightColor;
  }
}

/// Base rectangular shimmer block. Automatically wraps itself in an
/// [AppShimmerScope] if not already inside one.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.sm,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (AppShimmerScope.maybeOf(context) != null) {
      return box;
    }
    return AppShimmerScope(child: box);
  }
}

/// Circular shimmer primitive for icons, status dots, and chart rings.
class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const ShimmerCircle({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.shimmerBase,
        shape: BoxShape.circle,
      ),
    );

    if (AppShimmerScope.maybeOf(context) != null) {
      return circle;
    }
    return AppShimmerScope(child: circle);
  }
}

/// Single-line text placeholder matching typographic line height.
class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerLine({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: width, height: height, borderRadius: borderRadius);
  }
}

/// Multi-line paragraph placeholder with realistic trailing line width.
class ShimmerText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineWidthFactor;

  const ShimmerText({
    super.key,
    this.lines = 2,
    this.lineHeight = 12,
    this.spacing = 8,
    this.lastLineWidthFactor = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1 && lines > 1;
        return Padding(
          padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : spacing),
          child: FractionallySizedBox(
            widthFactor: isLast ? lastLineWidthFactor : 1.0,
            child: ShimmerLine(height: lineHeight),
          ),
        );
      }),
    );
  }
}

/// User / vehicle avatar placeholder (circle or rounded square).
class ShimmerAvatar extends StatelessWidget {
  final double size;
  final bool isCircular;

  const ShimmerAvatar({super.key, this.size = 40, this.isCircular = true});

  @override
  Widget build(BuildContext context) {
    if (isCircular) {
      return ShimmerCircle(size: size);
    }
    return ShimmerBox(
      width: size,
      height: size,
      borderRadius: AppRadius.md,
    );
  }
}

/// Action button placeholder matching standard button dimensions.
class ShimmerButton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerButton({
    super.key,
    this.width = 120,
    this.height = 40,
    this.borderRadius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(width: width, height: height, borderRadius: borderRadius);
  }
}

/// Form input / dropdown field placeholder with optional label bar above.
class ShimmerInput extends StatelessWidget {
  final double? width;
  final double height;
  final bool showLabel;
  final double labelWidth;

  const ShimmerInput({
    super.key,
    this.width,
    this.height = 46,
    this.showLabel = false,
    this.labelWidth = 96,
  });

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      return ShimmerBox(
        width: width,
        height: height,
        borderRadius: AppRadius.md,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ShimmerLine(width: labelWidth, height: 12),
        const SizedBox(height: 8),
        ShimmerBox(
          width: width,
          height: height,
          borderRadius: AppRadius.md,
        ),
      ],
    );
  }
}

/// Surface card container for structured shimmer skeletons.
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Widget? child;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.borderRadius = AppRadius.lg,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child:
          child ??
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: ShimmerLine(width: 84, height: 11)),
                  SizedBox(width: 8),
                  ShimmerAvatar(size: 22, isCircular: false),
                ],
              ),
              SizedBox(height: 6),
              ShimmerLine(width: 56, height: 16),
              SizedBox(height: 4),
              ShimmerLine(width: 100, height: 9),
            ],
          ),
    );
  }
}

/// Structured table row placeholder matching enterprise data tables.
class ShimmerTableRow extends StatelessWidget {
  final int columns;
  final bool hasLeadingAvatar;
  final bool hasTrailingAction;
  final EdgeInsetsGeometry padding;

  const ShimmerTableRow({
    super.key,
    this.columns = 5,
    this.hasLeadingAvatar = true,
    this.hasTrailingAction = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (hasLeadingAvatar) ...[
            const ShimmerAvatar(size: 38),
            const SizedBox(width: 12),
          ],
          ...List.generate(columns, (index) {
            final flex = index == 0 ? 3 : 2;
            return Expanded(
              flex: flex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerLine(
                      width: index == 0 ? 130 : 85,
                      height: 13,
                    ),
                    if (index == 0) ...[
                      const SizedBox(height: 6),
                      const ShimmerLine(width: 80, height: 10),
                    ],
                  ],
                ),
              ),
            );
          }),
          if (hasTrailingAction) ...[
            const SizedBox(width: 8),
            const ShimmerButton(
              width: 84,
              height: 32,
              borderRadius: AppRadius.sm,
            ),
          ],
        ],
      ),
    );
  }
}

/// Structured list item placeholder matching incident, user, or mission cards.
class ShimmerListItem extends StatelessWidget {
  final bool hasLeadingAvatar;
  final bool hasStatusBadge;
  final bool hasSubtitle;
  final EdgeInsetsGeometry? margin;

  const ShimmerListItem({
    super.key,
    this.hasLeadingAvatar = true,
    this.hasStatusBadge = true,
    this.hasSubtitle = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerCard(
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          if (hasLeadingAvatar) ...[
            const ShimmerAvatar(size: 42, isCircular: false),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShimmerLine(width: 150, height: 14),
                if (hasSubtitle) ...[
                  const SizedBox(height: 8),
                  const ShimmerLine(width: 105, height: 11),
                ],
              ],
            ),
          ),
          if (hasStatusBadge) ...[
            const SizedBox(width: 10),
            const ShimmerBox(
              width: 68,
              height: 26,
              borderRadius: AppRadius.pill,
            ),
          ],
        ],
      ),
    );
  }
}
