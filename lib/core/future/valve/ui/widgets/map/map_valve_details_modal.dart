import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

class MapValveDetailsModal extends StatefulWidget {
  final ValveModel valve;
  final VoidCallback onClose;

  const MapValveDetailsModal({
    super.key,
    required this.valve,
    required this.onClose,
  });

  @override
  State<MapValveDetailsModal> createState() => _MapValveDetailsModalState();
}

class _MapValveDetailsModalState extends State<MapValveDetailsModal> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final valve = widget.valve;
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
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
                        child: const Icon(Icons.water_drop, color: Color(0xFF1B4F8A), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'تفاصيل المحبس #${valve.id ?? ""}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: widget.onClose,
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
                  // Sidebar
                  Container(
                    width: 200,
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildTab(0, 'البيانات الهندسية', Icons.engineering_outlined),
                        _buildTab(1, 'الموقع الجغرافي', Icons.location_on_outlined),
                        _buildTab(2, 'التشغيل والتركيب', Icons.settings_applications_outlined),
                        _buildTab(3, 'الصور والملفات', Icons.photo_library_outlined),
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
          border: isSelected ? Border.all(color: const Color(0xFFBFDBFE)) : null,
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
        return _buildEngineeringData();
      case 1:
        return _buildLocationOnly();
      case 2:
        return _buildOperationData();
      case 3:
        return _buildPlaceholder('لا توجد صور وملفات متاحة لهذا المحبس', Icons.photo_library_outlined);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEngineeringData() {
    final valve = widget.valve;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'البيانات الهندسية والفنية',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
            _InfoItem(title: 'نوع المحبس', value: valve.valveType?.displayName ?? '', icon: Icons.category_outlined, color: Colors.blue),
            _InfoItem(title: 'الاختصار', value: valve.valveType?.abbreviation ?? '', icon: Icons.text_snippet_outlined, color: Colors.indigo),
            _InfoItem(title: 'قطر المحبس', value: '${valve.diameter ?? "-"} مم', icon: Icons.straighten, color: Colors.teal),
            _InfoItem(title: 'قطر الماسورة', value: '${valve.pipeDiameter ?? "-"} مم', icon: Icons.plumbing, color: Colors.deepPurple),
            _InfoItem(title: 'العمق', value: '${valve.depth ?? "-"} م', icon: Icons.layers, color: Colors.orange),
            _InfoItem(title: 'عدد اللفات', value: '${valve.numOfTurns ?? "-"}', icon: Icons.rotate_right, color: Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationData() {
    final valve = widget.valve;
    final isGood = valve.status == 'Good' || valve.status == 'جيد';
    final statusColor = isGood ? Colors.green : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'التشغيل والتركيب',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
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
                    valve.status ?? 'غير معروف',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
            _InfoItem(title: 'الوضع الحالي', value: valve.position ?? '', icon: Icons.settings_remote, color: Colors.blue),
            _InfoItem(title: 'الاتجاه', value: valve.direction ?? '', icon: Icons.explore, color: Colors.indigo),
            _InfoItem(title: 'سنة التركيب', value: '${valve.inServiceYear ?? "-"}', icon: Icons.calendar_today, color: Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationOnly() {
    final valve = widget.valve;
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
                  _buildCoordinateItem('خط العرض (Latitude)', valve.lat?.toStringAsFixed(5) ?? 'غير متوفر'),
                  _buildCoordinateItem('خط الطول (Longitude)', valve.long?.toStringAsFixed(5) ?? 'غير متوفر'),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 64, color: Color(0xFF94A3B8)),
                      SizedBox(height: 12),
                      Text('عرض الخريطة سيكون متاحاً قريباً', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
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
