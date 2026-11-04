import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/dependcy_injection.dart';
import '../../../fleet/core/shimmer/fleet_shimmer_widgets.dart';
import '../../../fleet/core/theme/fleet_design_system.dart';
import '../../../fleet/domain/entities/fleet_filter_params.dart';
import '../../../fleet/domain/repositories/fleet_repository.dart';
import '../../../fleet/presentation/cubit/fleet_cubit.dart';
import '../../../fleet/presentation/cubit/fleet_state.dart';
import '../../../fleet/presentation/widgets/fleet_error_banner.dart';
import '../../../fleet/presentation/widgets/fleet_vehicle_details_modal.dart';
import '../../models/etit_vehicle_model.dart';
import 'etit_fleet_map_screen.dart';

class EtitVehiclesListScreen extends StatefulWidget {
  const EtitVehiclesListScreen({super.key});

  @override
  State<EtitVehiclesListScreen> createState() => _EtitVehiclesListScreenState();
}

class _EtitVehiclesListScreenState extends State<EtitVehiclesListScreen> {
  late final FleetCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt.isRegistered<FleetCubit>()
        ? getIt<FleetCubit>()
        : FleetCubit(repository: getIt<FleetRepository>());
    _cubit.initialize(enableLivePolling: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<FleetCubit, FleetState>(
          buildWhen: (prev, curr) =>
              prev.isInitialLoading != curr.isInitialLoading ||
              prev.status != curr.status ||
              prev.failure != curr.failure,
          builder: (context, state) {
            if (state.isInitialLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: FleetDashboardPageShimmer(),
              );
            }

            if (state.status == FleetStatus.error && !state.hasData) {
              return FleetErrorStateView(
                failure: state.failure!,
                onRetry: () => _cubit.refresh(forceFullRefresh: true),
              );
            }

            return RefreshIndicator(
              color: FleetColors.primaryNavy,
              onRefresh: () => _cubit.refresh(forceFullRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.failure != null && state.hasData)
                      FleetInlineErrorBanner(
                        failure: state.failure!,
                        onRetry: () => _cubit.refresh(forceFullRefresh: true),
                      ),

                    // 1. Top 4 KPI Summary Cards
                    const _FleetKpiCardsSection(),
                    const SizedBox(height: FleetSpacing.md),

                    // 2. Search Bar + Sync Timestamp + Action Buttons
                    _FleetSearchAndActionsBar(
                      searchController: _searchController,
                    ),
                    const SizedBox(height: 14),

                    // 3. Advanced Filter Dropdowns + Active Filter Chips
                    _FleetAdvancedFiltersBar(
                      onClearSearchText: () => _searchController.clear(),
                    ),
                    const SizedBox(height: FleetSpacing.md),

                    // 4. Data Table Card + Footer Pagination
                    const _FleetVehiclesTableSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 1. KPI SUMMARY CARDS SECTION (Scoped rebuild via BlocSelector)
// ═════════════════════════════════════════════════════════════════════════════
class _FleetKpiCardsSection extends StatelessWidget {
  const _FleetKpiCardsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetCubit, FleetState>(
      buildWhen: (prev, curr) =>
          prev.statistics != curr.statistics ||
          prev.filters.statusFilter != curr.filters.statusFilter,
      builder: (context, state) {
        final stats = state.statistics;
        final selectedStatus = state.filters.statusFilter;
        final cubit = context.read<FleetCubit>();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final cards = [
              _KpiSummaryCard(
                title: 'إجمالي المركبات',
                count: '${stats.totalCount}',
                subtitle: 'العدد الفعلي المسجل بالأسطول',
                bgColor: FleetColors.totalCardBg,
                borderColor: FleetColors.totalBorder,
                iconBgColor: FleetColors.totalIconBg,
                iconColor: FleetColors.totalIcon,
                textColor: FleetColors.textPrimary,
                icon: Icons.directions_car_filled_rounded,
                isSelected: selectedStatus == 'الكل',
                onTap: () => cubit.setStatusFilter('الكل'),
              ),
              _KpiSummaryCard(
                title: 'متحركة',
                count: '${stats.movingCount}',
                subtitle: stats.movingPercentageLabel,
                bgColor: FleetColors.movingCardBg,
                borderColor: FleetColors.movingBorder,
                iconBgColor: FleetColors.movingBadgeBg,
                iconColor: FleetColors.movingText,
                textColor: FleetColors.movingText,
                icon: Icons.play_arrow_rounded,
                isSelected: selectedStatus == 'متحركة',
                onTap: () => cubit.toggleStatusFilter('متحركة'),
              ),
              _KpiSummaryCard(
                title: 'متوقفة',
                count: '${stats.stoppedCount}',
                subtitle: stats.stoppedPercentageLabel,
                bgColor: FleetColors.stoppedCardBg,
                borderColor: FleetColors.stoppedBorder,
                iconBgColor: FleetColors.stoppedBadgeBg,
                iconColor: FleetColors.stoppedText,
                textColor: FleetColors.stoppedText,
                icon: Icons.pause_rounded,
                isSelected: selectedStatus == 'متوقفة',
                onTap: () => cubit.toggleStatusFilter('متوقفة'),
              ),
              _KpiSummaryCard(
                title: 'GPS غير متصل',
                count: '${stats.offlineCount}',
                subtitle: stats.offlinePercentageLabel,
                bgColor: FleetColors.offlineCardBg,
                borderColor: FleetColors.offlineBorder,
                iconBgColor: FleetColors.offlineBadgeBg,
                iconColor: FleetColors.offlineText,
                textColor: FleetColors.offlineText,
                icon: Icons.gps_off_rounded,
                isSelected:
                    selectedStatus == 'غير متصل' ||
                    selectedStatus == 'GPS غير متصل',
                onTap: () => cubit.toggleStatusFilter('GPS غير متصل'),
              ),
            ];

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
      },
    );
  }
}

class _KpiSummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final String? subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _KpiSummaryCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FleetRadius.lg),
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(FleetRadius.lg),
          border: Border.all(
            color: isSelected ? iconColor : borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FleetTextStyles.kpiTitle.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(count, style: FleetTextStyles.kpiCount),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FleetTextStyles.kpiSubtitle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 2. SEARCH BAR + SYNC TIMESTAMP + ACTION BUTTONS ROW
// ═════════════════════════════════════════════════════════════════════════════
class _FleetSearchAndActionsBar extends StatelessWidget {
  final TextEditingController searchController;

  const _FleetSearchAndActionsBar({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetCubit, FleetState>(
      buildWhen: (prev, curr) =>
          prev.filters.searchQuery != curr.filters.searchQuery ||
          prev.isRefreshing != curr.isRefreshing ||
          prev.lastSyncedAt != curr.lastSyncedAt,
      builder: (context, state) {
        final cubit = context.read<FleetCubit>();
        return Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Search Box (Debounced via FleetCubit)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 660),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: FleetColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(FleetRadius.md),
                  border: Border.all(color: FleetColors.borderMedium),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: cubit.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText:
                        'ابحث برقم اللوحة، كود السيارة، الفرع، الشاسيه أو IMEI...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: FleetColors.textHint,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: FleetColors.textMuted,
                    ),
                    suffixIcon: state.filters.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              searchController.clear();
                              cubit.clearSearch();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Last Synced Timestamp Badge
            if (state.lastSyncedAt != null)
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: FleetColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(FleetRadius.md),
                  border: Border.all(color: FleetColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: FleetColors.movingDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'آخر تحديث: ${FleetDateFormatter.formatSyncTime(state.lastSyncedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FleetColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: state.isRefreshing
                      ? null
                      : () => cubit.refresh(forceFullRefresh: true),
                  icon: state.isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: FleetColors.primaryNavy,
                          ),
                        )
                      : const Icon(
                          Icons.sync_rounded,
                          size: 18,
                          color: FleetColors.primaryNavy,
                        ),
                  label: const Text(
                    'تحديث البيانات',
                    style: TextStyle(
                      color: FleetColors.primaryNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: FleetColors.surfaceWhite,
                    side: const BorderSide(
                      color: FleetColors.primaryNavy,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FleetRadius.md),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EtitFleetMapScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'الخريطة المباشرة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FleetColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FleetRadius.md),
                    ),
                    elevation: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3. ADVANCED FILTERS BAR + ACTIVE FILTER CHIPS
// ═════════════════════════════════════════════════════════════════════════════
class _FleetAdvancedFiltersBar extends StatelessWidget {
  final VoidCallback onClearSearchText;

  const _FleetAdvancedFiltersBar({required this.onClearSearchText});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetCubit, FleetState>(
      buildWhen: (prev, curr) =>
          prev.filters != curr.filters || prev.statistics != curr.statistics,
      builder: (context, state) {
        final cubit = context.read<FleetCubit>();
        final filters = state.filters;
        final stats = state.statistics;
        final activeChips = filters.activeChips;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: FleetColors.surfaceWhite,
            borderRadius: BorderRadius.circular(FleetRadius.md),
            border: Border.all(color: FleetColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: FleetColors.primaryNavy,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'تصفية متقدمة',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FleetColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),

                  // Filter Dropdowns (100% dynamic from backend statistics)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FilterDropdownField(
                        label: 'الفرع',
                        icon: Icons.apartment_rounded,
                        value: filters.branchFilter,
                        items: stats.branches,
                        onChanged: (val) {
                          if (val != null) cubit.setBranchFilter(val);
                        },
                      ),
                      _FilterDropdownField(
                        label: 'حالة المركبة',
                        icon: Icons.analytics_outlined,
                        value: filters.statusFilter,
                        items: const [
                          'الكل',
                          'متحركة',
                          'متوقفة',
                          'GPS غير متصل',
                        ],
                        onChanged: (val) {
                          if (val != null) cubit.setStatusFilter(val);
                        },
                      ),
                      _FilterDropdownField(
                        label: 'نوع السيارة',
                        icon: Icons.directions_car_outlined,
                        value: filters.vehicleTypeFilter,
                        items: stats.vehicleTypes,
                        onChanged: (val) {
                          if (val != null) cubit.setVehicleTypeFilter(val);
                        },
                      ),
                      _FilterDropdownField(
                        label: 'جهاز التتبع',
                        icon: Icons.router_outlined,
                        value: filters.vendorFilter,
                        items: stats.vendors,
                        onChanged: (val) {
                          if (val != null) cubit.setVendorFilter(val);
                        },
                      ),
                      _FilterDropdownField(
                        label: 'الشريحة',
                        icon: Icons.sim_card_outlined,
                        value: filters.providerFilter,
                        items: stats.providers,
                        onChanged: (val) {
                          if (val != null) cubit.setProviderFilter(val);
                        },
                      ),
                    ],
                  ),

                  // Clear All Filters Button
                  OutlinedButton.icon(
                    onPressed: filters.hasActiveFilters
                        ? () {
                            onClearSearchText();
                            cubit.clearAllFilters();
                          }
                        : null,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text(
                      'مسح الفلاتر',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FleetColors.textSecondary,
                      backgroundColor: FleetColors.surfaceSubtle,
                      side: const BorderSide(color: FleetColors.borderMedium),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FleetRadius.md),
                      ),
                    ),
                  ),
                ],
              ),

              // Active Filter Chips Strip
              if (activeChips.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: FleetColors.borderLight),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'الفلاتر النشطة:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: FleetColors.textMuted,
                      ),
                    ),
                    ...activeChips.map(
                      (chip) => InputChip(
                        label: Text(
                          chip.label,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: FleetColors.primaryNavy,
                          ),
                        ),
                        backgroundColor: FleetColors.selectedRowBg,
                        deleteIconColor: FleetColors.primaryNavy,
                        side: const BorderSide(color: FleetColors.totalBorder),
                        visualDensity: VisualDensity.compact,
                        onDeleted: () {
                          if (chip.key == 'search') onClearSearchText();
                          cubit.removeFilterChip(chip.key);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterDropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : 'الكل';
    final isFiltered = safeValue != 'الكل';

    return Container(
      constraints: const BoxConstraints(minWidth: 165, maxWidth: 215),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isFiltered ? FleetColors.selectedRowBg : FleetColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(FleetRadius.md),
        border: Border.all(
          color: isFiltered ? FleetColors.accentBlue : FleetColors.borderMedium,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: FleetColors.primaryNavy),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: FleetColors.textMuted,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: safeValue,
                    isDense: true,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: FleetColors.textPrimary,
                    ),
                    items: items
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 4. VEHICLES DATA TABLE + PAGINATION FOOTER
// ═════════════════════════════════════════════════════════════════════════════
class _FleetVehiclesTableSection extends StatelessWidget {
  const _FleetVehiclesTableSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetCubit, FleetState>(
      buildWhen: (prev, curr) =>
          prev.paginatedVehicles != curr.paginatedVehicles ||
          prev.filteredVehicles.length != curr.filteredVehicles.length ||
          prev.filters.currentPage != curr.filters.currentPage ||
          prev.filters.pageSize != curr.filters.pageSize ||
          prev.filters.sortField != curr.filters.sortField ||
          prev.filters.sortAscending != curr.filters.sortAscending,
      builder: (context, state) {
        final pageItems = state.paginatedVehicles;
        final totalFiltered = state.filteredVehicles.length;
        final startIdx = state.pageStartIndex;
        final endIdx = state.pageEndIndex;

        return Container(
          decoration: BoxDecoration(
            color: FleetColors.surfaceWhite,
            borderRadius: BorderRadius.circular(FleetRadius.lg),
            border: Border.all(color: FleetColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth < 980
                      ? 980.0
                      : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTableHeader(context, state.filters),
                          if (pageItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: FleetColors.textHint,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'لا توجد مركبات مطابقة لمعايير البحث أو الفلترة الحالية',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: FleetColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      onPressed: () => context
                                          .read<FleetCubit>()
                                          .clearAllFilters(),
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('إعادة ضبط الفلاتر'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pageItems.length,
                              separatorBuilder: (_, _) => const Divider(
                                height: 1,
                                color: FleetColors.borderLight,
                              ),
                              itemBuilder: (context, i) => _FleetTableDataRow(
                                rowNumber: startIdx + i + 1,
                                vehicle: pageItems[i],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: FleetColors.borderLight),
              _buildPaginationFooter(
                context: context,
                state: state,
                startIdx: startIdx,
                endIdx: endIdx,
                totalFiltered: totalFiltered,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(BuildContext context, FleetFilterParams filters) {
    final cubit = context.read<FleetCubit>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: FleetColors.tableHeaderBg,
        border: Border(bottom: BorderSide(color: FleetColors.borderMedium)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 36,
            child: Text('#', style: FleetTextStyles.tableHeader),
          ),
          Expanded(
            flex: 3,
            child: _SortableHeaderCell(
              title: 'المركبة / رقم اللوحة',
              field: FleetSortField.plateNumber,
              currentField: filters.sortField,
              ascending: filters.sortAscending,
              onTap: () => cubit.toggleSort(FleetSortField.plateNumber),
            ),
          ),
          Expanded(
            flex: 2,
            child: _SortableHeaderCell(
              title: 'الفرع',
              icon: Icons.apartment_rounded,
              field: FleetSortField.branch,
              currentField: filters.sortField,
              ascending: filters.sortAscending,
              onTap: () => cubit.toggleSort(FleetSortField.branch),
            ),
          ),
          Expanded(
            flex: 2,
            child: _SortableHeaderCell(
              title: 'النوع',
              icon: Icons.directions_car_outlined,
              field: FleetSortField.vehicleType,
              currentField: filters.sortField,
              ascending: filters.sortAscending,
              onTap: () => cubit.toggleSort(FleetSortField.vehicleType),
            ),
          ),
          const Expanded(
            flex: 3,
            child: _StaticHeaderCell(
              title: 'جهاز التتبع (IMEI)',
              icon: Icons.satellite_alt_outlined,
            ),
          ),
          Expanded(
            flex: 2,
            child: _SortableHeaderCell(
              title: 'آخر تحديث',
              icon: Icons.calendar_today_outlined,
              field: FleetSortField.lastUpdate,
              currentField: filters.sortField,
              ascending: filters.sortAscending,
              onTap: () => cubit.toggleSort(FleetSortField.lastUpdate),
            ),
          ),
          Expanded(
            flex: 2,
            child: _SortableHeaderCell(
              title: 'الحالة',
              icon: Icons.monitor_heart_outlined,
              field: FleetSortField.speed,
              currentField: filters.sortField,
              ascending: filters.sortAscending,
              onTap: () => cubit.toggleSort(FleetSortField.speed),
            ),
          ),
          const SizedBox(
            width: 150,
            child: _StaticHeaderCell(
              title: 'الموقع والتفاصيل',
              icon: Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter({
    required BuildContext context,
    required FleetState state,
    required int startIdx,
    required int endIdx,
    required int totalFiltered,
  }) {
    final cubit = context.read<FleetCubit>();
    final safePage = state.safeCurrentPage;
    final totalPages = state.totalPages;
    final displayStart = totalFiltered == 0 ? 0 : startIdx + 1;

    final pageNumbers = <int>[];
    final windowStart = (safePage - 2).clamp(1, totalPages);
    final windowEnd = (windowStart + 4).clamp(1, totalPages);
    for (int p = windowStart; p <= windowEnd; p++) {
      pageNumbers.add(p);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: FleetColors.surfaceSubtle,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Text(
            'عرض $displayStart - $endIdx من $totalFiltered مركبة',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: FleetColors.textSecondary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaginationIconBtn(
                icon: Icons.chevron_left_rounded,
                enabled: safePage > 1,
                onTap: () => cubit.setPage(safePage - 1),
              ),
              const SizedBox(width: 6),
              for (final p in pageNumbers) ...[
                _PaginationNumberBtn(
                  pageNumber: p,
                  isActive: p == safePage,
                  onTap: () => cubit.setPage(p),
                ),
                const SizedBox(width: 6),
              ],
              _PaginationIconBtn(
                icon: Icons.chevron_right_rounded,
                enabled: safePage < totalPages,
                onTap: () => cubit.setPage(safePage + 1),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'عدد العناصر في الصفحة',
                style: TextStyle(
                  fontSize: 12,
                  color: FleetColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: FleetColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(FleetRadius.sm),
                  border: Border.all(color: FleetColors.borderMedium),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: state.filters.pageSize,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: FleetColors.textPrimary,
                    ),
                    items: const [5, 10, 20, 50, 100]
                        .map(
                          (s) => DropdownMenuItem<int>(
                            value: s,
                            child: Text('$s'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) cubit.setPageSize(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaticHeaderCell extends StatelessWidget {
  final String title;
  final IconData? icon;

  const _StaticHeaderCell({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: FleetColors.primaryNavy),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: FleetTextStyles.tableHeader,
          ),
        ),
      ],
    );
  }
}

class _SortableHeaderCell extends StatelessWidget {
  final String title;
  final IconData? icon;
  final FleetSortField field;
  final FleetSortField currentField;
  final bool ascending;
  final VoidCallback onTap;

  const _SortableHeaderCell({
    required this.title,
    this.icon,
    required this.field,
    required this.currentField,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSorted = field == currentField;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: FleetColors.primaryNavy),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: FleetTextStyles.tableHeader,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              !isSorted
                  ? Icons.unfold_more_rounded
                  : (ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded),
              size: 14,
              color: isSorted ? FleetColors.accentBlue : FleetColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _FleetTableDataRow extends StatelessWidget {
  final int rowNumber;
  final EtitVehicleModel vehicle;

  const _FleetTableDataRow({
    required this.rowNumber,
    required this.vehicle,
  });

  IconData _vehicleTypeIcon(String? type) {
    final t = (type ?? '').toLowerCase();
    if (t.contains('trailer')) return Icons.rv_hookup_rounded;
    if (t.contains('truck')) return Icons.local_shipping_rounded;
    if (t.contains('pickup')) return Icons.local_shipping_outlined;
    return Icons.directions_car_filled_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    final trackerBrand = (v.vendorName ?? '').trim().isNotEmpty
        ? v.vendorName!.trim()
        : ((v.providerName ?? '').trim().isNotEmpty
              ? v.providerName!.trim()
              : 'غير محدد');
    final imeiText = (v.deviceCode ?? '').trim().isNotEmpty
        ? 'IMEI: ${v.deviceCode}'
        : 'IMEI: غير مسجل';

    return InkWell(
      onTap: () => showFleetVehicleDetailsModal(context, v),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 1. Row index
            SizedBox(
              width: 36,
              child: Text(
                '$rowNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: FleetColors.textSecondary,
                ),
              ),
            ),

            // 2. المركبة / رقم اللوحة
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 38,
                    decoration: BoxDecoration(
                      color: FleetColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(FleetRadius.sm),
                      border: Border.all(color: FleetColors.borderLight),
                    ),
                    child: Icon(
                      _vehicleTypeIcon(v.vehicleType),
                      color: FleetColors.primaryNavy,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FleetColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'كود: ${v.code}',
                            style: FleetTextStyles.codeBadge,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          v.plateNumber.isNotEmpty ? v.plateNumber : v.code,
                          style: FleetTextStyles.plateTitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. الفرع
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: FleetColors.primaryNavy,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      (v.allocation ?? '').trim().isNotEmpty
                          ? v.allocation!
                          : 'غير محدد',
                      style: FleetTextStyles.cellPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // 4. النوع
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    _vehicleTypeIcon(v.vehicleType),
                    size: 16,
                    color: FleetColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (v.vehicleType ?? '').trim().isNotEmpty
                              ? v.vehicleType!
                              : '-',
                          style: FleetTextStyles.cellPrimary,
                        ),
                        Text(
                          v.arabicVehicleType,
                          style: FleetTextStyles.cellSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 5. جهاز التتبع (IMEI)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_rounded,
                        size: 14,
                        color: FleetColors.accentBlue,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          trackerBrand,
                          overflow: TextOverflow.ellipsis,
                          style: FleetTextStyles.cellPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(imeiText, style: FleetTextStyles.cellSecondary),
                ],
              ),
            ),

            // 6. آخر تحديث
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: FleetColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      FleetDateFormatter.formatArabicTimestamp(v.lastUpdate),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FleetColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 7. الحالة
            Expanded(
              flex: 2,
              child: _VehicleStatusCell(vehicle: v),
            ),

            // 8. الموقع والتفاصيل
            SizedBox(
              width: 150,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showVehicleOnMap(context, v),
                      icon: const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: FleetColors.primaryNavy,
                      ),
                      label: const Text(
                        'الخريطة',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: FleetColors.primaryNavy,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        side: const BorderSide(color: FleetColors.borderMedium),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(FleetRadius.sm),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'كل بيانات المركبة',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: FleetColors.primaryNavy,
                    ),
                    onPressed: () => showFleetVehicleDetailsModal(context, v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleOnMap(BuildContext context, EtitVehicleModel vehicle) {
    if (!vehicle.hasValidLocation) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EtitFleetMapScreen(targetVehicle: vehicle),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FleetRadius.xl),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 720,
          height: 520,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: FleetColors.primaryNavy,
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'موقع المركبة: ${vehicle.plateNumber} (كود: ${vehicle.code}) - ${vehicle.allocation ?? ""}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EtitFleetMapScreen(targetVehicle: vehicle),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.open_in_full_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'فتح بالخريطة الكاملة',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      vehicle.latitude!,
                      vehicle.longitude!,
                    ),
                    initialZoom: 15.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'incidents_managment',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(vehicle.latitude!, vehicle.longitude!),
                          width: 140,
                          height: 75,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: FleetColors.textPrimary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  vehicle.plateNumber.isNotEmpty
                                      ? vehicle.plateNumber
                                      : vehicle.code,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: vehicle.isMoving
                                      ? FleetColors.movingDot
                                      : FleetColors.accentBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_shipping,
                                  color: Colors.white,
                                  size: 20,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: FleetColors.surfaceSubtle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإحداثيات: ${vehicle.latitude!.toStringAsFixed(5)}, ${vehicle.longitude!.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'السرعة الحالية: ${vehicle.speed?.toStringAsFixed(1) ?? "0"} كم/س',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: vehicle.isMoving
                            ? FleetColors.movingDot
                            : FleetColors.textSecondary,
                      ),
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

class _VehicleStatusCell extends StatelessWidget {
  final EtitVehicleModel vehicle;

  const _VehicleStatusCell({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    late final String badgeText;
    late final String subText;
    late final Color badgeBg;
    late final Color badgeColor;
    late final Color dotColor;

    if (vehicle.isMoving) {
      badgeText = 'متحركة';
      subText = 'السرعة: ${vehicle.speed?.toStringAsFixed(0) ?? '0'} كم/س';
      badgeBg = FleetColors.movingBadgeBg;
      badgeColor = FleetColors.movingText;
      dotColor = FleetColors.movingDot;
    } else if (vehicle.isStopped) {
      badgeText = 'متوقفة';
      subText = FleetDateFormatter.formatRelativeDuration(vehicle.lastUpdate);
      badgeBg = FleetColors.stoppedBadgeBg;
      badgeColor = FleetColors.stoppedText;
      dotColor = FleetColors.stoppedDot;
    } else {
      badgeText = 'GPS غير متصل';
      subText = FleetDateFormatter.formatRelativeDuration(vehicle.lastUpdate);
      badgeBg = FleetColors.offlineBadgeBg;
      badgeColor = FleetColors.offlineText;
      dotColor = FleetColors.offlineDot;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: vehicle.isMoving
                ? FleetColors.movingText
                : FleetColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _PaginationIconBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationIconBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(FleetRadius.sm),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? FleetColors.surfaceWhite : FleetColors.surfaceMuted,
          borderRadius: BorderRadius.circular(FleetRadius.sm),
          border: Border.all(color: FleetColors.borderMedium),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? FleetColors.textSecondary : FleetColors.textHint,
        ),
      ),
    );
  }
}

class _PaginationNumberBtn extends StatelessWidget {
  final int pageNumber;
  final bool isActive;
  final VoidCallback onTap;

  const _PaginationNumberBtn({
    required this.pageNumber,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FleetRadius.sm),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? FleetColors.accentBlue : FleetColors.surfaceWhite,
          borderRadius: BorderRadius.circular(FleetRadius.sm),
          border: Border.all(
            color: isActive ? FleetColors.accentBlue : FleetColors.borderMedium,
          ),
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : FleetColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
