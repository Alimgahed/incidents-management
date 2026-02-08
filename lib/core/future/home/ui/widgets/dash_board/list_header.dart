import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/theming/styling.dart';

class DashboardListHeader extends StatelessWidget {
  const DashboardListHeader({super.key, required this.count});

  final int count;

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

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------- HEADER ----------------
          Row(
            children: [
              Text('الأزمات النشطة', style: TextStyles.size16()),
              const Spacer(),
              Text('$count أزمة', style: TextStyles.size12()),
            ],
          ),

          const SizedBox(height: 12),

          /// ---------------- SEARCH ----------------
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

          /// ---------------- FILTER CHIPS ----------------
          BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final cubit = context.read<DashboardCubit>();
              return Wrap(
                spacing: 8,
                children: DashboardListHeader._filters
                    .map((filter) {
                      final isSelected = cubit.selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: FilterChip(
                          selected: isSelected,
                          selectedColor: appColor,
                          backgroundColor: fieldColor,
                          onSelected: (_) => cubit.updateFilter(filter),
                          label: Text(
                            filter,
                            style: TextStyles.size12(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
