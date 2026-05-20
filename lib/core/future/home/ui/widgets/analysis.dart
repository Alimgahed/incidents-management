import 'package:flutter/material.dart';

class WaterCompanyAnalyticsDashboard extends StatefulWidget {
  const WaterCompanyAnalyticsDashboard({super.key});

  @override
  State<WaterCompanyAnalyticsDashboard> createState() =>
      _WaterCompanyAnalyticsDashboardState();
}

class _WaterCompanyAnalyticsDashboardState
    extends State<WaterCompanyAnalyticsDashboard> {
  String selectedTimeRange = 'month';

  final List<Map<String, dynamic>> incidents = [
    {
      'id': 1,
      'type': 'كسر ماسورة رئيسية',
      'status': 'قيد التنفيذ',
      'severity': 'حرجة',
      'area': 'مدينة المنيا',
      'team': 'فريق الصيانة السريعة A',
      'responseTime': 12,
      'date': '2024-12-20',
      'affectedCustomers': 850,
    },
    {
      'id': 2,
      'type': 'تسرب مياه',
      'status': 'تم حلها',
      'severity': 'متوسطة',
      'area': 'ملوي',
      'team': 'فريق الصيانة B',
      'responseTime': 18,
      'date': '2024-12-19',
      'affectedCustomers': 120,
    },
    {
      'id': 3,
      'type': 'انقطاع مياه',
      'status': 'قيد الانتظار',
      'severity': 'عالية',
      'area': 'سمالوط',
      'team': 'فريق الطوارئ C',
      'responseTime': 0,
      'date': '2024-12-21',
      'affectedCustomers': 650,
    },
    {
      'id': 4,
      'type': 'انسداد شبكة',
      'status': 'قيد التنفيذ',
      'severity': 'متوسطة',
      'area': 'أبو قرقاص',
      'team': 'فريق التسليك A',
      'responseTime': 25,
      'date': '2024-12-20',
      'affectedCustomers': 200,
    },
    {
      'id': 5,
      'type': 'كسر ماسورة فرعية',
      'status': 'تم حلها',
      'severity': 'منخفضة',
      'area': 'مغاغة',
      'team': 'فريق الصيانة A',
      'responseTime': 30,
      'date': '2024-12-18',
      'affectedCustomers': 45,
    },
    {
      'id': 6,
      'type': 'تلوث مياه',
      'status': 'قيد التنفيذ',
      'severity': 'حرجة',
      'area': 'بني مزار',
      'team': 'فريق الجودة A',
      'responseTime': 8,
      'date': '2024-12-21',
      'affectedCustomers': 1200,
    },
    {
      'id': 7,
      'type': 'ضعف ضغط المياه',
      'status': 'تم حلها',
      'severity': 'منخفضة',
      'area': 'دير مواس',
      'team': 'فريق الضخ A',
      'responseTime': 35,
      'date': '2024-12-17',
      'affectedCustomers': 80,
    },
    {
      'id': 8,
      'type': 'تسرب مياه',
      'status': 'قيد الانتظار',
      'severity': 'متوسطة',
      'area': 'مطاي',
      'team': 'فريق الصيانة C',
      'responseTime': 0,
      'date': '2024-12-21',
      'affectedCustomers': 150,
    },
    {
      'id': 9,
      'type': 'كسر عداد',
      'status': 'قيد التنفيذ',
      'severity': 'منخفضة',
      'area': 'العدوة',
      'team': 'فريق العدادات A',
      'responseTime': 40,
      'date': '2024-12-20',
      'affectedCustomers': 15,
    },
    {
      'id': 10,
      'type': 'انقطاع مياه',
      'status': 'تم حلها',
      'severity': 'حرجة',
      'area': 'مدينة المنيا',
      'team': 'فريق الطوارئ A',
      'responseTime': 10,
      'date': '2024-12-16',
      'affectedCustomers': 2500,
    },
    {
      'id': 11,
      'type': 'كسر ماسورة رئيسية',
      'status': 'تم حلها',
      'severity': 'عالية',
      'area': 'ملوي',
      'team': 'فريق الصيانة السريعة B',
      'responseTime': 15,
      'date': '2024-12-15',
      'affectedCustomers': 950,
    },
    {
      'id': 12,
      'type': 'تسرب مياه',
      'status': 'قيد التنفيذ',
      'severity': 'متوسطة',
      'area': 'سمالوط',
      'team': 'فريق الصيانة D',
      'responseTime': 22,
      'date': '2024-12-21',
      'affectedCustomers': 180,
    },
    {
      'id': 13,
      'type': 'عطل محطة ضخ',
      'status': 'قيد التنفيذ',
      'severity': 'حرجة',
      'area': 'أبو قرقاص',
      'team': 'فريق المحطات A',
      'responseTime': 7,
      'date': '2024-12-20',
      'affectedCustomers': 3200,
    },
    {
      'id': 14,
      'type': 'انسداد شبكة',
      'status': 'تم حلها',
      'severity': 'منخفضة',
      'area': 'مطاي',
      'team': 'فريق التسليك B',
      'responseTime': 45,
      'date': '2024-12-19',
      'affectedCustomers': 95,
    },
    {
      'id': 15,
      'type': 'ضعف ضغط المياه',
      'status': 'قيد الانتظار',
      'severity': 'عالية',
      'area': 'بني مزار',
      'team': 'فريق الضخ B',
      'responseTime': 0,
      'date': '2024-12-21',
      'affectedCustomers': 750,
    },
  ];

  int get total => incidents.length;
  int get active => incidents.where((i) => i['status'] != 'تم حلها').length;
  int get resolved => incidents.where((i) => i['status'] == 'تم حلها').length;
  int get pending =>
      incidents.where((i) => i['status'] == 'قيد الانتظار').length;
  int get critical => incidents.where((i) => i['severity'] == 'حرجة').length;
  int get totalAffectedCustomers =>
      incidents.fold<int>(0, (sum, i) => sum + (i['affectedCustomers'] as int));

  int get avgResponseTime {
    final withResponse = incidents.where((i) => i['responseTime'] > 0).toList();
    if (withResponse.isEmpty) return 0;
    return (withResponse.fold<int>(
              0,
              (sum, i) => sum + (i['responseTime'] as int),
            ) /
            withResponse.length)
        .round();
  }

  Map<String, int> countBy(String key) {
    final map = <String, int>{};
    for (var i in incidents) {
      map[i[key]] = (map[i[key]] ?? 0) + 1;
    }
    return map;
  }

  Color getSeverityColor(String s) =>
      {
        'حرجة': const Color(0xFFDC2626),
        'عالية': const Color(0xFFEA580C),
        'متوسطة': const Color(0xFFF59E0B),
        'منخفضة': const Color(0xFF16A34A),
      }[s] ??
      Colors.grey;
  Color getStatusColor(String s) =>
      {
        'قيد الانتظار': const Color(0xFFF59E0B),
        'قيد التنفيذ': const Color(0xFF0284C7),
        'تم حلها': const Color(0xFF16A34A),
      }[s] ??
      Colors.grey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'شركة مياه الشرب والصرف الصحي',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'محافظة المنيا - لوحة تحليل الطوارئ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButton<String>(
                        value: selectedTimeRange,
                        underline: const SizedBox(),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'week',
                            child: Text(
                              'آخر أسبوع',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'month',
                            child: Text(
                              'آخر شهر',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'quarter',
                            child: Text(
                              'آخر 3 أشهر',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'year',
                            child: Text(
                              'آخر سنة',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => selectedTimeRange = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text(
                        'تصدير',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildKPIs(),
                const SizedBox(height: 24),
                _buildCharts(),
                const SizedBox(height: 24),
                _buildIncidentTypes(),
                const SizedBox(height: 24),
                _buildTable(),
                const SizedBox(height: 24),
                _buildSummary(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;
        final w = wide
            ? (constraints.maxWidth - 72) / 5
            : (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _kpi(
              Icons.water_damage,
              'إجمالي البلاغات',
              total.toString(),
              'في الشهر الحالي',
              const Color(0xFF0284C7),
              8,
              w,
            ),
            _kpi(
              Icons.pending_actions,
              'بلاغات نشطة',
              active.toString(),
              '$pending في الانتظار',
              const Color(0xFFF59E0B),
              3,
              w,
            ),
            _kpi(
              Icons.access_time,
              'وقت الاستجابة',
              '$avgResponseTime دقيقة',
              'متوسط الوصول',
              const Color(0xFF8B5CF6),
              -12,
              w,
            ),
            _kpi(
              Icons.check_circle,
              'معدل الحل',
              '${((resolved / total) * 100).round()}%',
              '$resolved تم حلها',
              const Color(0xFF16A34A),
              -5,
              w,
            ),
            _kpi(
              Icons.people,
              'عملاء متأثرون',
              '${(totalAffectedCustomers / 1000).toStringAsFixed(1)}K',
              'إجمالي المتأثرين',
              const Color(0xFFDC2626),
              15,
              w,
            ),
          ],
        );
      },
    );
  }

  Widget _kpi(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
    int trend,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trend > 0 ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      trend > 0 ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: trend > 0 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${trend.abs()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trend > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    final bySeverity = countBy('severity');
    final byStatus = countBy('status');
    final byArea = countBy('area');
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _chart(
                  'توزيع حسب الخطورة',
                  Icons.bar_chart,
                  const Color(0xFF0284C7),
                  bySeverity,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _chart(
                  'توزيع حسب الحالة',
                  Icons.assessment,
                  const Color(0xFF16A34A),
                  byStatus,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _areas(byArea)),
            ],
          );
        }
        return Column(
          children: [
            _chart(
              'توزيع حسب الخطورة',
              Icons.bar_chart,
              const Color(0xFF0284C7),
              bySeverity,
            ),
            const SizedBox(height: 16),
            _chart(
              'توزيع حسب الحالة',
              Icons.assessment,
              const Color(0xFF16A34A),
              byStatus,
            ),
            const SizedBox(height: 16),
            _areas(byArea),
          ],
        );
      },
    );
  }

  Widget _chart(
    String title,
    IconData icon,
    Color color,
    Map<String, int> data,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...data.entries.map(
            (e) => _bar(
              e.key,
              e.value,
              e.key.contains('حرجة') ||
                      e.key.contains('عالية') ||
                      e.key.contains('متوسطة') ||
                      e.key.contains('منخفضة')
                  ? getSeverityColor(e.key)
                  : getStatusColor(e.key),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, int value, Color color) {
    final pct = ((value / total) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$value ($pct%)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / total,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _areas(Map<String, int> byArea) {
    final sorted = byArea.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: const Color(0xFF8B5CF6), size: 24),
              const SizedBox(width: 8),
              const Text(
                'أكثر المناطق تأثراً',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...sorted
              .take(6)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDDD6FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          e.value.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildIncidentTypes() {
    final byType = countBy('type');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: const Color(0xFFEA580C), size: 24),
              const SizedBox(width: 8),
              const Text(
                'أنواع البلاغات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 700;
              final cols = wide ? 4 : 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: byType.entries
                    .map(
                      (e) => Container(
                        width:
                            (constraints.maxWidth - (12 * (cols - 1))) / cols,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C4A6E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF075985),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.table_chart,
                      color: const Color(0xFF0284C7),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'سجل البلاغات المفصل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('تصفية'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey[200]),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columns: const [
                DataColumn(
                  label: Text(
                    'رقم',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'النوع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'الخطورة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'الحالة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'المنطقة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'الفريق',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'وقت الاستجابة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'العملاء',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
              rows: incidents
                  .map(
                    (i) => DataRow(
                      cells: [
                        DataCell(Text('#${i['id']}')),
                        DataCell(Text(i['type'])),
                        DataCell(
                          _badge(
                            i['severity'],
                            getSeverityColor(i['severity']),
                          ),
                        ),
                        DataCell(
                          _badge(i['status'], getStatusColor(i['status'])),
                        ),
                        DataCell(Text(i['area'])),
                        DataCell(
                          Text(i['team'], style: const TextStyle(fontSize: 11)),
                        ),
                        DataCell(
                          Text(
                            i['responseTime'] == 0
                                ? '-'
                                : '${i['responseTime']} دقيقة',
                          ),
                        ),
                        DataCell(Text('${i['affectedCustomers']}')),
                        DataCell(
                          Text(
                            i['date'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'الملخص التنفيذي والتوصيات',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _summaryCol1()),
                    const SizedBox(width: 24),
                    Expanded(child: _summaryCol2()),
                  ],
                );
              }
              return Column(
                children: [
                  _summaryCol1(),
                  const SizedBox(height: 20),
                  _summaryCol2(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryCol1() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '📊 التحليل الإحصائي',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFBFDBFE),
        ),
      ),
      const SizedBox(height: 12),
      _item('بلاغات المياه تمثل 53% من إجمالي الحوادث'),
      _item(
        'الحوادث الحرجة بنسبة ${((critical / total) * 100).round()}% تحتاج تدخل فوري',
      ),
      _item('متوسط وقت الاستجابة $avgResponseTime دقيقة (ممتاز)'),
      _item(
        '${(totalAffectedCustomers / 1000).toStringAsFixed(1)}K عميل متأثر بالحوادث الحالية',
      ),
    ],
  );

  Widget _summaryCol2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '💡 التوصيات الاستراتيجية',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFBFDBFE),
        ),
      ),
      const SizedBox(height: 12),
      _item('زيادة فرق الصيانة الوقائية في المنيا وملوي'),
      _item('إنشاء مخزون احتياطي للمواسير في المناطق الحرجة'),
      _item('تفعيل نظام الإنذار المبكر للكشف عن التسريبات'),
      _item('تدريب إضافي لفرق الطوارئ على محطات الضخ'),
    ],
  );

  Widget _item(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, color: Colors.white),
    ),
  );
}
