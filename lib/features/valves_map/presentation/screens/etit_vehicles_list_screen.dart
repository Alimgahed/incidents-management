import 'package:flutter/material.dart';
import '../../models/etit_vehicle_model.dart';
import '../../services/etit_gps_service.dart';
import 'etit_fleet_map_screen.dart';

class EtitVehiclesListScreen extends StatefulWidget {
  const EtitVehiclesListScreen({super.key});

  @override
  State<EtitVehiclesListScreen> createState() => _EtitVehiclesListScreenState();
}

class _EtitVehiclesListScreenState extends State<EtitVehiclesListScreen> {
  final EtitGpsService _gpsService = EtitGpsService();

  List<EtitVehicleModel> _allVehicles = [];
  List<EtitVehicleModel> _filteredVehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedBranch = 'الكل';

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);
    final data = await _gpsService.getVehiclesWithLiveTracking();

    if (mounted) {
      setState(() {
        _allVehicles = data;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredVehicles = _allVehicles.where((v) {
      final matchesSearch = _searchQuery.isEmpty ||
          v.plateNumber.contains(_searchQuery) ||
          v.code.contains(_searchQuery) ||
          (v.allocation ?? '').contains(_searchQuery);

      final matchesBranch = _selectedBranch == 'الكل' || v.allocation == _selectedBranch;

      return matchesSearch && matchesBranch;
    }).toList();
  }

  List<String> get _branches {
    final list = _allVehicles.map((v) => v.allocation ?? 'غير محدد').toSet().toList();
    list.sort();
    return ['الكل', ...list];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أسطول سيارات شركة المياه (ETIT)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'فتح الخريطة الكاملة',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EtitFleetMapScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: _fetchVehicles,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Branch Filter Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث برقم اللوحة أو كود السيارة أو الفرع...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _branches.map((b) {
                      final isSelected = _selectedBranch == b;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: ChoiceChip(
                          label: Text(b),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedBranch = b;
                                _applyFilters();
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Vehicle List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري قراءة أسطول السيارات من ETIT...'),
                      ],
                    ),
                  )
                : _filteredVehicles.isEmpty
                    ? const Center(child: Text('لا توجد مركبات تطابق البحث'))
                    : RefreshIndicator(
                        onRefresh: _fetchVehicles,
                        child: ListView.builder(
                          itemCount: _filteredVehicles.length,
                          itemBuilder: (context, index) {
                            final v = _filteredVehicles[index];
                            final hasLoc = v.hasValidLocation;
                            final isMoving = v.isMoving;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isMoving
                                      ? Colors.green.shade100
                                      : hasLoc
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade200,
                                  child: Icon(
                                    Icons.directions_car,
                                    color: isMoving
                                        ? Colors.green
                                        : hasLoc
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      v.plateNumber,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'كود: ${v.code}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('الفرع: ${v.allocation ?? "غير محدد"} | النوع: ${v.vehicleType ?? "عادية"}'),
                                    Text('جهاز: ${v.vendorName ?? "Teltonika"} (IMEI: ${v.deviceCode ?? "N/A"})'),
                                    if (hasLoc)
                                      Text(
                                        'الحالة: ${isMoving ? "متحرك بسرعة ${v.speed} كم/س" : "متوقف (GPS متصل)"}',
                                        style: TextStyle(
                                          color: isMoving ? Colors.green.shade700 : Colors.blue.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.location_on, color: Colors.blue),
                                  tooltip: 'تتبع على الخريطة',
                                  onPressed: hasLoc
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EtitFleetMapScreen(targetVehicle: v),
                                            ),
                                          );
                                        }
                                      : () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('لا توجد إشارة GPS حديثة لهذه المركبة')),
                                          );
                                        },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.map),
        label: const Text('الخريطة المباشرة'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EtitFleetMapScreen()),
          );
        },
      ),
    );
  }
}
