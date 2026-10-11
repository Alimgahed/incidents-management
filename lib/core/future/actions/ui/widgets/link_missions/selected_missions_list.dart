import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/relation_incident_mission.dart' show SelectedMission;

class SelectedMissionsList extends StatelessWidget {
  final List<SelectedMission> selectedMissions;
  final Function(String) onRemove;

  const SelectedMissionsList({
    super.key,
    required this.selectedMissions,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.link, color: Color(0xFF1B4F8A), size: 20),
            const SizedBox(width: 8),
            const Text(
              'المهمات المرتبطة حالياً',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4F8A),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${selectedMissions.length} مهام',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: selectedMissions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final mission = selectedMissions[index];
            return _buildSelectedMissionCard(mission, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildSelectedMissionCard(SelectedMission mission, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Left actions (Delete, Reorder)
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => onRemove(mission.uniqueId),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
            ),
          ),
          
          const Spacer(),

          // Right Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                mission.missionName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle (Since category and responsible are not in SelectedMission, we omit or put placeholder)
              Text(
                'مهمة مسجلة بالنظام',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Circle and Icon
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment, color: Colors.blue, size: 24),
          ),
        ],
      ),
    );
  }
}
