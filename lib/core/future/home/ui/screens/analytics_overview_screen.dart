import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';

/// Operational summary derived only from [IncidentMapCubit] live data (no dummy rows).
class AnalyticsOverviewScreen extends StatelessWidget {
  const AnalyticsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<IncidentMapCubit, IncidentMapState>(
          builder: (context, state) {
            if (state is IncidentMapInitial) {
              return _InitialConnectCard(
                onConnect: () => context.read<IncidentMapCubit>().initialize(),
              );
            }
            if (state is IncidentMapLoading && context.read<IncidentMapCubit>().incidents.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is IncidentMapError && context.read<IncidentMapCubit>().incidents.isEmpty) {
              return _ErrorCard(
                message: state.message,
                onRetry: () => context.read<IncidentMapCubit>().initialize(),
              );
            }
            
            final incidents = context.read<IncidentMapCubit>().incidents;
            return _LoadedBody(
              incidents: incidents,
              onRefresh: () => context.read<IncidentMapCubit>().refresh(),
              connected: context.read<IncidentMapCubit>().isConnected,
            );
          },
        ),
      ),
    );
  }
}

class _InitialConnectCard extends StatelessWidget {
  final VoidCallback onConnect;

  const _InitialConnectCard({required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub_outlined, size: 48, color: Color(0xFF1E3A5F)),
                const SizedBox(height: 16),
                Text(
                  'التدفق المباشر غير متصل',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'ملخص التحليلات يُشتق من بيانات الأزمات الحية فقط. اضغط للاتصال وتحميل اللقطة.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onConnect,
                  icon: const Icon(Icons.cloud_sync),
                  label: const Text('اتصال وتحميل البيانات'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final List<CurrentIncidentModel> incidents;
  final VoidCallback onRefresh;
  final bool connected;

  const _LoadedBody({
    required this.incidents,
    required this.onRefresh,
    required this.connected,
  });

  static void _addCount(Map<int, int> bucket, int? value) {
    if (value == null) return;
    bucket[value] = (bucket[value] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final severityCounts = <int, int>{};
    final statusCounts = <int, int>{};
    var missionsTotal = 0;

    for (final i in incidents) {
      _addCount(severityCounts, i.currentIncidentSeverity);
      _addCount(statusCounts, i.currentIncidentStatus);
      missionsTotal += i.currentIncidentWithMissions?.length ?? 0;
    }

    final severityEntries = severityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final statusEntries = statusCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxSeverity = severityEntries.isEmpty
        ? 1
        : severityEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxStatus = statusEntries.isEmpty
        ? 1
        : statusEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ملخص من التدفق المباشر',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Icon(
                connected ? Icons.cloud_done : Icons.cloud_off,
                color: connected ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(connected ? 'متصل' : 'غير متصل'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الأرقام المعروضة هي تكرار القيم كما وردت من الخادم (رموز الحالة والشدة).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                label: 'إجمالي الأزمات',
                value: '${incidents.length}',
                icon: Icons.emergency_outlined,
              ),
              _StatCard(
                label: 'إجمالي المهام (مجمّع)',
                value: '$missionsTotal',
                icon: Icons.checklist,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DistributionSection(
            title: 'توزيع الشدة (current_incident_severity)',
            entries: severityEntries,
            maxCount: maxSeverity,
          ),
          const SizedBox(height: 16),
          _DistributionSection(
            title: 'توزيع الحالة (current_incident_status)',
            entries: statusEntries,
            maxCount: maxStatus,
          ),
          if (incidents.isEmpty) ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                'لا توجد أزمات في اللقطة الحالية.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF1E3A5F)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistributionSection extends StatelessWidget {
  final String title;
  final List<MapEntry<int, int>> entries;
  final int maxCount;

  const _DistributionSection({
    required this.title,
    required this.entries,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final denom = maxCount <= 0 ? 1 : maxCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Text('لا توجد قيم في اللقطة الحالية.')
            else
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          'الرمز ${e.key}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: e.value / denom,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${e.value}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
