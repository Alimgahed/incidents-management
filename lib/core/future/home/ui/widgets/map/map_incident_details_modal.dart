import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:intl/intl.dart';

class MapIncidentDetailsModal extends StatefulWidget {
  final CurrentIncidentModel incident;
  final VoidCallback onClose;

  const MapIncidentDetailsModal({
    super.key,
    required this.incident,
    required this.onClose,
  });

  @override
  State<MapIncidentDetailsModal> createState() => _MapIncidentDetailsModalState();
}

class _MapIncidentDetailsModalState extends State<MapIncidentDetailsModal> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final onClose = widget.onClose;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).height * 0.9,
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.analytics_outlined, color: Color(0xFF1B4F8A), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'تفاصيل الأزمة #${incident.currentIncidentId ?? ""}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: onClose,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar (Tabs simulation)
                  Container(
                    width: 200,
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildTab(0, 'البيانات العامة', Icons.info_outline),
                        _buildTab(1, 'الموقع الجغرافي', Icons.location_on_outlined),
                        _buildTab(2, 'المهام', Icons.assignment_outlined),
                        _buildTab(3, 'الصور والملفات', Icons.photo_library_outlined),
                        _buildTab(4, 'سجل التحديثات', Icons.history),
                      ],
                    ),
                  ),
                  // Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildSelectedContent(),
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

  Widget _buildTab(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: const Color(0xFFBFDBFE))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF1B4F8A) : const Color(0xFF64748B),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF1B4F8A) : const Color(0xFF64748B),
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedTabIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralData(),
            const SizedBox(height: 32),
            _buildDescription(),
          ],
        );
      case 1:
        return _buildLocationOnly();
      case 2:
        return _buildMissionsOnly();
      case 3:
        return _buildPlaceholder('لا توجد صور وملفات متاحة لهذه الأزمة', Icons.photo_library_outlined);
      case 4:
        return _buildPlaceholder('سجل التحديثات غير متوفر حالياً', Icons.history);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlaceholder(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(icon, size: 64, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOnly() {
    final incident = widget.incident;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الموقع الجغرافي',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCoordinateItem('خط العرض (Latitude)', incident.currentIncidentXAxis?.toString() ?? 'غير متوفر'),
                  _buildCoordinateItem('خط الطول (Longitude)', incident.currentIncidentYAxis?.toString() ?? 'غير متوفر'),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 380,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: (incident.currentIncidentXAxis != null && incident.currentIncidentYAxis != null)
                      ? FlutterMap(
                          key: ValueKey('modal_map_${incident.currentIncidentId}_${incident.currentIncidentXAxis}_${incident.currentIncidentYAxis}'),
                          options: MapOptions(
                            initialCenter: LatLng(
                              incident.currentIncidentXAxis!,
                              incident.currentIncidentYAxis!,
                            ),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.crisis_management',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    incident.currentIncidentXAxis!,
                                    incident.currentIncidentYAxis!,
                                  ),
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 44,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_off_outlined, size: 56, color: Color(0xFF94A3B8)),
                              SizedBox(height: 12),
                              Text('الإحداثيات الجغرافية غير محددة لهذه الأزمة', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionsOnly() {
    final incident = widget.incident;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المهام المطلوبة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 16),
        if (incident.currentIncidentWithMissions?.isEmpty ?? true)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
            ),
            child: const Center(
              child: Text('لا توجد مهام مطلوبة لهذه الأزمة حالياً', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
            ),
          )
        else
          ...incident.currentIncidentWithMissions!.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.task_alt, color: Color(0xFF3B82F6), size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.missionName ?? 'مهمة غير معروفة',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(m.currentIncidentMissionStatus ?? 1).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              getStatusArabic(m.currentIncidentMissionStatus ?? 1),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: getStatusColor(m.currentIncidentMissionStatus ?? 1)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildGeneralData() {
    final incident = widget.incident;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final dateStr = incident.currentIncidentCreatedAt != null
        ? dateFormat.format(incident.currentIncidentCreatedAt!)
        : 'غير معروف';

    final statusText = incident.statusName ?? getStatusArabic(incident.currentIncidentStatus ?? 1);
    final statusColor = getStatusColor(incident.currentIncidentStatus ?? 1);
    
    final severityText = incident.severityName ?? getSeverityArabic(incident.currentIncidentSeverity ?? 1);
    final severityColor = getSeverityColor(incident.currentIncidentSeverity ?? 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'البيانات الأساسية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: severityColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: severityColor),
                      const SizedBox(width: 6),
                      Text(
                        severityText,
                        style: TextStyle(color: severityColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _InfoItem(title: 'حالة الأزمة', value: statusText, icon: Icons.check_circle_outline, color: statusColor),
            _InfoItem(title: 'نوع الأزمة', value: incident.currentIncidentTypeName ?? '', icon: Icons.category_outlined, color: Colors.blue),
            _InfoItem(title: 'الفرع', value: incident.branchName ?? '', icon: Icons.business_outlined, color: Colors.indigo),
            _InfoItem(title: 'تاريخ الإنشاء', value: dateStr, icon: Icons.calendar_today_outlined, color: Colors.teal),
            _InfoItem(title: 'منشئ البلاغ', value: incident.username ?? '', icon: Icons.person_outline, color: Colors.deepPurple),
            _InfoItem(title: 'درجة الخطورة', value: severityText, icon: Icons.warning_amber_rounded, color: severityColor),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final incident = widget.incident;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'وصف البلاغ والأزمة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            incident.currentIncidentDescription ?? 'لا يوجد وصف متاح.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
          ),
        ),
      ],
    );
  }



  Widget _buildCoordinateItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoItem({required this.title, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: effectiveColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  value.isEmpty ? 'لا يوجد' : value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
