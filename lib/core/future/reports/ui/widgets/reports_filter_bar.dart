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
          padding: const EdgeInsets.all(18),
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
              // Main Filters Row
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                alignment: WrapAlignment.start,
                children: [
                  // Search Bar
                  SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'بحث متقدم',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => cubit.updateSearchQuery(val),
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
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        cubit.updateSearchQuery('');
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
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

                  // 1. Manager Filter
                  _buildDropdownField(
                    label: 'المسؤول',
                    value: state.selectedManager ?? 'الكل',
                    items: ['الكل', ...state.availableManagers],
                    onChanged: (val) => cubit.setSelectedManager(val),
                  ),

                  // 2. Status Filter
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

                  // 3. Severity Filter
                  _buildDropdownField(
                    label: 'مستوى الخطورة',
                    value: _severityIdToName(state.selectedSeverity),
                    items: const ['الكل', 'حرجة', 'عالية', 'متوسطة', 'منخفضة'],
                    onChanged: (val) {
                      cubit.setSelectedSeverity(_severityNameToId(val));
                    },
                  ),

                  // 4. Type Filter
                  _buildDropdownField(
                    label: 'نوع الأزمة',
                    value: state.selectedType ?? 'الكل',
                    items: ['الكل', ...state.availableTypes],
                    onChanged: (val) => cubit.setSelectedType(val),
                  ),

                  // 5. Branch Filter (Strictly Real Data from Route/Branch API)
                  _buildDropdownField(
                    label: 'الفرع',
                    value: currentBranchSelection,
                    items: branchDropdownItems,
                    onChanged: (val) {
                      if (val == null || val == 'الكل') {
                        cubit.setSelectedBranchId(null, null);
                      } else {
                        // Find matching branchOption ID
                        final opt = state.branchOptions.firstWhere(
                          (o) => o.name == val,
                          orElse: () => BranchOption(id: null, name: val),
                        );
                        cubit.setSelectedBranchId(opt.id, opt.name);
                      }
                    },
                  ),

                  // 6. Start Date
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

                  // 7. End Date
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
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons Row & Extra Filters Toggle
              Row(
                children: [
                  // Primary Apply Button
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
                    icon: const Icon(Icons.filter_alt_rounded, size: 16),
                    label: const Text(
                      'تطبيق الفلاتر وتحديث',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B72E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Reset Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      cubit.resetFilters();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Color(0xFF475569),
                    ),
                    label: const Text(
                      'إعادة ضبط',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

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
                      _showExtraFilters ? 'إخفاء الفلاتر الإضافية' : 'فلاتر إضافية',
                      style: const TextStyle(
                        fontSize: 13,
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
                        horizontal: 16,
                        vertical: 12,
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

                  // Export Button with equal spacing in row
                  if (widget.onExport != null) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: widget.onExport,
                      icon: const Icon(
                        Icons.file_upload_outlined,
                        size: 16,
                        color: Color(0xFF1B72E8),
                      ),
                      label: const Text(
                        'تصدير',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B72E8),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Expandable Extra Filters Row
              if (_showExtraFilters) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'شروط توثيق متقدمة:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 16),

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
                      const SizedBox(width: 10),

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
                      const SizedBox(width: 10),

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
