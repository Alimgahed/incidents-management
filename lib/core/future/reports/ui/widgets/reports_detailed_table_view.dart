import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map/map_incident_details_modal.dart';

class ReportsDetailedTableView extends StatefulWidget {
  final List<CurrentIncidentModel> incidents;

  const ReportsDetailedTableView({super.key, required this.incidents});

  @override
  State<ReportsDetailedTableView> createState() =>
      _ReportsDetailedTableViewState();
}

class _ReportsDetailedTableViewState extends State<ReportsDetailedTableView> {
  int _rowsPerPage = 15;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final total = widget.incidents.length;
    final totalPages = (total / _rowsPerPage).ceil().clamp(1, 9999);
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, total);
    final pageItems = total > 0
        ? widget.incidents.sublist(startIndex, endIndex)
        : <CurrentIncidentModel>[];

    return Container(
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
          // Table Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rows Count / Range
                Text(
                  'عرض $startIndex إلى $endIndex من إجمالي $total أزمة',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    fontFamily: 'Cairo',
                  ),
                ),
                // Title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'الجدول التفصيلي لبيانات الأزمات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.table_chart_rounded,
                      color: Color(0xFF1B72E8),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: const [
                SizedBox(width: 70, child: _Th('الإجراء', align: TextAlign.center)),
                Expanded(flex: 2, child: _Th('تاريخ الإنشاء', align: TextAlign.left)),
                Expanded(flex: 2, child: _Th('الصور / المهام', align: TextAlign.center)),
                Expanded(flex: 2, child: _Th('الحالة', align: TextAlign.center)),
                Expanded(flex: 2, child: _Th('الخطورة', align: TextAlign.center)),
                Expanded(flex: 2, child: _Th('المسؤول')),
                Expanded(flex: 2, child: _Th('الفرع')),
                Expanded(flex: 3, child: _Th('النوع')),
                Expanded(flex: 4, child: _Th('الوصف')),
                SizedBox(width: 50, child: _Th('#', align: TextAlign.right)),
              ],
            ),
          ),

          // Table Content
          Expanded(
            child: pageItems.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد أزمات مطابقة للفلاتر المحددة',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: pageItems.length,
                    separatorBuilder: (_, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (context, index) {
                      final item = pageItems[index];
                      final dateStr = item.currentIncidentCreatedAt != null
                          ? dateFormat.format(item.currentIncidentCreatedAt!)
                          : '-';

                      final photosCount = item.photos?.length ?? 0;
                      final missionsCount =
                          item.currentIncidentWithMissions?.length ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // Action
                            SizedBox(
                              width: 70,
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 18,
                                    color: Color(0xFF1B72E8),
                                  ),
                                  tooltip: 'عرض تفاصيل الأزمة',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => MapIncidentDetailsModal(
                                        incident: item,
                                        onClose: () => Navigator.pop(context),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Date
                            Expanded(
                              flex: 2,
                              child: Text(
                                dateStr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            // Photos & Missions badges
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (photosCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      margin: const EdgeInsets.only(left: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.image_outlined,
                                            size: 12,
                                            color: Color(0xFF1B72E8),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$photosCount',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B72E8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (missionsCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3E8FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.assignment_outlined,
                                            size: 12,
                                            color: Color(0xFF8B5CF6),
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '$missionsCount',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8B5CF6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Status Badge
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: _buildStatusBadge(
                                  item.currentIncidentStatus,
                                ),
                              ),
                            ),
                            // Severity Badge
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: _buildSeverityBadge(
                                  item.currentIncidentSeverity,
                                ),
                              ),
                            ),
                            // Manager
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.managerName ?? item.username ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF475569),
                                  fontFamily: 'Cairo',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Branch
                            Expanded(
                              flex: 2,
                              child: Text(
                                (item.branchName != null &&
                                        item.branchName!.trim().isNotEmpty)
                                    ? item.branchName!.trim()
                                    : (item.branchId != null
                                        ? 'فرع #${item.branchId}'
                                        : 'غير محدد'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                  fontFamily: 'Cairo',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Type
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.currentIncidentTypeName ?? 'غير محدد',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                  fontFamily: 'Cairo',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Description
                            Expanded(
                              flex: 4,
                              child: Text(
                                item.currentIncidentDescription ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'Cairo',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // ID
                            SizedBox(
                              width: 50,
                              child: Text(
                                '#${item.currentIncidentId ?? ''}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B72E8),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Pagination Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Next / Prev buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _currentPage < totalPages - 1
                          ? () => setState(() => _currentPage++)
                          : null,
                    ),
                    Text(
                      'صفحة ${_currentPage + 1} من $totalPages',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                  ],
                ),

                // Rows Per Page Selector
                Row(
                  children: [
                    DropdownButton<int>(
                      value: _rowsPerPage,
                      underline: const SizedBox.shrink(),
                      items: const [10, 15, 25, 50].map((count) {
                        return DropdownMenuItem<int>(
                          value: count,
                          child: Text('$count سطر'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _rowsPerPage = val;
                            _currentPage = 0;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'عدد الأسطر:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(int? severity) {
    if (severity == null) {
      return const Text('-', style: TextStyle(fontFamily: 'Cairo', fontSize: 12));
    }
    final label = getSeverityArabic(severity);
    final color = getSeverityColor(severity);
    final bg = color.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int? status) {
    if (status == null) {
      return const Text('-', style: TextStyle(fontFamily: 'Cairo', fontSize: 12));
    }
    final label = getStatusArabic(status);
    final color = getStatusColor(status);
    final bg = color.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String label;
  final TextAlign align;

  const _Th(this.label, {this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        fontFamily: 'Cairo',
      ),
    );
  }
}
