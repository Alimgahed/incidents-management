import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';

/// Socket connection + last live payload time (from [IncidentMapCubit]).
class DashboardLiveStatusStrip extends StatelessWidget {
  const DashboardLiveStatusStrip({super.key});

  String _formatTime(DateTime? t) {
    if (t == null) return '—';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentMapCubit, IncidentMapState>(
      buildWhen: (a, b) =>
          a.runtimeType != b.runtimeType ||
          b is IncidentMapLoaded ||
          b is IncidentMapError,
      builder: (context, state) {
        final cubit = context.read<IncidentMapCubit>();
        final connected = cubit.isConnected;
        final last = cubit.lastIncidentPayloadAt;
        final loading = state is IncidentMapLoading;
        final err = state is IncidentMapError ? state.message : null;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              _Chip(
                icon: connected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                label: connected ? 'متصل' : 'غير متصل',
                foreground: connected ? const Color(0xFF065F46) : const Color(0xFFB45309),
                background: connected ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.schedule_rounded,
                label: 'آخر تحديث ${_formatTime(last)}',
                foreground: const Color(0xFF1B4F8A),
                background: const Color(0xFFE2E8F0),
              ),
              if (err != null && err.isNotEmpty) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: err,
                  child: _Chip(
                    icon: Icons.warning_amber_rounded,
                    label: 'تنبيه',
                    foreground: const Color(0xFF991B1B),
                    background: const Color(0xFFFEE2E2),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  const _Chip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
