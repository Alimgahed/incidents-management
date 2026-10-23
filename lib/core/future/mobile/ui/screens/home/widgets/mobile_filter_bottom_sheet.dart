import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';

class MobileFilterBottomSheet extends StatefulWidget {
  final List<CurrentIncidentModel> incidents;

  const MobileFilterBottomSheet({super.key, required this.incidents});

  @override
  State<MobileFilterBottomSheet> createState() =>
      _MobileFilterBottomSheetState();
}

class _MobileFilterBottomSheetState extends State<MobileFilterBottomSheet> {
  int? _tempStatus;
  int? _tempSeverity;
  int? _tempBranch;
  int? _tempIncidentType;
  bool? _tempHasPhotos;

  late final List<Map<String, dynamic>> _availableBranches;
  late final List<Map<String, dynamic>> _availableTypes;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DashboardCubit>();
    _tempStatus = cubit.selectedStatus;
    _tempSeverity = cubit.selectedSeverity;
    _tempBranch = cubit.selectedBranchId;
    _tempIncidentType = cubit.selectedIncidentTypeId;
    _tempHasPhotos = cubit.selectedHasPhotos;

    _availableBranches = _computeAvailableBranches();
    _availableTypes = _computeAvailableIncidentTypes();
  }

  List<Map<String, dynamic>> _computeAvailableBranches() {
    final branchMap = <int, String>{};
    for (var i = 0; i < widget.incidents.length; i++) {
      final inc = widget.incidents[i];
      if (inc.branchId != null &&
          inc.branchName != null &&
          inc.branchName!.trim().isNotEmpty) {
        branchMap[inc.branchId!] = inc.branchName!.trim();
      }
    }

    final sortedEntries = branchMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sortedEntries.map((e) => {'id': e.key, 'label': e.value}).toList();
  }

  List<Map<String, dynamic>> _computeAvailableIncidentTypes() {
    final typeMap = <int, String>{};
    for (var i = 0; i < widget.incidents.length; i++) {
      final inc = widget.incidents[i];
      if (inc.currentIncidentTypeId != null &&
          inc.currentIncidentTypeName != null &&
          inc.currentIncidentTypeName!.trim().isNotEmpty) {
        typeMap[inc.currentIncidentTypeId!] =
            inc.currentIncidentTypeName!.trim();
      }
    }

    final sortedEntries = typeMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sortedEntries.map((e) => {'id': e.key, 'label': e.value}).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;

    final hasAnyFilterSelection = _tempStatus != null ||
        _tempSeverity != null ||
        _tempBranch != null ||
        _tempIncidentType != null ||
        _tempHasPhotos != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + bottomPadding + viewInsetsBottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: appColor, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'تصفية البلاغات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const Spacer(),
                if (hasAnyFilterSelection || cubit.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _tempStatus = null;
                        _tempSeverity = null;
                        _tempBranch = null;
                        _tempIncidentType = null;
                        _tempHasPhotos = null;
                      });
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: Color(0xFFDC2626),
                    ),
                    label: const Text(
                      'إعادة ضبط',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: secondaryTextColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

            // 1. Status Filter Section
            _buildFilterSection(
              title: 'حالة البلاغ',
              icon: Icons.sync_alt_rounded,
              isSelected: _tempStatus != null,
              onClear: () => setState(() => _tempStatus = null),
              child: _buildStatusFilter(),
            ),

            const SizedBox(height: 20),

            // 2. Severity Filter Section
            _buildFilterSection(
              title: 'درجة الخطورة',
              icon: Icons.priority_high_rounded,
              isSelected: _tempSeverity != null,
              onClear: () => setState(() => _tempSeverity = null),
              child: _buildSeverityFilter(),
            ),

            const SizedBox(height: 20),

            // 3. Branch Filter Section
            _buildFilterSection(
              title: 'الفرع أو المنطقة',
              icon: Icons.location_city_rounded,
              isSelected: _tempBranch != null,
              onClear: () => setState(() => _tempBranch = null),
              child: _buildBranchFilter(),
            ),

            const SizedBox(height: 20),

            // 4. Incident Type Filter Section
            _buildFilterSection(
              title: 'نوع الأزمة',
              icon: Icons.category_rounded,
              isSelected: _tempIncidentType != null,
              onClear: () => setState(() => _tempIncidentType = null),
              child: _buildIncidentTypeFilter(),
            ),

            const SizedBox(height: 20),

            // 5. Photos / Attachments Filter Section
            _buildFilterSection(
              title: 'المرفقات والصور',
              icon: Icons.photo_library_rounded,
              isSelected: _tempHasPhotos != null,
              onClear: () => setState(() => _tempHasPhotos = null),
              child: _buildPhotosFilter(),
            ),

            const SizedBox(height: 26),

            // Actions: Apply & Clear Buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.applyFilters(
                        status: _tempStatus,
                        severity: _tempSeverity,
                        branchId: _tempBranch,
                        incidentTypeId: _tempIncidentType,
                        hasPhotos: _tempHasPhotos,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تطبيق الفلتر',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (hasAnyFilterSelection) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _tempStatus = null;
                          _tempSeverity = null;
                          _tempBranch = null;
                          _tempIncidentType = null;
                          _tempHasPhotos = null;
                        });
                        cubit.clearAllFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'مسح الكل',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onClear,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: appColor, size: 17),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              GestureDetector(
                onTap: onClear,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'مسح',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildStatusFilter() {
    const statuses = [
      {'id': 1, 'label': 'تم التبليغ'},
      {'id': 2, 'label': 'تم الارسال'},
      {'id': 3, 'label': 'قيد التنفيذ'},
      {'id': 4, 'label': 'قيد الانتظار'},
      {'id': 5, 'label': 'قيد المراجعة'},
      {'id': 6, 'label': 'تم حلها'},
      {'id': 7, 'label': 'تم الرفض'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final id = status['id'] as int;
        final label = status['label'] as String;
        final isSelected = _tempStatus == id;
        final color = getStatusColor(id);

        return ChoiceChip(
          selected: isSelected,
          label: Text(label),
          labelStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withValues(alpha: 0.08),
          selectedColor: color,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? color : color.withValues(alpha: 0.25),
            ),
          ),
          onSelected: (selected) {
            setState(() {
              _tempStatus = selected ? id : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSeverityFilter() {
    const severities = [
      {'id': 1, 'label': 'منخفضة'},
      {'id': 2, 'label': 'متوسطة'},
      {'id': 3, 'label': 'عالية'},
      {'id': 4, 'label': 'حرجة'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: severities.map((severity) {
        final id = severity['id'] as int;
        final label = severity['label'] as String;
        final isSelected = _tempSeverity == id;
        final color = getSeverityColor(id);

        return ChoiceChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getSeverityIcon(id),
                size: 14,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 5),
              Text(label),
            ],
          ),
          labelStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withValues(alpha: 0.08),
          selectedColor: color,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? color : color.withValues(alpha: 0.25),
            ),
          ),
          onSelected: (selected) {
            setState(() {
              _tempSeverity = selected ? id : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildBranchFilter() {
    if (_availableBranches.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'لا توجد فروع مسجلة بالبيانات الحالية',
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _tempBranch != null ? appColor : const Color(0xFFE2E8F0),
          width: _tempBranch != null ? 1.5 : 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _tempBranch,
          hint: const Text(
            'اختر الفرع (الكل)',
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: secondaryTextColor),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'جميع الفروع',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
            ..._availableBranches.map((branch) {
              final id = branch['id'] as int;
              final label = branch['label'] as String;
              return DropdownMenuItem<int?>(
                value: id,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city_rounded,
                      size: 16,
                      color: _tempBranch == id ? appColor : secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _tempBranch == id
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _tempBranch == id ? appColor : primaryTextColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _tempBranch = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildIncidentTypeFilter() {
    if (_availableTypes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'لا توجد أنواع أزمات مسجلة بالبيانات الحالية',
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _tempIncidentType != null ? appColor : const Color(0xFFE2E8F0),
          width: _tempIncidentType != null ? 1.5 : 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _tempIncidentType,
          hint: const Text(
            'اختر نوع الأزمة (الكل)',
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: secondaryTextColor),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'جميع أنواع الأزمات',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
            ..._availableTypes.map((type) {
              final id = type['id'] as int;
              final label = type['label'] as String;
              return DropdownMenuItem<int?>(
                value: id,
                child: Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 16,
                      color: _tempIncidentType == id
                          ? appColor
                          : secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _tempIncidentType == id
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _tempIncidentType == id
                              ? appColor
                              : primaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _tempIncidentType = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPhotosFilter() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            selected: _tempHasPhotos == true,
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_rounded, size: 14),
                SizedBox(width: 6),
                Text('يحتوي على صور'),
              ],
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: _tempHasPhotos == true
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: _tempHasPhotos == true
                  ? Colors.white
                  : const Color(0xFF0284C7),
            ),
            backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.08),
            selectedColor: const Color(0xFF0284C7),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _tempHasPhotos == true
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF0284C7).withValues(alpha: 0.25),
              ),
            ),
            onSelected: (selected) {
              setState(() {
                _tempHasPhotos = selected ? true : null;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            selected: _tempHasPhotos == false,
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_photography_rounded, size: 14),
                SizedBox(width: 6),
                Text('بدون صور'),
              ],
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: _tempHasPhotos == false
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: _tempHasPhotos == false
                  ? Colors.white
                  : const Color(0xFF64748B),
            ),
            backgroundColor: const Color(0xFF64748B).withValues(alpha: 0.08),
            selectedColor: const Color(0xFF64748B),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _tempHasPhotos == false
                    ? const Color(0xFF64748B)
                    : const Color(0xFF64748B).withValues(alpha: 0.25),
              ),
            ),
            onSelected: (selected) {
              setState(() {
                _tempHasPhotos = selected ? false : null;
              });
            },
          ),
        ),
      ],
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning_amber_rounded;
      case 2:
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }
}
