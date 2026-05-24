import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/features/valves_map/presentation/logic/proximity_alert_cubit/proximity_alert_cubit.dart';

class NearestValveCard extends StatelessWidget {
  const NearestValveCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProximityAlertCubit, ProximityAlertState>(
      builder: (context, state) {
        if (state is! ProximityAlertActive) {
          return const SizedBox.shrink(); // Hide if no active tracking
        }

        final valve = state.nearestValve;
        final distance = state.distanceInMeters;

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.water_drop, color: Colors.blue, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'أقرب محبس: ${valve.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المنطقة: ${valve.zone}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDistance(distance),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getDistanceColor(distance),
                      ),
                    ),
                    const Text(
                      'المسافة',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDistance(double meters) {
    if (meters > 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} كم';
    }
    return '${meters.toStringAsFixed(0)} م';
  }

  Color _getDistanceColor(double meters) {
    if (meters <= 50) return Colors.red;
    if (meters <= 100) return Colors.orange;
    return Colors.green;
  }
}
