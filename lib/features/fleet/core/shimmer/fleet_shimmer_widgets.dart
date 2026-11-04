import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/fleet_design_system.dart';

/// Base wrapper that applies the project's centralized shimmer animation.
class FleetShimmerEffect extends StatelessWidget {
  final Widget child;

  const FleetShimmerEffect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FleetColors.shimmerBase,
      highlightColor: FleetColors.shimmerHighlight,
      period: const Duration(milliseconds: 1350),
      direction: ShimmerDirection.rtl,
      child: child,
    );
  }
}

class FleetShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const FleetShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = FleetRadius.xs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class FleetShimmerCircle extends StatelessWidget {
  final double size;

  const FleetShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 1. Header Shimmer
class FleetHeaderShimmer extends StatelessWidget {
  const FleetHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: FleetColors.surfaceWhite,
        borderRadius: BorderRadius.circular(FleetRadius.xl),
        border: Border.all(color: FleetColors.borderLight),
      ),
      child: const FleetShimmerEffect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FleetShimmerCircle(size: 36),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FleetShimmerBox(width: 160, height: 14),
                    SizedBox(height: 6),
                    FleetShimmerBox(width: 110, height: 10),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                FleetShimmerBox(width: 120, height: 28, borderRadius: 20),
                SizedBox(width: 12),
                FleetShimmerCircle(size: 36),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 2. Fleet Statistics Shimmer (4 KPI Cards matching exact 112px height)
class FleetStatisticsShimmer extends StatelessWidget {
  const FleetStatisticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final cards = List.generate(4, (_) => const _KpiCardSkeleton());

        if (isWide) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (c) => SizedBox(
                  width: (constraints.maxWidth - 12) / 2,
                  child: c,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _KpiCardSkeleton extends StatelessWidget {
  const _KpiCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: FleetColors.surfaceWhite,
        borderRadius: BorderRadius.circular(FleetRadius.lg),
        border: Border.all(color: FleetColors.borderLight),
      ),
      child: const FleetShimmerEffect(
        child: Row(
          children: [
            FleetShimmerCircle(size: 48),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FleetShimmerBox(width: 90, height: 12),
                  SizedBox(height: 10),
                  FleetShimmerBox(width: 64, height: 26, borderRadius: 8),
                  SizedBox(height: 8),
                  FleetShimmerBox(width: 105, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3. Fleet Filters Shimmer (Search row + Advanced Filters row)
class FleetFiltersShimmer extends StatelessWidget {
  const FleetFiltersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar + Action Buttons Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: FleetColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(FleetRadius.md),
                  border: Border.all(color: FleetColors.borderLight),
                ),
                child: const FleetShimmerEffect(
                  child: Row(
                    children: [
                      FleetShimmerCircle(size: 20),
                      SizedBox(width: 12),
                      FleetShimmerBox(width: 220, height: 12),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 130,
              height: 46,
              decoration: BoxDecoration(
                color: FleetColors.surfaceWhite,
                borderRadius: BorderRadius.circular(FleetRadius.md),
                border: Border.all(color: FleetColors.borderLight),
              ),
              child: const FleetShimmerEffect(
                child: Center(child: FleetShimmerBox(width: 90, height: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 145,
              height: 46,
              decoration: BoxDecoration(
                color: FleetColors.surfaceWhite,
                borderRadius: BorderRadius.circular(FleetRadius.md),
                border: Border.all(color: FleetColors.borderLight),
              ),
              child: const FleetShimmerEffect(
                child: Center(child: FleetShimmerBox(width: 105, height: 14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Advanced Filter Dropdowns Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: FleetColors.surfaceWhite,
            borderRadius: BorderRadius.circular(FleetRadius.md),
            border: Border.all(color: FleetColors.borderLight),
          ),
          child: const FleetShimmerEffect(
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                FleetShimmerBox(width: 95, height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    FleetShimmerBox(width: 185, height: 42, borderRadius: 10),
                    FleetShimmerBox(width: 185, height: 42, borderRadius: 10),
                    FleetShimmerBox(width: 185, height: 42, borderRadius: 10),
                    FleetShimmerBox(width: 165, height: 42, borderRadius: 10),
                  ],
                ),
                FleetShimmerBox(width: 105, height: 40, borderRadius: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 4. Vehicle Row Shimmer (Matches exact 8-column table layout)
class VehicleRowShimmer extends StatelessWidget {
  const VehicleRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FleetColors.borderLight)),
      ),
      child: const FleetShimmerEffect(
        child: Row(
          children: [
            // #
            SizedBox(
              width: 36,
              child: FleetShimmerBox(width: 20, height: 14),
            ),
            // المركبة / رقم اللوحة
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  FleetShimmerBox(width: 48, height: 38, borderRadius: 8),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FleetShimmerBox(width: 72, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      FleetShimmerBox(width: 96, height: 16, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
            // الفرع
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  FleetShimmerCircle(size: 16),
                  SizedBox(width: 6),
                  FleetShimmerBox(width: 78, height: 14),
                ],
              ),
            ),
            // النوع
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FleetShimmerBox(width: 64, height: 13),
                  SizedBox(height: 5),
                  FleetShimmerBox(width: 48, height: 11),
                ],
              ),
            ),
            // جهاز التتبع (IMEI)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FleetShimmerBox(width: 75, height: 13),
                  SizedBox(height: 5),
                  FleetShimmerBox(width: 135, height: 11),
                ],
              ),
            ),
            // آخر تحديث
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  FleetShimmerCircle(size: 14),
                  SizedBox(width: 6),
                  FleetShimmerBox(width: 85, height: 13),
                ],
              ),
            ),
            // الحالة
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FleetShimmerBox(width: 80, height: 24, borderRadius: 20),
                  SizedBox(height: 5),
                  FleetShimmerBox(width: 68, height: 10),
                ],
              ),
            ),
            // الموقع
            SizedBox(
              width: 130,
              child: FleetShimmerBox(width: 118, height: 34, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

/// 5. Full Vehicle Table Shimmer (Header + 8 Skeleton Rows + Footer)
class VehicleTableShimmer extends StatelessWidget {
  final int rowCount;

  const VehicleTableShimmer({super.key, this.rowCount = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FleetColors.surfaceWhite,
        borderRadius: BorderRadius.circular(FleetRadius.lg),
        border: Border.all(color: FleetColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header Skeleton
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: FleetColors.tableHeaderBg,
            child: const FleetShimmerEffect(
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: FleetShimmerBox(width: 16, height: 12),
                  ),
                  Expanded(
                    flex: 3,
                    child: FleetShimmerBox(width: 110, height: 12),
                  ),
                  Expanded(
                    flex: 2,
                    child: FleetShimmerBox(width: 60, height: 12),
                  ),
                  Expanded(
                    flex: 2,
                    child: FleetShimmerBox(width: 55, height: 12),
                  ),
                  Expanded(
                    flex: 3,
                    child: FleetShimmerBox(width: 100, height: 12),
                  ),
                  Expanded(
                    flex: 2,
                    child: FleetShimmerBox(width: 75, height: 12),
                  ),
                  Expanded(
                    flex: 2,
                    child: FleetShimmerBox(width: 60, height: 12),
                  ),
                  SizedBox(
                    width: 130,
                    child: FleetShimmerBox(width: 70, height: 12),
                  ),
                ],
              ),
            ),
          ),
          // Skeleton Rows
          for (int i = 0; i < rowCount; i++) const VehicleRowShimmer(),
          // Footer Pagination Skeleton
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: FleetColors.surfaceSubtle,
            child: const FleetShimmerEffect(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FleetShimmerBox(width: 135, height: 14),
                  Row(
                    children: [
                      FleetShimmerBox(width: 32, height: 32, borderRadius: 8),
                      SizedBox(width: 6),
                      FleetShimmerBox(width: 32, height: 32, borderRadius: 8),
                      SizedBox(width: 6),
                      FleetShimmerBox(width: 32, height: 32, borderRadius: 8),
                    ],
                  ),
                  FleetShimmerBox(width: 150, height: 32, borderRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. Complete Fleet List Page Shimmer
class FleetDashboardPageShimmer extends StatelessWidget {
  const FleetDashboardPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FleetStatisticsShimmer(),
          SizedBox(height: 16),
          FleetFiltersShimmer(),
          SizedBox(height: 16),
          VehicleTableShimmer(rowCount: 6),
        ],
      ),
    );
  }
}

/// 7. Map Overlay Shimmer (Matches Floating Filter Bar + Stacked Controls)
class FleetMapShimmer extends StatelessWidget {
  const FleetMapShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.white.withAlpha(150),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top filter bar skeleton
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    5,
                    (i) => Container(
                      width: i == 0 ? 270 : 130,
                      height: 38,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const FleetShimmerEffect(
                        child: FleetShimmerBox(height: 14, borderRadius: 6),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 36,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const FleetShimmerEffect(
                        child: FleetShimmerBox(height: 14, borderRadius: 6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 110,
                      height: 36,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const FleetShimmerEffect(
                        child: FleetShimmerBox(height: 14, borderRadius: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Right stacked controls skeleton
            Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: 322,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const FleetShimmerEffect(
                              child: FleetShimmerBox(height: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const FleetShimmerEffect(
                              child: FleetShimmerBox(height: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const FleetShimmerEffect(
                        child: FleetShimmerBox(height: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const FleetShimmerEffect(
                        child: FleetShimmerBox(height: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 8. Vehicle Details Card Shimmer
class VehicleDetailsShimmer extends StatelessWidget {
  const VehicleDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      decoration: BoxDecoration(
        color: FleetColors.surfaceWhite,
        borderRadius: BorderRadius.circular(FleetRadius.xl),
        border: Border.all(color: FleetColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: const FleetShimmerEffect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                FleetShimmerBox(width: 44, height: 38, borderRadius: 8),
                SizedBox(width: 12),
                Expanded(child: FleetShimmerBox(height: 18)),
                SizedBox(width: 12),
                FleetShimmerBox(width: 75, height: 24, borderRadius: 20),
              ],
            ),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FleetShimmerBox(height: 52, borderRadius: 10),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FleetShimmerBox(height: 52, borderRadius: 10),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FleetShimmerBox(height: 52, borderRadius: 10),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FleetShimmerBox(height: 52, borderRadius: 10),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FleetShimmerBox(height: 52, borderRadius: 10),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FleetShimmerBox(height: 52, borderRadius: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 9. Trips Timeline Shimmer (Reusable skeleton for Trip History)
class TripsShimmer extends StatelessWidget {
  final int itemCount;

  const TripsShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FleetColors.surfaceWhite,
          borderRadius: BorderRadius.circular(FleetRadius.md),
          border: Border.all(color: FleetColors.borderLight),
        ),
        child: const FleetShimmerEffect(
          child: Row(
            children: [
              FleetShimmerCircle(size: 36),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FleetShimmerBox(width: 140, height: 14),
                    SizedBox(height: 6),
                    FleetShimmerBox(width: 200, height: 11),
                  ],
                ),
              ),
              FleetShimmerBox(width: 65, height: 22, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// 10. Alerts Card Shimmer (Reusable skeleton for Fleet Alerts)
class AlertsShimmer extends StatelessWidget {
  final int itemCount;

  const AlertsShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FleetColors.surfaceWhite,
          borderRadius: BorderRadius.circular(FleetRadius.md),
          border: Border.all(color: FleetColors.borderLight),
        ),
        child: const FleetShimmerEffect(
          child: Row(
            children: [
              FleetShimmerBox(width: 40, height: 40, borderRadius: 10),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FleetShimmerBox(width: 160, height: 14),
                    SizedBox(height: 6),
                    FleetShimmerBox(width: 110, height: 11),
                  ],
                ),
              ),
              FleetShimmerBox(width: 72, height: 24, borderRadius: 20),
            ],
          ),
        ),
      ),
    );
  }
}
