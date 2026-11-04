import 'dart:math' as math;
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
  final TextEditingController _searchController = TextEditingController();

  List<EtitVehicleModel> _allVehicles = [];
  List<EtitVehicleModel> _filteredVehicles = [];
  bool _isLoading = true;

  // Filters
  String _searchQuery = '';
  String _selectedBranch = 'الكل';
  String _selectedStatus = 'الكل'; // الكل, متحركة, متوقفة, GPS غير متصل
  String _selectedType = 'الكل';

  // Pagination
  int _currentPage = 1;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);
    final data = await _gpsService.getVehiclesWithLiveTracking();

    if (mounted) {
      setState(() {
        _allVehicles = data;
        _applyFilters(resetPage: true);
        _isLoading = false;
      });
    }
  }

  void _applyFilters({bool resetPage = false}) {
    if (resetPage) _currentPage = 1;

    _filteredVehicles = _allVehicles.where((v) {
      // 1. Search query
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          v.plateNumber.toLowerCase().contains(q) ||
          v.code.toLowerCase().contains(q) ||
          (v.codePlateNumber ?? '').toLowerCase().contains(q) ||
          (v.deviceCode ?? '').toLowerCase().contains(q) ||
          (v.allocation ?? '').toLowerCase().contains(q);

      // 2. Branch filter
      final matchesBranch =
          _selectedBranch == 'الكل' || (v.allocation ?? 'غير محدد') == _selectedBranch;

      // 3. Status filter
      bool matchesStatus = true;
      if (_selectedStatus == 'متحركة') {
        matchesStatus = v.isMoving;
      } else if (_selectedStatus == 'متوقفة') {
        matchesStatus = v.isStopped;
      } else if (_selectedStatus == 'GPS غير متصل') {
        matchesStatus = v.isOffline;
      }

      // 4. Vehicle Type filter
      final matchesType =
          _selectedType == 'الكل' || (v.vehicleType ?? 'غير محدد') == _selectedType;

      return matchesSearch && matchesBranch && matchesStatus && matchesType;
    }).toList();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedBranch = 'الكل';
      _selectedStatus = 'الكل';
      _selectedType = 'الكل';
      _applyFilters(resetPage: true);
    });
  }

  List<String> get _branches {
    final set = _allVehicles
        .map((v) => (v.allocation ?? '').trim().isEmpty ? 'غير محدد' : v.allocation!.trim())
        .toSet()
        .toList()
      ..sort();
    return ['الكل', ...set];
  }

  List<String> get _vehicleTypes {
    final set = _allVehicles
        .map((v) => (v.vehicleType ?? '').trim().isEmpty ? 'غير محدد' : v.vehicleType!.trim())
        .toSet()
        .toList()
      ..sort();
    return ['الكل', ...set];
  }

  // Dynamic KPI computations from model list
  int get _totalCount => _allVehicles.length;
  int get _movingCount => _allVehicles.where((v) => v.isMoving).length;
  int get _stoppedCount => _allVehicles.where((v) => v.isStopped).length;
  int get _offlineCount => _allVehicles.where((v) => v.isOffline).length;

  String _percentOfTotal(int count) {
    if (_totalCount == 0) return '0.0 % من الإجمالي';
    final pct = (count / _totalCount) * 100;
    return '${pct.toStringAsFixed(1)} % من الإجمالي';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0F3B6C)),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل بيانات الأسطول والإحداثيات الحية من ETIT...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchVehicles,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top 4 Summary Cards
                    _buildKpiCardsRow(),
                    const SizedBox(height: 16),

                    // 2. Search Bar + Action Buttons
                    _buildSearchAndActionsRow(),
                    const SizedBox(height: 14),

                    // 3. Advanced Filter Dropdowns Row
                    _buildAdvancedFiltersRow(),
                    const SizedBox(height: 16),

                    // 4. Data Table Card + Footer Pagination
                    _buildVehiclesTableCard(),
                  ],
                ),
              ),
            ),
    );
  }

  // ── 1. Top 4 KPI Cards ──────────────────────────────────────────────────────
  Widget _buildKpiCardsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final cards = [
          _buildKpiCard(
            title: 'إجمالي المركبات',
            count: '$_totalCount',
            subtitle: null,
            bgColor: const Color(0xFFEAF3FF),
            borderColor: const Color(0xFFBFDBFE),
            iconBgColor: const Color(0xFFDBEAFE),
            iconColor: const Color(0xFF1D4ED8),
            textColor: const Color(0xFF0F172A),
            icon: Icons.directions_car_filled_rounded,
            isSelected: _selectedStatus == 'الكل',
            onTap: () => setState(() {
              _selectedStatus = 'الكل';
              _applyFilters(resetPage: true);
            }),
          ),
          _buildKpiCard(
            title: 'متحركة',
            count: '$_movingCount',
            subtitle: _percentOfTotal(_movingCount),
            bgColor: const Color(0xFFEAFBF0),
            borderColor: const Color(0xFFBBF7D0),
            iconBgColor: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF15803D),
            textColor: const Color(0xFF15803D),
            icon: Icons.play_arrow_rounded,
            isSelected: _selectedStatus == 'متحركة',
            onTap: () => setState(() {
              _selectedStatus = _selectedStatus == 'متحركة' ? 'الكل' : 'متحركة';
              _applyFilters(resetPage: true);
            }),
          ),
          _buildKpiCard(
            title: 'متوقفة',
            count: '$_stoppedCount',
            subtitle: _percentOfTotal(_stoppedCount),
            bgColor: const Color(0xFFFFF8EB),
            borderColor: const Color(0xFFFDE68A),
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFB45309),
            textColor: const Color(0xFFB45309),
            icon: Icons.pause_rounded,
            isSelected: _selectedStatus == 'متوقفة',
            onTap: () => setState(() {
              _selectedStatus = _selectedStatus == 'متوقفة' ? 'الكل' : 'متوقفة';
              _applyFilters(resetPage: true);
            }),
          ),
          _buildKpiCard(
            title: 'GPS غير متصل',
            count: '$_offlineCount',
            subtitle: _percentOfTotal(_offlineCount),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            iconBgColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFB91C1C),
            textColor: const Color(0xFFB91C1C),
            icon: Icons.gps_off_rounded,
            isSelected: _selectedStatus == 'GPS غير متصل',
            onTap: () => setState(() {
              _selectedStatus =
                  _selectedStatus == 'GPS غير متصل' ? 'الكل' : 'GPS غير متصل';
              _applyFilters(resetPage: true);
            }),
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((c) => SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String count,
    required String? subtitle,
    required Color bgColor,
    required Color borderColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? iconColor : borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      height: 1.1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Search Bar + Refresh + Live Map Button ───────────────────────────────
  Widget _buildSearchAndActionsRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Search Input
        SizedBox(
          width: 480,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                  _applyFilters(resetPage: true);
                });
              },
              decoration: const InputDecoration(
                hintText: 'ابحث برقم اللوحة، كود السيارة، اسم السيارة أو IMEI...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF475569), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ),

        // Buttons: Refresh + Live Map
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: _fetchVehicles,
              icon: const Icon(Icons.sync_rounded, size: 18, color: Color(0xFF0F3B6C)),
              label: const Text(
                'تحديث البيانات',
                style: TextStyle(
                  color: Color(0xFF0F3B6C),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF93C5FD)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EtitFleetMapScreen()),
                );
              },
              icon: const Icon(Icons.map_outlined, size: 18, color: Colors.white),
              label: const Text(
                'الخريطة المباشرة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3B6C),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 3. Advanced Filter Dropdowns Row ────────────────────────────────────────
  Widget _buildAdvancedFiltersRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Label: تصفية متقدمة
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 18, color: Color(0xFF0F3B6C)),
              SizedBox(width: 6),
              Text(
                'تصفية متقدمة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F3B6C),
                ),
              ),
            ],
          ),

          // Dropdowns
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildFilterDropdown(
                label: 'الفرع',
                icon: Icons.apartment_rounded,
                fallbackIcon: Icons.apartment_rounded,
                value: _selectedBranch,
                items: _branches,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBranch = val;
                      _applyFilters(resetPage: true);
                    });
                  }
                },
              ),
              _buildFilterDropdown(
                label: 'حالة المركبة',
                icon: Icons.analytics_outlined,
                fallbackIcon: Icons.analytics_outlined,
                value: _selectedStatus,
                items: const ['الكل', 'متحركة', 'متوقفة', 'GPS غير متصل'],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedStatus = val;
                      _applyFilters(resetPage: true);
                    });
                  }
                },
              ),
              _buildFilterDropdown(
                label: 'نوع السيارة',
                icon: Icons.directions_car_outlined,
                fallbackIcon: Icons.directions_car_outlined,
                value: _selectedType,
                items: _vehicleTypes,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                      _applyFilters(resetPage: true);
                    });
                  }
                },
              ),
            ],
          ),

          // Clear Filters Button
          OutlinedButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF334155)),
            label: const Text(
              'مسح الفلاتر',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF8FAFC),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required IconData fallbackIcon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : 'الكل';

    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF475569)),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Row(
                children: [
                  Icon(fallbackIcon, size: 17, color: const Color(0xFF0F3B6C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── 4. Vehicles Table + Pagination Footer ───────────────────────────────────
  Widget _buildVehiclesTableCard() {
    final totalFiltered = _filteredVehicles.length;
    final totalPages = math.max(1, (totalFiltered / _pageSize).ceil());
    if (_currentPage > totalPages) _currentPage = totalPages;

    final startIndex = totalFiltered == 0 ? 0 : (_currentPage - 1) * _pageSize;
    final endIndex = math.min(startIndex + _pageSize, totalFiltered);
    final pageItems = totalFiltered == 0
        ? <EtitVehicleModel>[]
        : _filteredVehicles.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF4F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '#',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _HeaderCell(icon: null, label: 'المركبة / رقم اللوحة'),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell(icon: Icons.apartment_rounded, label: 'الفرع'),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell(icon: Icons.directions_car_outlined, label: 'النوع'),
                ),
                Expanded(
                  flex: 3,
                  child: _HeaderCell(icon: Icons.satellite_alt_rounded, label: 'جهاز التتبع (IMEI)'),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell(icon: Icons.calendar_today_outlined, label: 'آخر تحديث'),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell(icon: Icons.monitor_heart_outlined, label: 'الحالة'),
                ),
                SizedBox(
                  width: 140,
                  child: _HeaderCell(icon: Icons.location_on_outlined, label: 'الموقع'),
                ),
              ],
            ),
          ),

          // Table Rows
          if (pageItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'لا توجد مركبات مطابقة لمعايير البحث أو الفلترة الحالية',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pageItems.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (context, idx) {
                final rowNum = startIndex + idx + 1;
                final v = pageItems[idx];
                return _buildVehicleRow(rowNum, v);
              },
            ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Pagination Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                // Right: عرض X - Y من Z مركبة
                Text(
                  totalFiltered == 0
                      ? 'عرض 0 من 0 مركبة'
                      : 'عرض ${startIndex + 1} - $endIndex من $totalFiltered مركبة',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),

                // Center: Page Numbers
                _buildPageNumbersBar(totalPages),

                // Left: Page size selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'عدد العناصر في الصفحة',
                      style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _pageSize,
                          items: const [10, 20, 50, 100]
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text('$s', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _pageSize = val;
                                _currentPage = 1;
                              });
                            }
                          },
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

  Widget _buildVehicleRow(int rowNum, EtitVehicleModel v) {
    final isMoving = v.isMoving;
    final isOffline = v.isOffline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 1. #
          SizedBox(
            width: 40,
            child: Text(
              '$rowNum',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
            ),
          ),

          // 2. المركبة / رقم اللوحة
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    (v.vehicleType ?? '').toLowerCase().contains('trailer')
                        ? Icons.rv_hookup_rounded
                        : (v.vehicleType ?? '').toLowerCase().contains('truck')
                            ? Icons.local_shipping_rounded
                            : Icons.directions_car_filled_rounded,
                    color: const Color(0xFF0F3B6C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'كود: ${v.code.isNotEmpty ? v.code : "-"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        v.plateNumber.isNotEmpty ? v.plateNumber : (v.codePlateNumber ?? '-'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. الفرع
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF0F3B6C)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    (v.allocation ?? '').trim().isNotEmpty ? v.allocation! : 'غير محدد',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. النوع
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 18, color: Color(0xFF475569)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (v.vehicleType ?? '').isNotEmpty ? v.vehicleType! : '-',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        v.arabicVehicleType,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. جهاز التتبع (IMEI)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wifi_rounded,
                      size: 15,
                      color: isOffline ? const Color(0xFF94A3B8) : const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      (v.vendorName ?? '').isNotEmpty ? v.vendorName! : 'Teltonika',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if ((v.providerName ?? '').isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${v.providerName})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'IMEI: ${(v.deviceCode ?? '').isNotEmpty ? v.deviceCode : "-"}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 6. آخر تحديث
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF475569)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    (v.lastUpdate ?? '').isNotEmpty ? v.lastUpdate! : 'غير متوفر',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 7. الحالة
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMoving
                        ? const Color(0xFFDCFCE7)
                        : isOffline
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMoving
                              ? const Color(0xFF15803D)
                              : isOffline
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isMoving
                            ? 'متحركة'
                            : isOffline
                                ? 'GPS غير متصل'
                                : 'متوقفة',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isMoving
                              ? const Color(0xFF15803D)
                              : isOffline
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMoving
                      ? 'السرعة: ${v.speed?.toStringAsFixed(0) ?? 0} كم/س'
                      : (v.statusName ?? ''),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isMoving ? const Color(0xFF15803D) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // 8. الموقع (عرض على الخريطة)
          SizedBox(
            width: 140,
            child: OutlinedButton.icon(
              onPressed: v.hasValidLocation
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EtitFleetMapScreen(targetVehicle: v),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.location_on_outlined, size: 15),
              label: const Text(
                'عرض على الخريطة',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F3B6C),
                side: BorderSide(
                  color: v.hasValidLocation ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumbersBar(int totalPages) {
    final pagesToShow = <int>[];
    final start = math.max(1, _currentPage - 2);
    final end = math.min(totalPages, start + 4);
    for (int p = start; p <= end; p++) {
      pagesToShow.add(p);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPageBtn(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 1,
          onTap: () => setState(() => _currentPage--),
        ),
        const SizedBox(width: 4),
        for (final p in pagesToShow) ...[
          InkWell(
            onTap: () => setState(() => _currentPage = p),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p == _currentPage ? const Color(0xFF0284C7) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$p',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: p == _currentPage ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        _buildPageBtn(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages,
          onTap: () => setState(() => _currentPage++),
        ),
      ],
    );
  }

  Widget _buildPageBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _HeaderCell({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: const Color(0xFF0F3B6C)),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
