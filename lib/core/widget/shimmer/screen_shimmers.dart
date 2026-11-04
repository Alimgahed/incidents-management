import 'package:flutter/material.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/widget/shimmer/shimmer_primitives.dart';

export 'package:incidents_managment/core/widget/shimmer/shimmer_primitives.dart';
export 'package:incidents_managment/features/fleet/core/shimmer/fleet_shimmer_widgets.dart';

// =============================================================================
// LEVEL 2 — SCREEN-SPECIFIC SHIMMER COMPOSITIONS
// =============================================================================

// -----------------------------------------------------------------------------
// 1. OPERATIONS DASHBOARD SHIMMER (KPI Strip + Incident List + Details Panel)
// -----------------------------------------------------------------------------

class DashboardKpiStripShimmer extends StatelessWidget {
  final int cardCount;
  const DashboardKpiStripShimmer({super.key, this.cardCount = 5});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return SizedBox(
              height: 98,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cardCount,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, _) => const SizedBox(
                  width: 190,
                  child: ShimmerCard(padding: EdgeInsets.all(14)),
                ),
              ),
            );
          }
          return Row(
            children: List.generate(cardCount, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index < cardCount - 1 ? 12 : 0,
                  ),
                  child: const ShimmerCard(padding: EdgeInsets.all(14)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class IncidentListSectionShimmer extends StatelessWidget {
  final int itemCount;
  const IncidentListSectionShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ShimmerCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: AppRadius.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerBox(
                      width: 82,
                      height: 24,
                      borderRadius: AppRadius.pill,
                    ),
                    ShimmerLine(width: 64 + (index % 2) * 20.0, height: 12),
                  ],
                ),
                const SizedBox(height: 12),
                const ShimmerLine(width: 190, height: 15),
                const SizedBox(height: 8),
                const ShimmerText(lines: 2, lineHeight: 11, spacing: 6),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLine(width: 90, height: 11),
                    ShimmerLine(width: 75, height: 11),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class IncidentDetailsSectionShimmer extends StatelessWidget {
  const IncidentDetailsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLine(width: 240, height: 20),
                            SizedBox(height: 8),
                            ShimmerLine(width: 140, height: 13),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: const [
                          ShimmerBox(
                            width: 88,
                            height: 30,
                            borderRadius: AppRadius.pill,
                          ),
                          SizedBox(width: 8),
                          ShimmerBox(
                            width: 88,
                            height: 30,
                            borderRadius: AppRadius.pill,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      ShimmerInput(width: 170, height: 42, showLabel: true),
                      ShimmerInput(width: 170, height: 42, showLabel: true),
                      ShimmerInput(width: 170, height: 42, showLabel: true),
                      ShimmerInput(width: 170, height: 42, showLabel: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ShimmerCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLine(width: 150, height: 16),
                      ShimmerButton(width: 110, height: 34),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    4,
                    (_) => const ShimmerListItem(
                      hasLeadingAvatar: true,
                      hasStatusBadge: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreenShimmer extends StatelessWidget {
  const DashboardScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            return Column(
              children: [
                const DashboardKpiStripShimmer(),
                const SizedBox(height: 16),
                Expanded(
                  child: isDesktop
                      ? Row(
                          children: const [
                            SizedBox(
                              width: 400,
                              child: IncidentListSectionShimmer(itemCount: 5),
                            ),
                            SizedBox(width: 16),
                            Expanded(child: IncidentDetailsSectionShimmer()),
                          ],
                        )
                      : const IncidentListSectionShimmer(itemCount: 6),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. LIVE INCIDENTS MAP SCREEN SHIMMER
// -----------------------------------------------------------------------------

class IncidentsMapScreenShimmer extends StatelessWidget {
  const IncidentsMapScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          return Row(
            children: [
              if (isDesktop)
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      left: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerLine(width: 140, height: 18),
                      const SizedBox(height: 16),
                      const ShimmerInput(height: 44),
                      const SizedBox(height: 16),
                      ...List.generate(
                        5,
                        (_) => const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: ShimmerInput(height: 42, showLabel: true),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    Container(color: AppColors.shimmerSurface),
                    Positioned(
                      top: 16,
                      right: 16,
                      left: 16,
                      child: Row(
                        children: const [
                          ShimmerCard(
                            width: 240,
                            height: 54,
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ShimmerCircle(size: 28),
                                SizedBox(width: 10),
                                ShimmerLine(width: 140, height: 14),
                              ],
                            ),
                          ),
                          Spacer(),
                          ShimmerButton(width: 120, height: 42),
                        ],
                      ),
                    ),
                    const Center(
                      child: ShimmerCard(
                        width: 240,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShimmerCircle(size: 36),
                            SizedBox(height: 10),
                            ShimmerLine(width: 150, height: 13),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop)
                Container(
                  width: 340,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      right: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: const IncidentListSectionShimmer(itemCount: 5),
                ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. USER MANAGEMENT / EMPLOYEES SCREEN SHIMMER
// -----------------------------------------------------------------------------

class UserManagementScreenShimmer extends StatelessWidget {
  const UserManagementScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const NeverScrollableScrollPhysics(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 190, height: 22),
                        SizedBox(height: 8),
                        ShimmerLine(width: 250, height: 13),
                      ],
                    ),
                    if (!isMobile) const ShimmerButton(width: 140, height: 42),
                  ],
                ),
                const SizedBox(height: 24),
                // Stats cards
                if (isMobile)
                  Column(
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShimmerCard(height: 96),
                      ),
                    ),
                  )
                else
                  Row(
                    children: List.generate(3, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: index < 2 ? 16 : 0,
                          ),
                          child: const ShimmerCard(height: 104),
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: 24),
                // Filters panel
                ShimmerCard(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      ShimmerInput(width: 280, height: 42),
                      ShimmerInput(width: 170, height: 42),
                      ShimmerInput(width: 170, height: 42),
                      ShimmerInput(width: 170, height: 42),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Table or Mobile cards
                if (isMobile)
                  Column(
                    children: List.generate(
                      6,
                      (_) => const ShimmerListItem(
                        hasLeadingAvatar: true,
                        hasStatusBadge: true,
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: AppColors.surfaceSubtle,
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ShimmerLine(width: 100, height: 12),
                              ),
                              Expanded(
                                flex: 2,
                                child: ShimmerLine(width: 80, height: 12),
                              ),
                              Expanded(
                                flex: 2,
                                child: ShimmerLine(width: 80, height: 12),
                              ),
                              Expanded(
                                flex: 2,
                                child: ShimmerLine(width: 80, height: 12),
                              ),
                              SizedBox(
                                width: 90,
                                child: ShimmerLine(width: 60, height: 12),
                              ),
                            ],
                          ),
                        ),
                        ...List.generate(
                          7,
                          (_) => const ShimmerTableRow(columns: 4),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. EXECUTIVE REPORTS & ANALYTICS SHIMMER
// -----------------------------------------------------------------------------

class ReportsScreenShimmer extends StatelessWidget {
  const ReportsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;
            final kpiCols = AppBreakpoints.adaptiveGridColumns(
              constraints.maxWidth,
              mobile: 2,
              tablet: 3,
              desktop: 6,
              wideDesktop: 6,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 6 KPI cards grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kpiCols,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, _) => const ShimmerCard(
                    padding: EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 20),
                // Charts section
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _buildChartSkeletonCard(height: 320),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: _buildDonutSkeletonCard(height: 320),
                      ),
                    ],
                  )
                else ...[
                  _buildChartSkeletonCard(height: 260),
                  const SizedBox(height: 16),
                  _buildDonutSkeletonCard(height: 260),
                ],
                const SizedBox(height: 20),
                // Secondary breakdown cards
                if (isDesktop)
                  Row(
                    children: [
                      Expanded(child: _buildTableSkeletonCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTableSkeletonCard()),
                    ],
                  )
                else
                  _buildTableSkeletonCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartSkeletonCard({required double height}) {
    return ShimmerCard(
      height: height,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLine(width: 170, height: 16),
              ShimmerBox(width: 120, height: 30, borderRadius: AppRadius.sm),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (i) {
                final hFactor = 0.3 + ((i * 37) % 65) / 100.0;
                return FractionallySizedBox(
                  heightFactor: hFactor,
                  child: const ShimmerBox(
                    width: 22,
                    height: 200,
                    borderRadius: 6,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutSkeletonCard({required double height}) {
    return ShimmerCard(
      height: height,
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLine(width: 150, height: 16),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Center(child: ShimmerCircle(size: 140)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(width: 100, height: 12),
                      SizedBox(height: 12),
                      ShimmerLine(width: 85, height: 12),
                      SizedBox(height: 12),
                      ShimmerLine(width: 110, height: 12),
                      SizedBox(height: 12),
                      ShimmerLine(width: 75, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSkeletonCard() {
    return ShimmerCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLine(width: 160, height: 16),
          const SizedBox(height: 14),
          ...List.generate(
            4,
            (_) => const ShimmerListItem(
              hasLeadingAvatar: true,
              hasStatusBadge: true,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. INCIDENT TYPES & MISSIONS CATALOG SHIMMERS (WEB GRID & MOBILE LIST)
// -----------------------------------------------------------------------------

class CatalogGridScreenShimmer extends StatelessWidget {
  final int itemCount;
  final bool showCategoryChips;

  const CatalogGridScreenShimmer({
    super.key,
    this.itemCount = 8,
    this.showCategoryChips = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            final cols = AppBreakpoints.adaptiveGridColumns(
              constraints.maxWidth,
              mobile: 1,
              tablet: 2,
              desktop: 3,
              wideDesktop: 4,
            );
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCategoryChips) ...[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        5,
                        (i) => ShimmerBox(
                          width: 92 + (i % 2) * 24.0,
                          height: 36,
                          borderRadius: AppRadius.pill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (isMobile)
                    Column(
                      children: List.generate(
                        6,
                        (_) => const ShimmerListItem(
                          hasLeadingAvatar: true,
                          hasStatusBadge: true,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.1,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (_, _) => const ShimmerCard(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ShimmerAvatar(size: 42, isCircular: false),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ShimmerLine(width: 130, height: 15),
                                      SizedBox(height: 6),
                                      ShimmerLine(width: 85, height: 11),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ShimmerBox(
                                  width: 78,
                                  height: 24,
                                  borderRadius: AppRadius.pill,
                                ),
                                ShimmerBox(
                                  width: 32,
                                  height: 32,
                                  borderRadius: AppRadius.sm,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class IncidentTypesScreenShimmer extends StatelessWidget {
  const IncidentTypesScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogGridScreenShimmer(itemCount: 8, showCategoryChips: true);
  }
}

class MissionsScreenShimmer extends StatelessWidget {
  const MissionsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogGridScreenShimmer(itemCount: 9, showCategoryChips: true);
  }
}

// -----------------------------------------------------------------------------
// 6. LINK MISSIONS TO INCIDENT TYPES SHIMMER
// -----------------------------------------------------------------------------

class LinkMissionsScreenShimmer extends StatelessWidget {
  const LinkMissionsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogGridScreenShimmer(
      itemCount: 6,
      showCategoryChips: false,
    );
  }
}

// -----------------------------------------------------------------------------
// 7. FORM & REGISTRATION SCREEN SHIMMERS
// -----------------------------------------------------------------------------

class FormScreenShimmer extends StatelessWidget {
  final int fieldCount;
  const FormScreenShimmer({super.key, this.fieldCount = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ShimmerCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      ShimmerAvatar(size: 46, isCircular: false),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLine(width: 180, height: 18),
                            SizedBox(height: 6),
                            ShimmerLine(width: 240, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  ...List.generate(
                    fieldCount,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 18),
                      child: ShimmerInput(height: 48, showLabel: true),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShimmerButton(width: 110, height: 44),
                      SizedBox(width: 12),
                      ShimmerButton(width: 150, height: 44),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 8. MISSION ASSIGNMENT SCREEN SHIMMER
// -----------------------------------------------------------------------------

class MissionAssignUsersShimmer extends StatelessWidget {
  final int count;
  const MissionAssignUsersShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmerScope(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, _) => const ShimmerListItem(
          hasLeadingAvatar: true,
          hasStatusBadge: true,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 9. VALVES & GIS MAP SHIMMERS
// -----------------------------------------------------------------------------

class ValveMapScreenShimmer extends StatelessWidget {
  const ValveMapScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const IncidentsMapScreenShimmer();
  }
}

class AnalyticsOverviewShimmer extends StatelessWidget {
  const AnalyticsOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: ReportsScreenShimmer(),
    );
  }
}

class MobileIncidentDetailsShimmer extends StatelessWidget {
  const MobileIncidentDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: IncidentDetailsSectionShimmer()),
    );
  }
}
