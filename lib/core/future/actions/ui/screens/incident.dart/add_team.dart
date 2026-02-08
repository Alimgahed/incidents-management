import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class MiniaWaterMapApp extends StatelessWidget {
  const MiniaWaterMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'خريطة  المنيا',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Cairo'),
      home: const MiniaWaterMapScreen(),
    );
  }
}

// Models
class WaterPipe {
  final String id;
  final List<LatLng> coordinates;
  final String area;
  final String status;
  final int diameter;
  final String material;
  final String installDate;
  final int length;
  final double pressure;
  final Color color;

  WaterPipe({
    required this.id,
    required this.coordinates,
    required this.area,
    required this.status,
    required this.diameter,
    required this.material,
    required this.installDate,
    required this.length,
    required this.pressure,
    required this.color,
  });
}

class WaterValve {
  final String id;
  final LatLng position;
  final String type;
  final String status;
  final String code;
  final String installDate;
  final String lastMaintenance;
  final int diameter;
  final Color color;

  WaterValve({
    required this.id,
    required this.position,
    required this.type,
    required this.status,
    required this.code,
    required this.installDate,
    required this.lastMaintenance,
    required this.diameter,
    required this.color,
  });
}

class MiniaWaterMapScreen extends StatefulWidget {
  const MiniaWaterMapScreen({super.key});

  @override
  State<MiniaWaterMapScreen> createState() => _MiniaWaterMapScreenState();
}

class _MiniaWaterMapScreenState extends State<MiniaWaterMapScreen> {
  final MapController _mapController = MapController();
  List<WaterPipe> _pipes = [];
  List<WaterValve> _valves = [];
  String _selectedFilter = 'all';

  // Minya city center
  final LatLng _minyaCenter = LatLng(28.0871, 30.7618);

  @override
  void initState() {
    super.initState();
    _generateData();
  }

  void _generateData() {
    final random = Random();
    final pipes = <WaterPipe>[];
    final valves = <WaterValve>[];

    // Areas in Minya
    final areas = [
      {'name': 'وسط المدينة', 'lat': 28.0871, 'lng': 30.7618},
      {'name': 'شرق المنيا', 'lat': 28.0950, 'lng': 30.7750},
      {'name': 'غرب المنيا', 'lat': 28.0820, 'lng': 30.7500},
      {'name': 'شمال المنيا', 'lat': 28.1000, 'lng': 30.7600},
      {'name': 'جنوب المنيا', 'lat': 28.0700, 'lng': 30.7650},
      {'name': 'المنيا الجديدة', 'lat': 28.0600, 'lng': 30.7800},
      {'name': 'أبو قرقاص', 'lat': 28.0500, 'lng': 30.7400},
    ];

    final statuses = ['سليم', 'تسريب بسيط', 'تلف', 'قيد الصيانة'];
    final diameters = [100, 150, 200, 250, 300, 400];
    final materials = ['حديد', 'بلاستيك PVC', 'نحاس', 'استانلس'];

    // Generate pipes
    for (var i = 0; i < areas.length; i++) {
      final area = areas[i];
      for (var j = 0; j < 8; j++) {
        final startLat =
            (area['lat'] as double) + (random.nextDouble() - 0.5) * 0.02;
        final startLng =
            (area['lng'] as double) + (random.nextDouble() - 0.5) * 0.02;
        final endLat = startLat + (random.nextDouble() - 0.5) * 0.015;
        final endLng = startLng + (random.nextDouble() - 0.5) * 0.015;

        final status = statuses[random.nextInt(statuses.length)];
        final diameter = diameters[random.nextInt(diameters.length)];
        final material = materials[random.nextInt(materials.length)];

        pipes.add(
          WaterPipe(
            id: 'pipe-$i-$j',
            coordinates: [LatLng(startLat, startLng), LatLng(endLat, endLng)],
            area: area['name'] as String,
            status: status,
            diameter: diameter,
            material: material,
            installDate:
                '${2015 + random.nextInt(9)}-${(random.nextInt(12) + 1).toString().padLeft(2, '0')}',
            length: random.nextInt(500) + 100,
            pressure: (random.nextDouble() * 3 + 2),
            color: _getStatusColor(status),
          ),
        );
      }
    }

    // Generate valves
    final valveTypes = ['محبس رئيسي', 'محبس فرعي', 'محبس طوارئ', 'محبس تحكم'];
    final valveStatuses = ['يعمل', 'عطل', 'صيانة'];

    for (var i = 0; i < 40; i++) {
      final lat = _minyaCenter.latitude + (random.nextDouble() - 0.5) * 0.08;
      final lng = _minyaCenter.longitude + (random.nextDouble() - 0.5) * 0.08;
      final status = valveStatuses[random.nextInt(valveStatuses.length)];
      final type = valveTypes[random.nextInt(valveTypes.length)];

      valves.add(
        WaterValve(
          id: 'valve-$i',
          position: LatLng(lat, lng),
          type: type,
          status: status,
          code: 'V-${(i + 1).toString().padLeft(4, '0')}',
          installDate:
              '${2015 + random.nextInt(9)}-${(random.nextInt(12) + 1).toString().padLeft(2, '0')}',
          lastMaintenance:
              '${2023 + random.nextInt(2)}-${(random.nextInt(12) + 1).toString().padLeft(2, '0')}',
          diameter: [100, 150, 200, 250][random.nextInt(4)],
          color: _getValveStatusColor(status),
        ),
      );
    }

    setState(() {
      _pipes = pipes;
      _valves = valves;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'سليم':
        return Colors.green;
      case 'تسريب بسيط':
        return Colors.yellow.shade700;
      case 'تلف':
        return Colors.red;
      case 'قيد الصيانة':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getValveStatusColor(String status) {
    switch (status) {
      case 'يعمل':
        return Colors.green;
      case 'عطل':
        return Colors.red;
      case 'صيانة':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<WaterPipe> get _filteredPipes {
    if (_selectedFilter == 'all') return _pipes;
    if (_selectedFilter == 'damaged') {
      return _pipes
          .where((p) => p.status == 'تلف' || p.status == 'تسريب بسيط')
          .toList();
    }
    if (_selectedFilter == 'good') {
      return _pipes.where((p) => p.status == 'سليم').toList();
    }
    if (_selectedFilter == 'maintenance') {
      return _pipes.where((p) => p.status == 'قيد الصيانة').toList();
    }
    return _pipes;
  }

  List<WaterValve> get _filteredValves {
    if (_selectedFilter == 'all') return _valves;
    if (_selectedFilter == 'damaged') {
      return _valves.where((v) => v.status == 'عطل').toList();
    }
    if (_selectedFilter == 'good') {
      return _valves.where((v) => v.status == 'يعمل').toList();
    }
    if (_selectedFilter == 'maintenance') {
      return _valves.where((v) => v.status == 'صيانة').toList();
    }
    return _valves;
  }

  @override
  Widget build(BuildContext context) {
    final workingValves = _valves.where((v) => v.status == 'يعمل').length;
    final damagedPipes = _pipes.where((p) => p.status == 'تلف').length;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade600],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'خريطة شبكة مياه الشرب - محافظة المنيا',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'نظام إدارة ومراقبة المواسير والمحابس',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'إجمالي المواسير',
                    '${_pipes.length}',
                    Colors.blue,
                    Icons.plumbing,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'المحابس العاملة',
                    '$workingValves',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'إجمالي المحابس',
                    '${_valves.length}',
                    Colors.purple,
                    Icons.settings,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'مواسير تالفة',
                    '$damagedPipes',
                    Colors.red,
                    Icons.warning,
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('الكل', 'all', Colors.blue),
                  const SizedBox(width: 8),
                  _buildFilterChip('سليم', 'good', Colors.green),
                  const SizedBox(width: 8),
                  _buildFilterChip('تالف / عطل', 'damaged', Colors.red),
                  const SizedBox(width: 8),
                  _buildFilterChip('قيد الصيانة', 'maintenance', Colors.orange),
                ],
              ),
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _minyaCenter,
                    initialZoom: 13.0,
                    maxZoom: 18.0,
                    minZoom: 10.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.minya_water',
                    ),

                    // Pipe lines
                    PolylineLayer(
                      polylines: _filteredPipes.map((pipe) {
                        return Polyline(
                          points: pipe.coordinates,
                          color: pipe.color,
                          strokeWidth: 4.0,
                        );
                      }).toList(),
                    ),

                    // Valve markers
                    MarkerLayer(
                      markers: _filteredValves.map((valve) {
                        return Marker(
                          point: valve.position,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showValveDialog(valve),
                            child: Container(
                              decoration: BoxDecoration(
                                color: valve.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Legend
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'دليل الألوان',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildLegendItem(Colors.green, 'سليم / يعمل'),
                        _buildLegendItem(Colors.yellow.shade700, 'تسريب بسيط'),
                        _buildLegendItem(Colors.red, 'تلف / عطل'),
                        _buildLegendItem(Colors.blue, 'قيد الصيانة'),
                        _buildLegendItem(Colors.orange, 'صيانة محبس'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showValveDialog(WaterValve valve) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.purple),
            const SizedBox(width: 12),
            Text('معلومات المحبس', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('الكود', valve.code),
            _buildDetailRow('النوع', valve.type),
            _buildDetailRow('الحالة', valve.status, valve.color),
            _buildDetailRow('القطر', '${valve.diameter} مم'),
            _buildDetailRow('تاريخ التركيب', valve.installDate),
            _buildDetailRow('آخر صيانة', valve.lastMaintenance),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
