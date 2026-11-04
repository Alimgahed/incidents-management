import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_cubit.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

class ReportsFilterBar extends StatefulWidget {
  final VoidCallback? onExport;

  const ReportsFilterBar({super.key, this.onExport});

  @override
  State<ReportsFilterBar> createState() => _ReportsFilterBarState();
}

class _ReportsFilterBarState extends State<ReportsFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showExtraFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ReportsCubit>();

        // Build list of branch items from real authoritative data
        final branchDropdownItems = ['الكل', ...state.availableBranches];
        final currentBranchSelection = state.selectedBranch ?? 'الكل';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Compact Primary Filters + Actions Row
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.end,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      // Search Bar
                      SizedBox(
                        width: 210,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'بحث سريع',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 38,
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) =>
                                    cubit.updateSearchQuery(val),
                                decoration: InputDecoration(
                                  hintText: 'ابحث في التقارير...',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'Cairo',
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    size: 18,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 16,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            cubit.updateSearchQuery('');
                                          },
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1B72E8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Branch Filter (Strictly Real Data from Route/Branch API)
                      _buildDropdownField(
                        label: 'الفرع',
                        value: currentBranchSelection,
                        items: branchDropdownItems,
                        onChanged: (val) {
                          if (val == null || val == 'الكل') {
                            cubit.setSelectedBranchId(null, null);
                          } else {
                            final opt = state.branchOptions.firstWhere(
                              (o) => o.name == val,
                              orElse: () => BranchOption(id: null, name: val),
                            );
                            cubit.setSelectedBranchId(opt.id, opt.name);
                          }
                        },
                      ),

                      // Status Filter
                      _buildDropdownField(
                        label: 'حالة الأزمة',
                        value: _statusIdToName(state.selectedStatus),
                        items: const [
                          'الكل',
                          'تم التبليغ',
                          'تم الارسال',
                          'قيد التنفيذ',
                          'قيد الانتظار',
                          'قيد المراجعة',
                          'تم حلها',
                          'تم الرفض',
                        ],
                        onChanged: (val) {
                          cubit.setSelectedStatus(_statusNameToId(val));
                        },
                      ),

                      // Severity Filter
                      _buildDropdownField(
                        label: 'مستوى الخطورة',
                        value: _severityIdToName(state.selectedSeverity),
                        items: const [
                          'الكل',
                          'حرجة',
                          'عالية',
                          'متوسطة',
                          'منخفضة',
                        ],
                        onChanged: (val) {
                          cubit.setSelectedSeverity(_severityNameToId(val));
                        },
                      ),
                    ],
                  ),

                  // Action Buttons Group
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Extra Filters Toggle Button
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showExtraFilters = !_showExtraFilters;
                          });
                        },
                        icon: Icon(
                          _showExtraFilters
                              ? Icons.expand_less_rounded
                              : Icons.tune_rounded,
                          size: 16,
                          color: const Color(0xFF1B72E8),
                        ),
                        label: Text(
                          _showExtraFilters
                              ? 'طي الفلاتر المتقدمة'
                              : 'فلاتر متقدمة (التاريخ والنوع)',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B72E8),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _showExtraFilters
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          side: BorderSide(
                            color: _showExtraFilters
                                ? const Color(0xFF1B72E8)
                                : const Color(0xFFE2E8F0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Reset Button
                      OutlinedButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          cubit.resetFilters();
                        },
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                          size: 16,
                          color: Color(0xFF475569),
                        ),
                        label: const Text(
                          'إعادة ضبط',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Primary Refresh/Apply Button
                      ElevatedButton.icon(
                        onPressed: () {
                          cubit.refresh();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم تحديث وتطبيق الفلاتر على بيانات التقارير بنجاح',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                              backgroundColor: Color(0xFF1B72E8),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sync_rounded, size: 16),
                        label: const Text(
                          'تحديث',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B72E8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Expandable Advanced Filters Drawer (Manager, Type, Dates, Documentation Chips)
              if (_showExtraFilters) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      // 1. Manager Filter
                      _buildDropdownField(
                        label: 'المسؤول',
                        value: state.selectedManager ?? 'الكل',
                        items: ['الكل', ...state.availableManagers],
                        onChanged: (val) => cubit.setSelectedManager(val),
                      ),

                      // 2. Type Filter
                      _buildDropdownField(
                        label: 'نوع الأزمة',
                        value: state.selectedType ?? 'الكل',
                        items: ['الكل', ...state.availableTypes],
                        onChanged: (val) => cubit.setSelectedType(val),
                      ),

                      // 3. Start Date
                      _buildDateField(
                        context: context,
                        label: 'من تاريخ',
                        date: state.startDate,
                        onSelected: (date) {
                          cubit.setDateRange(date, state.endDate);
                        },
                        onCleared: () {
                          cubit.setDateRange(null, state.endDate);
                        },
                      ),

                      // 4. End Date
                      _buildDateField(
                        context: context,
                        label: 'إلى تاريخ',
                        date: state.endDate,
                        onSelected: (date) {
                          cubit.setDateRange(state.startDate, date);
                        },
                        onCleared: () {
                          cubit.setDateRange(state.startDate, null);
                        },
                      ),

                      // Filter 1: Has Photos
                      FilterChip(
                        selected: state.hasPhotos == true,
                        label: const Text('موثقة بصور مرفقة'),
                        avatar: Icon(
                          state.hasPhotos == true
                              ? Icons.check
                              : Icons.photo_camera_outlined,
                          size: 16,
                        ),
                        onSelected: (val) {
                          cubit.toggleHasPhotos(val ? true : null);
                        },
                      ),

                      // Filter 2: Has Missions
                      FilterChip(
                        selected: state.hasMissions == true,
                        label: const Text('تحتوي على مهام عمل'),
                        avatar: Icon(
                          state.hasMissions == true
                              ? Icons.check
                              : Icons.assignment_outlined,
                          size: 16,
                        ),
                        onSelected: (val) {
                          cubit.toggleHasMissions(val ? true : null);
                        },
                      ),

                      // Filter 3: Has Coordinates
                      FilterChip(
                        selected: state.hasCoordinates == true,
                        label: const Text('محددة بموقع جغرافي'),
                        avatar: Icon(
                          state.hasCoordinates == true
                              ? Icons.check
                              : Icons.location_on_outlined,
                          size: 16,
                        ),
                        onSelected: (val) {
                          cubit.toggleHasCoordinates(val ? true : null);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final cleanItems = items.toSet().toList();
    final actualValue = cleanItems.contains(value) ? value : cleanItems.first;

    return SizedBox(
      width: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: actualValue,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Cairo',
                ),
                items: cleanItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onSelected,
    VoidCallback? onCleared,
  }) {
    final f = DateFormat('yyyy/MM/dd');

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                onSelected(picked);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      date != null ? f.format(date) : 'اختر التاريخ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: date != null
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                        fontFamily: 'Cairo',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (date != null && onCleared != null)
                    GestureDetector(
                      onTap: onCleared,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusIdToName(int? id) {
    return switch (id) {
      1 => 'تم التبليغ',
      2 => 'تم الارسال',
      3 => 'قيد التنفيذ',
      4 => 'قيد الانتظار',
      5 => 'قيد المراجعة',
      6 => 'تم حلها',
      7 => 'تم الرفض',
      _ => 'الكل',
    };
  }

  int? _statusNameToId(String? name) {
    return switch (name) {
      'تم التبليغ' => 1,
      'تم الارسال' => 2,
      'قيد التنفيذ' => 3,
      'قيد الانتظار' => 4,
      'قيد المراجعة' => 5,
      'تم حلها' => 6,
      'تم الرفض' => 7,
      _ => null,
    };
  }

  String _severityIdToName(int? id) {
    return switch (id) {
      4 => 'حرجة',
      3 => 'عالية',
      2 => 'متوسطة',
      1 => 'منخفضة',
      _ => 'الكل',
    };
  }

  int? _severityNameToId(String? name) {
    return switch (name) {
      'حرجة' => 4,
      'عالية' => 3,
      'متوسطة' => 2,
      'منخفضة' => 1,
      _ => null,
    };
  }
}
