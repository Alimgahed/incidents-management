import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/auth/data/model/registration_model.dart';
import 'package:incidents_managment/core/future/reports/data/repo/reports_repo.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';
import 'package:incidents_managment/core/helpers/arabic_text_helper.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepo _reportsRepo;

  ReportsCubit({required ReportsRepo reportsRepo})
      : _reportsRepo = reportsRepo,
        super(const ReportsInitial());

  List<CurrentIncidentModel> _allIncidents = [];
  List<Sector> _apiBranches = [];

  // Filter values
  String _searchQuery = '';
  String? _selectedManager;
  int? _selectedStatus;
  int? _selectedSeverity;
  String? _selectedType;
  int? _selectedBranchId;
  String? _selectedBranchName;
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _hasPhotos;
  bool? _hasMissions;
  bool? _hasCoordinates;
  int _activeTabIndex = 0;
  String _trendPeriod = 'شهري'; // 'شهري', 'أسبوعي', 'يومي'

  /// Loads all incidents and official branch data from backend
  Future<void> loadReports() async {
    emit(const ReportsLoading());

    final results = await Future.wait([
      _reportsRepo.getCurrentIncidents(),
      _reportsRepo.getBranches(),
    ]);

    final incidentResult = results[0] as ApiResult<List<CurrentIncidentModel>>;
    final branches = results[1] as List<Sector>;
    _apiBranches = branches;

    switch (incidentResult) {
      case ApiResultSuccess(:final data):
        _allIncidents = data;
        _recomputeAndEmit();
      case ApiResultError(:final error):
        emit(ReportsError(error.error ?? 'حدث خطأ في تحميل التقارير'));
    }
  }

  /// Refreshes data without resetting active filters
  Future<void> refresh() async {
    final results = await Future.wait([
      _reportsRepo.getCurrentIncidents(),
      _reportsRepo.getBranches(),
    ]);

    final incidentResult = results[0] as ApiResult<List<CurrentIncidentModel>>;
    final branches = results[1] as List<Sector>;
    if (branches.isNotEmpty) {
      _apiBranches = branches;
    }

    switch (incidentResult) {
      case ApiResultSuccess(:final data):
        _allIncidents = data;
        _recomputeAndEmit();
      case ApiResultError():
        if (state is! ReportsLoaded) {
          emit(const ReportsError('تعذر تحديث بيانات التقارير'));
        }
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _recomputeAndEmit();
  }

  void setSelectedManager(String? manager) {
    _selectedManager = (manager == null || manager == 'الكل') ? null : manager;
    _recomputeAndEmit();
  }

  void setSelectedStatus(int? status) {
    _selectedStatus = status;
    _recomputeAndEmit();
  }

  void setSelectedSeverity(int? severity) {
    _selectedSeverity = severity;
    _recomputeAndEmit();
  }

  void setSelectedType(String? type) {
    _selectedType = (type == null || type == 'الكل') ? null : type;
    _recomputeAndEmit();
  }

  void setSelectedBranchId(int? branchId, [String? branchName]) {
    _selectedBranchId = branchId;
    _selectedBranchName = branchName;
    _recomputeAndEmit();
  }

  void setSelectedBranch(String? branch) {
    if (branch == null || branch == 'الكل') {
      _selectedBranchName = null;
      _selectedBranchId = null;
    } else {
      _selectedBranchName = branch;
      // Try to find matching branchId from all incidents
      for (final inc in _allIncidents) {
        if (inc.branchName == branch && inc.branchId != null) {
          _selectedBranchId = inc.branchId;
          break;
        }
      }
    }
    _recomputeAndEmit();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _recomputeAndEmit();
  }

  void toggleHasPhotos(bool? val) {
    _hasPhotos = val;
    _recomputeAndEmit();
  }

  void toggleHasMissions(bool? val) {
    _hasMissions = val;
    _recomputeAndEmit();
  }

  void toggleHasCoordinates(bool? val) {
    _hasCoordinates = val;
    _recomputeAndEmit();
  }

  void selectTab(int index) {
    _activeTabIndex = index;
    if (state is ReportsLoaded) {
      emit((state as ReportsLoaded).copyWith(activeTabIndex: index));
    }
  }

  void setTrendPeriod(String period) {
    _trendPeriod = period;
    _recomputeAndEmit();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedManager = null;
    _selectedStatus = null;
    _selectedSeverity = null;
    _selectedType = null;
    _selectedBranchId = null;
    _selectedBranchName = null;
    _startDate = null;
    _endDate = null;
    _hasPhotos = null;
    _hasMissions = null;
    _hasCoordinates = null;
    _recomputeAndEmit();
  }

  void _recomputeAndEmit() {
    // 1. Dynamic Dropdown Options strictly derived from actual data
    final managersSet = <String>{};
    final typesSet = <String>{};
    final branchMap = <int, String>{};
    final branchesWithoutIdSet = <String>{};

    // First populate all branches dynamically from backend /register API
    for (final b in _apiBranches) {
      if (b.name.trim().isNotEmpty) {
        branchMap[b.id] = b.name.trim();
      }
    }

    for (final inc in _allIncidents) {
      if (inc.managerName != null && inc.managerName!.trim().isNotEmpty) {
        managersSet.add(inc.managerName!.trim());
      }
      if (inc.username != null && inc.username!.trim().isNotEmpty) {
        managersSet.add(inc.username!.trim());
      }
      if (inc.currentIncidentTypeName != null &&
          inc.currentIncidentTypeName!.trim().isNotEmpty) {
        typesSet.add(inc.currentIncidentTypeName!.trim());
      }
      if (inc.branchId != null &&
          inc.branchName != null &&
          inc.branchName!.trim().isNotEmpty) {
        branchMap[inc.branchId!] = inc.branchName!.trim();
      } else if (inc.branchName != null && inc.branchName!.trim().isNotEmpty) {
        branchesWithoutIdSet.add(inc.branchName!.trim());
      }
    }

    final branchOptions = <BranchOption>[];
    for (final entry in branchMap.entries) {
      branchOptions.add(BranchOption(id: entry.key, name: entry.value));
    }
    for (final name in branchesWithoutIdSet) {
      if (!branchMap.values.contains(name)) {
        branchOptions.add(BranchOption(id: null, name: name));
      }
    }
    branchOptions.sort((a, b) => a.name.compareTo(b.name));

    final availableBranchNames = branchOptions.map((b) => b.name).toList();

    // 2. Filter incidents using active criteria
    final filtered = _allIncidents.where((item) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = ArabicTextHelper.normalize(_searchQuery);
        final matches = ArabicTextHelper.normalize(item.currentIncidentDescription).contains(q) ||
            ArabicTextHelper.normalize(item.currentIncidentNotes).contains(q) ||
            ArabicTextHelper.normalize(item.currentIncidentTypeName).contains(q) ||
            ArabicTextHelper.normalize(item.branchName).contains(q) ||
            ArabicTextHelper.normalize(item.address).contains(q) ||
            ArabicTextHelper.normalize(item.managerName).contains(q) ||
            ArabicTextHelper.normalize(item.username).contains(q) ||
            (item.currentIncidentId?.toString() ?? '').contains(q);
        if (!matches) return false;
      }

      // Manager filter
      if (_selectedManager != null && _selectedManager!.isNotEmpty) {
        final matchesManager = (item.managerName == _selectedManager) ||
            (item.username == _selectedManager);
        if (!matchesManager) return false;
      }

      // Status filter
      if (_selectedStatus != null) {
        if (item.currentIncidentStatus != _selectedStatus) return false;
      }

      // Severity filter
      if (_selectedSeverity != null) {
        if (item.currentIncidentSeverity != _selectedSeverity) return false;
      }

      // Type filter
      if (_selectedType != null && _selectedType!.isNotEmpty) {
        if (item.currentIncidentTypeName != _selectedType) return false;
      }

      // Branch filter (supports ID or Name matching)
      if (_selectedBranchId != null) {
        if (item.branchId != _selectedBranchId) return false;
      } else if (_selectedBranchName != null && _selectedBranchName!.isNotEmpty) {
        if (item.branchName != _selectedBranchName) return false;
      }

      // Date range filter
      if (_startDate != null) {
        final created = item.currentIncidentCreatedAt;
        if (created == null || created.isBefore(_startDate!)) return false;
      }
      if (_endDate != null) {
        final created = item.currentIncidentCreatedAt;
        final endOfDay = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        if (created == null || created.isAfter(endOfDay)) return false;
      }

      // Extra toggle: Photos
      if (_hasPhotos != null) {
        final hasPhotosNow = item.photos != null && item.photos!.isNotEmpty;
        if (hasPhotosNow != _hasPhotos) return false;
      }

      // Extra toggle: Missions
      if (_hasMissions != null) {
        final hasMissionsNow = item.currentIncidentWithMissions != null &&
            item.currentIncidentWithMissions!.isNotEmpty;
        if (hasMissionsNow != _hasMissions) return false;
      }

      // Extra toggle: Coordinates
      if (_hasCoordinates != null) {
        final hasCoordsNow = (item.currentIncidentXAxis != null && item.currentIncidentXAxis != 0) &&
            (item.currentIncidentYAxis != null && item.currentIncidentYAxis != 0);
        if (hasCoordsNow != _hasCoordinates) return false;
      }

      return true;
    }).toList();

    // 3. KPI Metrics
    final total = filtered.length;
    // Active incidents: 1:تم التبليغ, 2:تم الارسال, 3:قيد التنفيذ, 4:قيد الانتظار, 5:قيد المراجعة
    final active = filtered.where((i) {
      final s = i.currentIncidentStatus;
      return s == 1 || s == 2 || s == 3 || s == 4 || s == 5;
    }).length;

    // High & Critical Severity: 3 (عالية) & 4 (حرجة)
    final highSeverity = filtered.where((i) {
      final sev = i.currentIncidentSeverity;
      return sev == 3 || sev == 4;
    }).length;

    // Closed/Resolved incidents: 6 (تم حلها), 7 (تم الرفض)
    final closed = filtered.where((i) {
      final s = i.currentIncidentStatus;
      return s == 6 || s == 7;
    }).length;

    // Documented with photos
    final documentedWithPhotos = filtered.where((i) {
      return i.photos != null && i.photos!.isNotEmpty;
    }).length;

    // New incidents: Incidents created within the active filtered range
    // If date range is specified, all matching incidents were created in that range.
    // If no date range is set, count incidents created within the last 7 days of dataset
    int newIncidentsCount = 0;
    if (_startDate != null) {
      newIncidentsCount = total;
    } else if (filtered.isNotEmpty) {
      final latestDate = filtered
          .map((e) => e.currentIncidentCreatedAt)
          .whereType<DateTime>()
          .fold<DateTime?>(null, (prev, curr) {
            if (prev == null) return curr;
            return curr.isAfter(prev) ? curr : prev;
          });
      if (latestDate != null) {
        final sevenDaysBefore = latestDate.subtract(const Duration(days: 7));
        newIncidentsCount = filtered.where((i) {
          final c = i.currentIncidentCreatedAt;
          return c != null && c.isAfter(sevenDaysBefore);
        }).length;
      } else {
        newIncidentsCount = filtered.where((i) => i.currentIncidentStatus == 1).length;
      }
    }

    // 4. Status Breakdown (using strictly the 7 canonical statuses from enms.dart)
    final statusMap = <String, int>{
      'تم التبليغ': 0,
      'تم الارسال': 0,
      'قيد التنفيذ': 0,
      'قيد الانتظار': 0,
      'قيد المراجعة': 0,
      'تم حلها': 0,
      'تم الرفض': 0,
    };
    for (final i in filtered) {
      final s = i.currentIncidentStatus ?? 1;
      final statusName = getStatusArabic(s);
      statusMap[statusName] = (statusMap[statusName] ?? 0) + 1;
    }

    // 5. Severity Breakdown (1: منخفضة, 2: متوسطة, 3: عالية, 4: حرجة)
    final severityMap = <String, int>{
      'حرجة': 0,
      'عالية': 0,
      'متوسطة': 0,
      'منخفضة': 0,
    };
    for (final i in filtered) {
      switch (i.currentIncidentSeverity) {
        case 4:
          severityMap['حرجة'] = (severityMap['حرجة'] ?? 0) + 1;
          break;
        case 3:
          severityMap['عالية'] = (severityMap['عالية'] ?? 0) + 1;
          break;
        case 2:
          severityMap['متوسطة'] = (severityMap['متوسطة'] ?? 0) + 1;
          break;
        case 1:
        default:
          severityMap['منخفضة'] = (severityMap['منخفضة'] ?? 0) + 1;
          break;
      }
    }

    // 6. Types Breakdown
    final typesMap = <String, int>{};
    for (final i in filtered) {
      final t = (i.currentIncidentTypeName != null &&
              i.currentIncidentTypeName!.trim().isNotEmpty)
          ? i.currentIncidentTypeName!.trim()
          : 'غير محدد';
      typesMap[t] = (typesMap[t] ?? 0) + 1;
    }

    // 7. Branches Breakdown (Strictly Real Data, No Fabrications)
    final branchMapCounts = <String, int>{};
    for (final i in filtered) {
      final b = (i.branchName != null && i.branchName!.trim().isNotEmpty)
          ? i.branchName!.trim()
          : (i.branchId != null ? 'فرع #${i.branchId}' : 'غير محدد');
      branchMapCounts[b] = (branchMapCounts[b] ?? 0) + 1;
    }

    // 8. Honest Trend Data (Chronological aggregation for month / week / day)
    final trendData = _buildHonestTrendData(filtered, _trendPeriod);

    // 9. Mission Statistics
    int totalMissions = 0;
    int completedMissions = 0;
    int inProgressMissions = 0;
    int notStartedMissions = 0;
    int incidentsWithMissions = 0;

    for (final i in filtered) {
      final missions = i.currentIncidentWithMissions;
      if (missions != null && missions.isNotEmpty) {
        incidentsWithMissions++;
        totalMissions += missions.length;
        for (final m in missions) {
          final ms = m.currentIncidentMissionStatus;
          if (ms == 4 || ms == 5 || ms == 6) {
            completedMissions++;
          } else if (ms == 2 || ms == 3) {
            inProgressMissions++;
          } else {
            notStartedMissions++;
          }
        }
      }
    }

    final missionsStats = MissionsReportStats(
      totalMissions: totalMissions,
      completedMissions: completedMissions,
      completedPercentage: totalMissions > 0
          ? (completedMissions / totalMissions) * 100
          : 0.0,
      inProgressMissions: inProgressMissions,
      notStartedMissions: notStartedMissions,
      notStartedPercentage: totalMissions > 0
          ? (notStartedMissions / totalMissions) * 100
          : 0.0,
      avgMissionsPerIncident: total > 0 ? (totalMissions / total) : 0.0,
      incidentsWithMissionsCount: incidentsWithMissions,
    );

    // 10. Data Quality Metrics (Strictly Real Data)
    final withDesc = filtered.where((i) {
      return i.currentIncidentDescription != null &&
          i.currentIncidentDescription!.trim().isNotEmpty;
    }).length;
    final withBranch = filtered.where((i) {
      return (i.branchName != null && i.branchName!.trim().isNotEmpty) ||
          i.branchId != null;
    }).length;
    final withCoords = filtered.where((i) {
      return (i.currentIncidentXAxis != null && i.currentIncidentXAxis != 0) &&
          (i.currentIncidentYAxis != null && i.currentIncidentYAxis != 0);
    }).length;
    final withPhotos = filtered.where((i) {
      return i.photos != null && i.photos!.isNotEmpty;
    }).length;
    final withMissions = incidentsWithMissions;

    final dataQuality = DataQualityStats(
      hasDescriptionCount: withDesc,
      hasDescriptionPercentage: total > 0 ? (withDesc / total) * 100 : 0.0,
      hasBranchCount: withBranch,
      hasBranchPercentage: total > 0 ? (withBranch / total) * 100 : 0.0,
      hasCoordinatesCount: withCoords,
      hasCoordinatesPercentage: total > 0 ? (withCoords / total) * 100 : 0.0,
      hasPhotosCount: withPhotos,
      hasPhotosPercentage: total > 0 ? (withPhotos / total) * 100 : 0.0,
      hasMissionsCount: withMissions,
      hasMissionsPercentage: total > 0 ? (withMissions / total) * 100 : 0.0,
      missingBranchCount: total - withBranch,
      missingCoordinatesCount: total - withCoords,
      total: total,
    );

    // 11. Latest Incidents (sorted by created_at desc)
    final latest = List<CurrentIncidentModel>.from(filtered);
    latest.sort((a, b) {
      final aDate = a.currentIncidentCreatedAt;
      final bDate = b.currentIncidentCreatedAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    final topLatest = latest.take(6).toList();

    // 12. Stale Incidents (active incidents with oldest status update or creation)
    final stale = List<CurrentIncidentModel>.from(
      filtered.where((i) => i.currentIncidentStatus != 5 && i.currentIncidentStatus != 6),
    );
    stale.sort((a, b) {
      final aDate = a.currentIncidentStatusUpdatedAt ?? a.currentIncidentCreatedAt;
      final bDate = b.currentIncidentStatusUpdatedAt ?? b.currentIncidentCreatedAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return -1;
      if (bDate == null) return 1;
      return aDate.compareTo(bDate); // oldest first
    });
    final topStale = stale.take(6).toList();

    emit(ReportsLoaded(
      allIncidents: _allIncidents,
      filteredIncidents: filtered,
      searchQuery: _searchQuery,
      selectedManager: _selectedManager,
      selectedStatus: _selectedStatus,
      selectedSeverity: _selectedSeverity,
      selectedType: _selectedType,
      selectedBranch: _selectedBranchName,
      selectedBranchId: _selectedBranchId,
      startDate: _startDate,
      endDate: _endDate,
      hasPhotos: _hasPhotos,
      hasMissions: _hasMissions,
      hasCoordinates: _hasCoordinates,
      activeTabIndex: _activeTabIndex,
      trendPeriod: _trendPeriod,
      totalIncidents: total,
      activeIncidents: active,
      highSeverityIncidents: highSeverity,
      newIncidents: newIncidentsCount,
      closedIncidents: closed,
      documentedWithPhotos: documentedWithPhotos,
      statusCounts: statusMap,
      severityCounts: severityMap,
      typeCounts: typesMap,
      branchCounts: branchMapCounts,
      trendData: trendData,
      missionsStats: missionsStats,
      dataQuality: dataQuality,
      latestIncidents: topLatest,
      staleIncidents: topStale,
      availableManagers: managersSet.toList()..sort(),
      availableTypes: typesSet.toList()..sort(),
      availableBranches: availableBranchNames,
      branchOptions: branchOptions,
    ));
  }

  /// Constructs genuine chronological trend data points (daily, weekly, or monthly)
  /// without ANY fabricated numbers or fake curves. Zero is zero.
  List<MonthlyTrendPoint> _buildHonestTrendData(
    List<CurrentIncidentModel> incidents,
    String period,
  ) {
    if (period == 'يومي') {
      return _buildDailyTrend(incidents);
    } else if (period == 'أسبوعي') {
      return _buildWeeklyTrend(incidents);
    } else {
      return _buildMonthlyTrend(incidents);
    }
  }

  List<MonthlyTrendPoint> _buildMonthlyTrend(List<CurrentIncidentModel> incidents) {
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final monthlyTotals = List<int>.filled(12, 0);
    final monthlyActive = List<int>.filled(12, 0);
    final monthlyCritical = List<int>.filled(12, 0);

    for (final inc in incidents) {
      final date = inc.currentIncidentCreatedAt;
      if (date != null && date.month >= 1 && date.month <= 12) {
        final mIdx = date.month - 1;
        monthlyTotals[mIdx]++;
        final s = inc.currentIncidentStatus;
        if (s == 1 || s == 2 || s == 3 || s == 4) {
          monthlyActive[mIdx]++;
        }
        if (inc.currentIncidentSeverity == 4) {
          monthlyCritical[mIdx]++;
        }
      }
    }

    return List.generate(12, (index) {
      return MonthlyTrendPoint(
        label: arabicMonths[index],
        total: monthlyTotals[index],
        active: monthlyActive[index],
        critical: monthlyCritical[index],
      );
    });
  }

  List<MonthlyTrendPoint> _buildWeeklyTrend(List<CurrentIncidentModel> incidents) {
    // Determine anchor date: latest incident creation or now
    DateTime anchor = DateTime.now();
    for (final inc in incidents) {
      final d = inc.currentIncidentCreatedAt;
      if (d != null && d.isAfter(anchor)) {
        anchor = d;
      }
    }

    // Generate last 8 weeks
    final points = <MonthlyTrendPoint>[];
    for (int i = 7; i >= 0; i--) {
      final weekStart = anchor.subtract(Duration(days: i * 7 + 6));
      final weekEnd = anchor.subtract(Duration(days: i * 7));

      int total = 0;
      int active = 0;
      int critical = 0;

      for (final inc in incidents) {
        final d = inc.currentIncidentCreatedAt;
        if (d != null) {
          if (!d.isBefore(weekStart) && !d.isAfter(weekEnd.add(const Duration(days: 1)))) {
            total++;
            final s = inc.currentIncidentStatus;
            if (s == 1 || s == 2 || s == 3 || s == 4) active++;
            if (inc.currentIncidentSeverity == 4) critical++;
          }
        }
      }

      points.add(
        MonthlyTrendPoint(
          label: 'أسبوع ${8 - i}',
          total: total,
          active: active,
          critical: critical,
        ),
      );
    }

    return points;
  }

  List<MonthlyTrendPoint> _buildDailyTrend(List<CurrentIncidentModel> incidents) {
    DateTime anchor = DateTime.now();
    for (final inc in incidents) {
      final d = inc.currentIncidentCreatedAt;
      if (d != null && d.isAfter(anchor)) {
        anchor = d;
      }
    }

    final points = <MonthlyTrendPoint>[];
    final dayFormat = DateFormat('MM/dd');

    // Generate last 10 days
    for (int i = 9; i >= 0; i--) {
      final day = anchor.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);

      int total = 0;
      int active = 0;
      int critical = 0;

      for (final inc in incidents) {
        final d = inc.currentIncidentCreatedAt;
        if (d != null && !d.isBefore(dayStart) && !d.isAfter(dayEnd)) {
          total++;
          final s = inc.currentIncidentStatus;
          if (s == 1 || s == 2 || s == 3 || s == 4) active++;
          if (inc.currentIncidentSeverity == 4) critical++;
        }
      }

      points.add(
        MonthlyTrendPoint(
          label: dayFormat.format(day),
          total: total,
          active: active,
          critical: critical,
        ),
      );
    }

    return points;
  }
}
