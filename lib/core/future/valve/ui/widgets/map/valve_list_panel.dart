import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

class ValveListPanel extends StatelessWidget {
  final List<ValveModel> filteredValves;
  final Function(ValveModel) onValveTap;
  final int? totalCount;

  const ValveListPanel({
    super.key,
    required this.filteredValves,
    required this.onValveTap,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredValves.length,
              itemBuilder: (context, index) {
                final valve = filteredValves[index];
                return _ValveCard(
                  valve: valve,
                  onTap: () => onValveTap(valve),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalCount != null
                ? 'قائمة المحابس (${filteredValves.length} / $totalCount)'
                : 'قائمة المحابس (${filteredValves.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4F8A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValveCard extends StatelessWidget {
  final ValveModel valve;
  final VoidCallback onTap;

  const _ValveCard({required this.valve, required this.onTap});

  Color _getStatusColor(String? status) {
    final isGood = status == 'Good' || status == 'جيد';
    return isGood ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(valve.status);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.water_drop, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valve.valveType?.displayName ?? 'محبس غير معروف',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        valve.id?.toString() ?? 'بدون رقم',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      valve.status ?? 'غير معروف',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
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
