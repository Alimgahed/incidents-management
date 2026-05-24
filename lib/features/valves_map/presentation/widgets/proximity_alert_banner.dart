import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/features/valves_map/core/engine/geofence_state_machine.dart';
import 'package:incidents_managment/features/valves_map/presentation/logic/proximity_alert_cubit/proximity_alert_cubit.dart';

class ProximityAlertBanner extends StatelessWidget {
  const ProximityAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProximityAlertCubit, ProximityAlertState>(
      builder: (context, state) {
        if (state is! ProximityAlertActive) {
          return const SizedBox.shrink();
        }

        if (state.geofenceState == GeofenceState.outside || 
            state.geofenceState == GeofenceState.exiting) {
          return const SizedBox.shrink();
        }

        final isInside = state.geofenceState == GeofenceState.inside;
        final color = isInside ? Colors.red : Colors.orange;
        final icon = isInside ? Icons.warning_amber_rounded : Icons.info_outline;
        final text = isInside 
            ? 'تنبيه: أنت قريب جداً من المحبس (${state.distanceInMeters.toStringAsFixed(0)} متر)'
            : 'أنت تقترب من المحبس (${state.distanceInMeters.toStringAsFixed(0)} متر)';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              if (isInside)
                BoxShadow(
                  color: color.withAlpha(80),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
