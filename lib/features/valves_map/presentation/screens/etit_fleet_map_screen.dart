import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/etit_vehicle_model.dart';
import '../../services/etit_gps_service.dart';

class EtitFleetMapScreen extends StatefulWidget {
  final EtitVehicleModel? targetVehicle;

  const EtitFleetMapScreen({super.key, this.targetVehicle});

  @override
  State<EtitFleetMapScreen> createState() => _EtitFleetMapScreenState();
}

class _EtitFleetMapScreenState extends State<EtitFleetMapScreen> {
  final MapController _mapController = MapController();
  final EtitGpsService _gpsService = EtitGpsService();
  final TextEditingController _searchController = TextEditingController();

  List<EtitVehicleModel> _allVehicles = [];
  List<EtitVehicleModel> _filteredVehicles = [];
  EtitVehicleModel? _selectedVehicle;

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSidePanelExpanded = false;
  bool _isFollowingSelected = false;

  // Filters (All dynamic from ETIT model data)
  String _searchQuery = '';
  String _selectedStatus = 'الكل'; // الكل, متحركة, متوقفة, غير متصل
  String _selectedBranch = 'الكل';
  String _selectedType = 'الكل';
  String _selectedVendor = 'الكل';
  String _selectedProvider = 'الكل';
  String _selectedSystemStatus = 'الكل';

  // Map tile style
  String _mapLayerKey = 'osm';

  Timer? _refreshTimer;

  static const LatLng _minyaCenter = LatLng(28.10988, 30.75030);

  static const Map<String, Map<String, String>> _mapLayers = {
    'osm': {
      'label': 'خريطة قياسية',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
    'satellite': {
      'label': 'قمر صناعي',
      'url':
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.targetVehicle;
    _loadLiveFleet();
    // Live polling every 10 seconds (100% Read-Only)
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadLiveFleet(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveFleet({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    } else {
      if (mounted) setState(() => _isRefreshing = true);
    }

    final data = await _gpsService.getVehiclesWithLiveTracking();

    if (!mounted) return;

    setState(() {
      _allVehicles = data;
      _applyFilters();
      _isLoading = false;
      _isRefreshing = false;

      if (_selectedVehicle != null) {
        final updated = _allVehicles.where((v) => v.id == _selectedVehicle!.id);
        if (updated.isNotEmpty) {
          _selectedVehicle = updated.first;
        }
      } else if (widget.targetVehicle != null && !silent) {
        final match = _allVehicles.where((v) => v.id == widget.targetVehicle!.id);
        if (match.isNotEmpty) {
          _selectedVehicle = match.first;
        }
      }
    });

    if (!silent && _selectedVehicle != null && _selectedVehicle!.hasValidLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            LatLng(_selectedVehicle!.latitude!, _selectedVehicle!.longitude!),
            15.5,
          );
        }
      });
    } else if (silent &&
        _isFollowingSelected &&
        _selectedVehicle != null &&
        _selectedVehicle!.hasValidLocation) {
      _mapController.move(
        LatLng(_selectedVehicle!.latitude!, _selectedVehicle!.longitude!),
        _mapController.camera.zoom,
      );
    }
  }

  void _applyFilters() {
    final q = _searchQuery.trim().toLowerCase();

    _filteredVehicles = _allVehicles.where((v) {
      final matchesSearch = q.isEmpty ||
          v.plateNumber.toLowerCase().contains(q) ||
          v.code.toLowerCase().contains(q) ||
          (v.codePlateNumber ?? '').toLowerCase().contains(q) ||
          (v.deviceCode ?? '').toLowerCase().contains(q) ||
          (v.allocation ?? '').toLowerCase().contains(q) ||
          (v.chassisNumber ?? '').toLowerCase().contains(q) ||
          (v.vendorName ?? '').toLowerCase().contains(q) ||
          (v.providerName ?? '').toLowerCase().contains(q);

      bool matchesStatus = true;
      if (_selectedStatus == 'متحركة') {
        matchesStatus = v.isMoving;
      } else if (_selectedStatus == 'متوقفة') {
        matchesStatus = v.isStopped;
      } else if (_selectedStatus == 'غير متصل') {
        matchesStatus = v.isOffline;
      }

      final vBranch = (v.allocation ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.allocation!.trim();
      final matchesBranch =
          _selectedBranch == 'الكل' || vBranch == _selectedBranch;

      final vType = (v.vehicleType ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.vehicleType!.trim();
      final matchesType = _selectedType == 'الكل' || vType == _selectedType;

      final vVendor = (v.vendorName ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.vendorName!.trim();
      final matchesVendor =
          _selectedVendor == 'الكل' || vVendor == _selectedVendor;

      final vProvider = (v.providerName ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.providerName!.trim();
      final matchesProvider =
          _selectedProvider == 'الكل' || vProvider == _selectedProvider;

      final vSysStatus = (v.statusName ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.statusName!.trim();
      final matchesSysStatus =
          _selectedSystemStatus == 'الكل' || vSysStatus == _selectedSystemStatus;

      return matchesSearch &&
          matchesStatus &&
          matchesBranch &&
          matchesType &&
          matchesVendor &&
          matchesProvider &&
          matchesSysStatus;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedStatus != 'الكل' ||
      _selectedBranch != 'الكل' ||
      _selectedType != 'الكل' ||
      _selectedVendor != 'الكل' ||
      _selectedProvider != 'الكل' ||
      _selectedSystemStatus != 'الكل';

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatus = 'الكل';
      _selectedBranch = 'الكل';
      _selectedType = 'الكل';
      _selectedVendor = 'الكل';
      _selectedProvider = 'الكل';
      _selectedSystemStatus = 'الكل';
      _applyFilters();
    });
  }

  List<String> _extractUniqueOptions(String? Function(EtitVehicleModel) getter) {
    final set = _allVehicles
        .map((v) {
          final val = (getter(v) ?? '').trim();
          return val.isEmpty ? 'غير محدد' : val;
        })
        .toSet()
        .toList()
      ..sort();
    return ['الكل', ...set];
  }

  List<String> get _branches => _extractUniqueOptions((v) => v.allocation);
  List<String> get _vehicleTypes => _extractUniqueOptions((v) => v.vehicleType);
  List<String> get _vendors => _extractUniqueOptions((v) => v.vendorName);
  List<String> get _providers => _extractUniqueOptions((v) => v.providerName);

  int get _totalCount => _allVehicles.length;
  int get _movingCount => _allVehicles.where((v) => v.isMoving).length;
  int get _stoppedCount => _allVehicles.where((v) => v.isStopped).length;
  int get _offlineCount => _allVehicles.where((v) => v.isOffline).length;

  void _fitAllMarkers() {
    final pts = _filteredVehicles
        .where((v) => v.hasValidLocation)
        .map((v) => LatLng(v.latitude!, v.longitude!))
        .toList();
    if (pts.isEmpty) {
      _mapController.move(_minyaCenter, 10.5);
      return;
    }
    if (pts.length == 1) {
      _mapController.move(pts.first, 15.0);
      return;
    }
    final bounds = LatLngBounds.fromPoints(pts);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(80, 120, 360, 120),
      ),
    );
  }

  void _selectAndFocusVehicle(EtitVehicleModel v, {bool fromPanel = false}) {
    setState(() {
      _selectedVehicle = v;
      if (fromPanel) {
        _isSidePanelExpanded = false;
      }
    });
    if (v.hasValidLocation) {
      _mapController.move(LatLng(v.latitude!, v.longitude!), 15.5);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'المركبة (${v.plateNumber.isNotEmpty ? v.plateNumber : v.code}) ليس لها إحداثيات GPS متصلة حالياً — تم عرض كافة بياناتها بالأسفل.',
          ),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _statusColor(EtitVehicleModel v) {
    if (v.isMoving) return const Color(0xFF16A34A);
    if (v.isStopped) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  Color _statusBgColor(EtitVehicleModel v) {
    if (v.isMoving) return const Color(0xFFDCFCE7);
    if (v.isStopped) return const Color(0xFFFEF3C7);
    return const Color(0xFFFEE2E2);
  }

  IconData _vehicleIcon(String? type) {
    final t = (type ?? '').toLowerCase();
    if (t.contains('trailer')) return Icons.rv_hookup_rounded;
    if (t.contains('truck')) return Icons.local_shipping_rounded;
    if (t.contains('pickup')) return Icons.local_shipping_outlined;
    return Icons.directions_car_filled_rounded;
  }

  DateTime? _parseEtitDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.trim();
    final direct = DateTime.tryParse(clean);
    if (direct != null) return direct;

    // Format like "4 November 2026 18:15" or "04 November 2026 18:15:22"
    final months = {
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
    };
    final m = RegExp(
      r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})\s+(\d{1,2}):(\d{2})(?::(\d{2}))?',
    ).firstMatch(clean);
    if (m != null) {
      final day = int.tryParse(m.group(1)!) ?? 1;
      final mon = months[m.group(2)!.toLowerCase()] ?? 1;
      final year = int.tryParse(m.group(3)!) ?? 2026;
      final hour = int.tryParse(m.group(4)!) ?? 0;
      final min = int.tryParse(m.group(5)!) ?? 0;
      final sec = int.tryParse(m.group(6) ?? '0') ?? 0;
      return DateTime(year, mon, day, hour, min, sec);
    }
    return null;
  }

  String _formatLastUpdateLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'غير متوفر';
    final dt = _parseEtitDate(raw);
    if (dt == null) return raw;
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'م' : 'ص';
    final timeStr =
        '${hour12.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $amPm';
    if (isToday) return 'اليوم $timeStr';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} $timeStr';
  }

  String _formatRelativeShort(String? raw) {
    final dt = _parseEtitDate(raw);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes} د';
    if (diff.inHours < 24) return '${diff.inHours} س';
    return '${diff.inDays} ي';
  }

  @override
  Widget build(BuildContext context) {
    final mapVehicles =
        _filteredVehicles.where((v) => v.hasValidLocation).toList();
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: Stack(
        children: [
          // ── 1. Interactive Live Map ────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.targetVehicle?.hasValidLocation == true
                  ? LatLng(
                      widget.targetVehicle!.latitude!,
                      widget.targetVehicle!.longitude!,
                    )
                  : _minyaCenter,
              initialZoom:
                  widget.targetVehicle?.hasValidLocation == true ? 15.0 : 11.0,
              maxZoom: 19,
              minZoom: 5,
              onTap: (_, _) => setState(() {
                _selectedVehicle = null;
                _isFollowingSelected = false;
              }),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    (_mapLayers[_mapLayerKey] ?? _mapLayers['osm']!)['url']!,
                userAgentPackageName: 'incidents_managment',
              ),
              MarkerLayer(
                markers: mapVehicles.map((v) => _buildVehicleMarker(v)).toList(),
              ),
            ],
          ),

          // ── 2. Left-Side Map Zoom & Tools Strip ───────────────────────────
          Positioned(
            left: 14,
            top: 135,
            child: _buildLeftMapToolsStrip(),
          ),

          // ── 3. Bottom-Left Status Legend Card (دليل الحالات) ───────────────
          Positioned(
            left: 14,
            bottom: 16,
            child: _buildStatusLegendCard(),
          ),

          // ── 4. Top Floating Filter Row + Right Stacked Controls & List ───
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopFloatingBar(canPop: canPop),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: SizedBox(
                    width: 322,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. تحديد الكل + تحديث الآن
                        Row(
                          children: [
                            Expanded(
                              child: _buildTopActionButton(
                                label: 'تحديد الكل',
                                icon: Icons.fit_screen_outlined,
                                onTap: _fitAllMarkers,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTopActionButton(
                                label: 'تحديث الآن',
                                icon: Icons.refresh_rounded,
                                isSpinning: _isRefreshing,
                                onTap: () => _loadLiveFleet(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 2. البحث بالرقم
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                                _applyFilters();
                              });
                            },
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'ابحث برقم اللوحة، كود السيارة أو IMEI...',
                              hintStyle: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 15,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _applyFilters();
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 3. زر قائمة المركبات
                        Material(
                          color: _isSidePanelExpanded
                              ? const Color(0xFF0F3B6C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          elevation: 3,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(
                              () => _isSidePanelExpanded = !_isSidePanelExpanded,
                            ),
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _isSidePanelExpanded
                                      ? const Color(0xFF0F3B6C)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions_car_filled_rounded,
                                    size: 18,
                                    color: _isSidePanelExpanded
                                        ? Colors.white
                                        : const Color(0xFF0F3B6C),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'قائمة المركبات (${_filteredVehicles.length})',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: _isSidePanelExpanded
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _isSidePanelExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: _isSidePanelExpanded
                                        ? Colors.white
                                        : const Color(0xFF475569),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 4. القائمة المنسدلة للمركبات (تظهر عند الضغط)
                        if (_isSidePanelExpanded)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              height: 360,
                              child: _buildRightVehiclesPanel(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 5. Selected Vehicle Floating Details Card ─────────────────────
          if (_selectedVehicle != null)
            Positioned(
              bottom: 16,
              left: 155,
              right: _isSidePanelExpanded ? 348 : 16,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _buildSelectedVehicleCard(_selectedVehicle!),
                ),
              ),
            ),

          // ── 7. Loading Overlay ────────────────────────────────────────────
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(45),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF0F3B6C),
                          ),
                        ),
                        SizedBox(width: 14),
                        Text(
                          'جاري تحميل خريطة الأسطول والبيانات الحية من ETIT...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. CUSTOM VEHICLE MARKER ON MAP
  // ═══════════════════════════════════════════════════════════════════════════
  Marker _buildVehicleMarker(EtitVehicleModel v) {
    final isSelected = _selectedVehicle?.id == v.id;
    final color = _statusColor(v);

    String statusSuffix;
    if (v.isMoving) {
      statusSuffix = '${v.speed?.toStringAsFixed(0) ?? '0'} كم/س';
    } else if (v.isStopped) {
      statusSuffix = 'متوقفة';
    } else {
      statusSuffix = 'غير متصل';
    }

    final displayName = v.plateNumber.isNotEmpty ? v.plateNumber : v.code;

    return Marker(
      point: LatLng(v.latitude!, v.longitude!),
      width: isSelected ? 175 : 155,
      height: isSelected ? 86 : 72,
      child: GestureDetector(
        onTap: () => _selectAndFocusVehicle(v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Label Pill Above Marker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F3B6C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.white : color.withAlpha(180),
                  width: 1.4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4ADE80) : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '$displayName · $statusSuffix',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            // Circular Vehicle Marker with Halo Ring
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withAlpha(55),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 1.5),
                    ),
                  ),
                Container(
                  width: isSelected ? 34 : 30,
                  height: isSelected ? 34 : 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _vehicleIcon(v.vehicleType),
                    color: Colors.white,
                    size: isSelected ? 18 : 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. TOP FLOATING FILTER & ACTION BAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopFloatingBar({required bool canPop}) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        // Right Group: Status Pills + Dropdowns + Search
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (canPop)
              Material(
                color: const Color(0xFF0F3B6C),
                borderRadius: BorderRadius.circular(10),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_rounded,
                            size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'عودة للقائمة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Status Filter Pills Group
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusPill(
                    label: 'الكل',
                    count: _totalCount,
                    value: 'الكل',
                    dotColor: null,
                    activeColor: const Color(0xFF0F3B6C),
                  ),
                  const SizedBox(width: 4),
                  _buildStatusPill(
                    label: 'متحركة',
                    count: _movingCount,
                    value: 'متحركة',
                    dotColor: const Color(0xFF16A34A),
                    activeColor: const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 4),
                  _buildStatusPill(
                    label: 'متوقفة',
                    count: _stoppedCount,
                    value: 'متوقفة',
                    dotColor: const Color(0xFFD97706),
                    activeColor: const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  _buildStatusPill(
                    label: 'غير متصل',
                    count: _offlineCount,
                    value: 'غير متصل',
                    dotColor: const Color(0xFFDC2626),
                    activeColor: const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),

            // Branch Dropdown
            _buildTopDropdownPill(
              prefixLabel: 'الفرع',
              icon: Icons.apartment_rounded,
              value: _selectedBranch,
              items: _branches,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedBranch = val;
                    _applyFilters();
                  });
                }
              },
            ),

            // Vehicle Type Dropdown
            _buildTopDropdownPill(
              prefixLabel: 'نوع السيارة',
              icon: Icons.directions_car_outlined,
              value: _selectedType,
              items: _vehicleTypes,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                    _applyFilters();
                  });
                }
              },
            ),

            // Tracker Vendor Dropdown
            _buildTopDropdownPill(
              prefixLabel: 'الجهاز',
              icon: Icons.router_outlined,
              value: _selectedVendor,
              items: _vendors,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedVendor = val;
                    _applyFilters();
                  });
                }
              },
            ),

            // SIM Provider Dropdown
            _buildTopDropdownPill(
              prefixLabel: 'الشريحة',
              icon: Icons.sim_card_outlined,
              value: _selectedProvider,
              items: _providers,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedProvider = val;
                    _applyFilters();
                  });
                }
              },
            ),

            if (_hasActiveFilters)
              Material(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _clearAllFilters,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded,
                            size: 15, color: Color(0xFFB91C1C)),
                        SizedBox(width: 4),
                        Text(
                          'مسح الفلاتر',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Left Group: Map Style + Live Status Badge (البث المباشر)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Map Layer Selector
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mapLayers.containsKey(_mapLayerKey)
                      ? _mapLayerKey
                      : 'osm',
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  items: _mapLayers.entries
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                size: 15,
                                color: Color(0xFF0F3B6C),
                              ),
                              const SizedBox(width: 6),
                              Text(e.value['label']!),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _mapLayerKey = val);
                    }
                  },
                ),
              ),
            ),

            // Live Stream Status Pill (البث المباشر فقط)
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'البث المباشر',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPill({
    required String label,
    required int count,
    required String value,
    required Color? dotColor,
    required Color activeColor,
  }) {
    final isSelected = _selectedStatus == value;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          _selectedStatus = value;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              '$label ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.white
                    : (dotColor ?? const Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDropdownPill({
    required String prefixLabel,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isFiltered = value != 'الكل';
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isFiltered ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFiltered
              ? const Color(0xFF3B82F6)
              : Colors.transparent,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : 'الكل',
          icon: const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          ),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: const Color(0xFF0F3B6C)),
                      const SizedBox(width: 6),
                      Text('$prefixLabel: $item'),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTopActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSpinning = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isSpinning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 16, color: const Color(0xFF0F3B6C)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. LEFT-SIDE MAP CONTROLS STRIP (+ / - / Center / Fit / Layers)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLeftMapToolsStrip() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMapToolIconButton(
            icon: Icons.add_rounded,
            tooltip: 'تكبير الخريطة',
            onTap: () {
              final z = (_mapController.camera.zoom + 1).clamp(5.0, 19.0);
              _mapController.move(_mapController.camera.center, z);
            },
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'تصغير الخريطة',
            onTap: () {
              final z = (_mapController.camera.zoom - 1).clamp(5.0, 19.0);
              _mapController.move(_mapController.camera.center, z);
            },
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.my_location_rounded,
            tooltip: 'توسيط محافظة المنيا',
            onTap: () => _mapController.move(_minyaCenter, 11.0),
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.fullscreen_rounded,
            tooltip: 'احتواء جميع المركبات المعروضة',
            onTap: _fitAllMarkers,
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.layers_outlined,
            tooltip: 'تبديل طبقة الخريطة',
            onTap: () {
              final keys = _mapLayers.keys.toList();
              final nextIdx = (keys.indexOf(_mapLayerKey) + 1) % keys.length;
              setState(() => _mapLayerKey = keys[nextIdx]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapToolIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: const Color(0xFF334155)),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. BOTTOM-LEFT STATUS LEGEND CARD (دليل الحالات)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStatusLegendCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(245),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'دليل الحالات',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('متحركة ($_movingCount)', const Color(0xFF16A34A)),
          const SizedBox(height: 5),
          _buildLegendItem('متوقفة ($_stoppedCount)', const Color(0xFFD97706)),
          const SizedBox(height: 5),
          _buildLegendItem(
            'غير متصل ($_offlineCount)',
            const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. RIGHT-SIDE COLLAPSIBLE VEHICLES PANEL (قائمة المركبات)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRightVehiclesPanel() {
    if (!_isSidePanelExpanded) {
      return Align(
        alignment: Alignment.topRight,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isSidePanelExpanded = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 18,
                    color: Color(0xFF0F3B6C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'قائمة المركبات (${_filteredVehicles.length})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 322,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car_filled_rounded,
                  size: 18,
                  color: Color(0xFF0F3B6C),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'قائمة المركبات (${_filteredVehicles.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'طي القائمة',
                  icon: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () =>
                      setState(() => _isSidePanelExpanded = false),
                ),
              ],
            ),
          ),

          // Quick Search Inside Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _applyFilters();
                  });
                },
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'بحث برقم اللوحة أو الكود...',
                  hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 4 Mini Status Tabs inside Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildPanelMiniTab('الكل ($_totalCount)', 'الكل'),
                const SizedBox(width: 4),
                _buildPanelMiniTab('متحركة ($_movingCount)', 'متحركة'),
                const SizedBox(width: 4),
                _buildPanelMiniTab('متوقفة ($_stoppedCount)', 'متوقفة'),
                const SizedBox(width: 4),
                _buildPanelMiniTab('غير متصل ($_offlineCount)', 'غير متصل'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Vehicle Cards List
          Expanded(
            child: _filteredVehicles.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'لا توجد مركبات مطابقة للفلاتر المحددة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    itemCount: _filteredVehicles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final v = _filteredVehicles[index];
                      return _buildPanelVehicleItem(v);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelMiniTab(String text, String statusValue) {
    final isSelected = _selectedStatus == statusValue;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          setState(() {
            _selectedStatus = statusValue;
            _applyFilters();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F3B6C)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelVehicleItem(EtitVehicleModel v) {
    final isSelected = _selectedVehicle?.id == v.id;
    final statusCol = _statusColor(v);
    final relTime = _formatRelativeShort(v.lastUpdate);

    String statusTrailing;
    if (v.isMoving) {
      statusTrailing = '${v.speed?.toStringAsFixed(0) ?? '0'} كم/س';
    } else if (v.isStopped) {
      statusTrailing = relTime.isNotEmpty ? 'متوقفة · $relTime' : 'متوقفة';
    } else {
      statusTrailing = relTime.isNotEmpty ? 'غير متصل · $relTime' : 'غير متصل';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _selectAndFocusVehicle(v, fromPanel: true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Vehicle Icon + Colored Status Dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(
                    _vehicleIcon(v.vehicleType),
                    color: const Color(0xFF334155),
                    size: 20,
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusCol,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // Plate + Code + Branch + Speed/Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          v.plateNumber.isNotEmpty ? v.plateNumber : v.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          v.code,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          (v.allocation ?? '').trim().isNotEmpty
                              ? v.allocation!
                              : 'غير محدد',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusTrailing,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusCol,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. SELECTED VEHICLE FLOATING DETAILS CARD (Bottom Overlay)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSelectedVehicleCard(EtitVehicleModel v) {
    final statusCol = _statusColor(v);
    final statusBg = _statusBgColor(v);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dark Navy Header Bar ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF0F3B6C),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _vehicleIcon(v.vehicleType),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        v.plateNumber.isNotEmpty ? v.plateNumber : v.code,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'كود: ${v.code}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusCol,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        v.arabicStatusLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: statusCol,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() {
                    _selectedVehicle = null;
                    _isFollowingSelected = false;
                  }),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── White Body: All Vehicle Info Cells ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'السرعة الحالية',
                        value: '${v.speed?.toStringAsFixed(0) ?? '0'} كم/س',
                        valueColor: statusCol,
                        icon: Icons.speed_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'الفرع',
                        value: (v.allocation ?? '').trim().isNotEmpty
                            ? v.allocation!
                            : 'غير محدد',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'النوع',
                        value:
                            '${v.vehicleType ?? '-'} · ${v.arabicVehicleType}',
                        icon: Icons.directions_car_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'آخر تحديث',
                        value: _formatLastUpdateLabel(v.lastUpdate),
                        icon: Icons.access_time_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'جهاز التتبع والشريحة',
                        value:
                            '${(v.vendorName ?? '').isNotEmpty ? v.vendorName : 'غير محدد'} (${(v.providerName ?? '').isNotEmpty ? v.providerName : '-'})',
                        icon: Icons.wifi_tethering_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'رقم IMEI',
                        value: (v.deviceCode ?? '').trim().isNotEmpty
                            ? v.deviceCode!
                            : 'غير مسجل',
                        icon: Icons.qr_code_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ── Footer Bar: Coordinates + Full Details + Follow Button ─────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                // Coordinates + Copy
                InkWell(
                  onTap: v.hasValidLocation
                      ? () {
                          Clipboard.setData(
                            ClipboardData(
                              text: '${v.latitude}, ${v.longitude}',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ الإحداثيات'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: Color(0xFF0F3B6C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        v.hasValidLocation
                            ? '${v.latitude!.toStringAsFixed(4)}° N, ${v.longitude!.toStringAsFixed(4)}° E'
                            : 'لا توجد إحداثيات GPS متصلة حالياً',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAllVehicleDataModal(v),
                      icon: const Icon(Icons.info_outline_rounded, size: 16),
                      label: const Text('كل بيانات المركبة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F3B6C),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: v.hasValidLocation
                          ? () {
                              setState(() {
                                _isFollowingSelected = !_isFollowingSelected;
                              });
                              _mapController.move(
                                LatLng(v.latitude!, v.longitude!),
                                16.0,
                              );
                            }
                          : null,
                      icon: Icon(
                        _isFollowingSelected
                            ? Icons.gps_fixed_rounded
                            : Icons.navigation_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isFollowingSelected
                            ? 'جاري التتبع المباشر'
                            : 'تتبع المركبة',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowingSelected
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF0F3B6C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailMetricCell({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 14, color: valueColor ?? const Color(0xFF0F3B6C)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. FULL VEHICLE DATA MODAL (Displays every single field from ETIT)
  // ═══════════════════════════════════════════════════════════════════════════
  void _showAllVehicleDataModal(EtitVehicleModel v) {
    final allRows = <MapEntry<String, String>>[
      MapEntry('المعرف الفريد (ID)', v.id),
      MapEntry('كود المركبة (code)', v.code),
      MapEntry('رقم اللوحة (plateNo)', v.plateNumber),
      MapEntry('الكود واللوحة (CodePlateNumber)', v.codePlateNumber ?? '-'),
      MapEntry('الفرع / التخصيص (Allocation)', v.allocation ?? '-'),
      MapEntry('معرف الفرع (branch UUID)', v.branch ?? '-'),
      MapEntry(
        'نوع المركبة (VehicleType)',
        '${v.vehicleType ?? '-'} (${v.arabicVehicleType})',
      ),
      MapEntry('حالة المركبة بالمنظومة (StatusName)', v.statusName ?? '-'),
      MapEntry('حالة الاتصال الحالية', v.arabicStatusLabel),
      MapEntry('كود حالة التتبع اللحظي (statusCode)', v.statusCode ?? '-'),
      MapEntry(
        'السرعة الحالية (speed)',
        '${v.speed?.toStringAsFixed(1) ?? '0.0'} كم/س',
      ),
      MapEntry('دائرة العرض (latitude)', v.latitude?.toString() ?? '-'),
      MapEntry('خط الطول (longitude)', v.longitude?.toString() ?? '-'),
      MapEntry('توقيت آخر تحديث (lastUpdate)', v.lastUpdate ?? '-'),
      MapEntry('رقم جهاز التتبع IMEI (deviceCode)', v.deviceCode ?? '-'),
      MapEntry('الشركة المصنعة للجهاز (Vendor_Name)', v.vendorName ?? '-'),
      MapEntry('مزود شريحة الاتصال (providerName)', v.providerName ?? '-'),
      MapEntry(
        'رقم الشاسيه (ChassisNumber)',
        (v.chassisNumber ?? '').isNotEmpty ? v.chassisNumber! : 'غير مسجل',
      ),
      MapEntry('خاضعة للمراقبة (isMonitored)', v.isMonitored ? 'نعم' : 'لا'),
    ];

    // Append any extra keys in rawData that aren't already listed
    const knownKeys = {
      'ID',
      'code',
      'plateNo',
      'CodePlateNumber',
      'Allocation',
      'branch',
      'VehicleType',
      'StatusName',
      'deviceCode',
      'Vendor_Name',
      'providerName',
      'ChassisNumber',
      'isMonitored',
      'latitude',
      'longitude',
      'speed',
      'statusCode',
      'lastUpdate',
    };
    for (final entry in v.rawData.entries) {
      if (!knownKeys.contains(entry.key)) {
        allRows.add(MapEntry(entry.key, '${entry.value ?? '-'}'));
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F3B6C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'كافة بيانات المركبة: ${v.plateNumber.isNotEmpty ? v.plateNumber : v.code}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: allRows.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  itemBuilder: (_, i) {
                    final item = allRows[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              item.key,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: SelectableText(
                              item.value,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
