import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:incidents_managment/core/theming/styling.dart';

class DashboardListHeader extends StatelessWidget {
  const DashboardListHeader({
    super.key,
    required this.count,
    this.compact = false,
  });

  final int count;
  final bool compact;

  static const List<String> _filters = [
    'الكل',
    'حرجة',
    'عالية',
    'متوسطة',
    'منخفضة',
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    if (compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'الأزمات النشطة',
                  style: TextStyles.size14(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: appColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyles.size11(
                      fontWeight: FontWeight.w700,
                      color: appColor,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 220,
                  height: 36,
                  child: TextField(
                    onChanged: cubit.updateSearchQuery,
                    style: TextStyles.size12(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'بحث…',
                      hintStyle: TextStyles.size11(
                        color: AppTheme.textTertiary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: appColor,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: inputFieldColor,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                final cubit = context.read<DashboardCubit>();
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = cubit.selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: FilterChip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          selected: isSelected,
                          selectedColor: appColor,
                          backgroundColor: const Color(0xFFF1F5F9),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: isSelected ? appColor : const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          onSelected: (_) => cubit.updateFilter(filter),
                          label: Text(
                            filter,
                            style: TextStyles.size11(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('الأزمات النشطة', style: TextStyles.size16()),
              const Spacer(),
              Text('$count أزمة', style: TextStyles.size12()),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: cubit.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'بحث في الأزمات...',
              hintStyle: TextStyles.size12(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: appColor),
              filled: true,
              fillColor: inputFieldColor,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final cubit = context.read<DashboardCubit>();
              return Wrap(
                spacing: 8,
                children: _filters
                    .map((filter) {
                      final isSelected = cubit.selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: FilterChip(
                          selected: isSelected,
                          selectedColor: appColor,
                          backgroundColor: const Color(0xFFF1F5F9),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: isSelected ? appColor : const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          onSelected: (_) => cubit.updateFilter(filter),
                          label: Text(
                            filter,
                            style: TextStyles.size12(
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}
