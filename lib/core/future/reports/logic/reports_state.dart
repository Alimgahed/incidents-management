import 'package:equatable/equatable.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class BranchOption extends Equatable {
  final int? id;
  final String name;

  const BranchOption({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class MonthlyTrendPoint extends Equatable {
  final String label; // e.g. "يناير" or "أسبوع 42" or "21 أكتوبر"
  final int total;
  final int active;
  final int critical;

  const MonthlyTrendPoint({
    required this.label,
    required this.total,
    required this.active,
    required this.critical,
  });

  @override
  List<Object?> get props => [label, total, active, critical];
}

class MissionsReportStats extends Equatable {
  final int totalMissions;
  final int completedMissions;
  final double completedPercentage;
  final int inProgressMissions;
  final int notStartedMissions;
  final double notStartedPercentage;
  final double avgMissionsPerIncident;
  final int incidentsWithMissionsCount;

  const MissionsReportStats({
    required this.totalMissions,
    required this.completedMissions,
    required this.completedPercentage,
    required this.inProgressMissions,
    required this.notStartedMissions,
    required this.notStartedPercentage,
    required this.avgMissionsPerIncident,
    this.incidentsWithMissionsCount = 0,
  });

  @override
  List<Object?> get props => [
        totalMissions,
        completedMissions,
        completedPercentage,
        inProgressMissions,
        notStartedMissions,
        notStartedPercentage,
        avgMissionsPerIncident,
        incidentsWithMissionsCount,
      ];
}

class DataQualityStats extends Equatable {
  final int hasDescriptionCount;
  final double hasDescriptionPercentage;
  final int hasBranchCount;
  final double hasBranchPercentage;
  final int hasCoordinatesCount;
  final double hasCoordinatesPercentage;
  final int hasPhotosCount;
  final double hasPhotosPercentage;
  final int hasMissionsCount;
  final double hasMissionsPercentage;
  final int missingBranchCount;
  final int missingCoordinatesCount;
  final int total;

  const DataQualityStats({
    required this.hasDescriptionCount,
    required this.hasDescriptionPercentage,
    required this.hasBranchCount,
    required this.hasBranchPercentage,
    required this.hasCoordinatesCount,
    required this.hasCoordinatesPercentage,
    required this.hasPhotosCount,
    required this.hasPhotosPercentage,
    required this.hasMissionsCount,
    required this.hasMissionsPercentage,
    this.missingBranchCount = 0,
    this.missingCoordinatesCount = 0,
    required this.total,
  });

  @override
  List<Object?> get props => [
        hasDescriptionCount,
        hasDescriptionPercentage,
        hasBranchCount,
        hasBranchPercentage,
        hasCoordinatesCount,
        hasCoordinatesPercentage,
        hasPhotosCount,
        hasPhotosPercentage,
        hasMissionsCount,
        hasMissionsPercentage,
        missingBranchCount,
        missingCoordinatesCount,
        total,
      ];
}

class ReportsLoaded extends ReportsState {
  final List<CurrentIncidentModel> allIncidents;
  final List<CurrentIncidentModel> filteredIncidents;

  // Filter criteria
  final String searchQuery;
  final String? selectedManager;
  final int? selectedStatus;
  final int? selectedSeverity;
  final String? selectedType;
  final String? selectedBranch;
  final int? selectedBranchId;
  final DateTime? startDate;
  final DateTime? endDate;

  // Extra toggle filters
  final bool? hasPhotos;
  final bool? hasMissions;
  final bool? hasCoordinates;

  // Tab & period selection
  final int activeTabIndex;
  final String trendPeriod; // 'شهري', 'أسبوعي', 'يومي'

  // Computed metrics
  final int totalIncidents;
  final int activeIncidents;
  final int highSeverityIncidents;
  final int newIncidents;
  final int closedIncidents;
  final int documentedWithPhotos;

  final Map<String, int> statusCounts;
  final Map<String, int> severityCounts;
  final Map<String, int> typeCounts;
  final Map<String, int> branchCounts;

  final List<MonthlyTrendPoint> trendData;
  final MissionsReportStats missionsStats;
  final DataQualityStats dataQuality;
  final List<CurrentIncidentModel> latestIncidents;
  final List<CurrentIncidentModel> staleIncidents;

  final List<String> availableManagers;
  final List<String> availableTypes;
  final List<String> availableBranches;
  final List<BranchOption> branchOptions;

  const ReportsLoaded({
    required this.allIncidents,
    required this.filteredIncidents,
    this.searchQuery = '',
    this.selectedManager,
    this.selectedStatus,
    this.selectedSeverity,
    this.selectedType,
    this.selectedBranch,
    this.selectedBranchId,
    this.startDate,
    this.endDate,
    this.hasPhotos,
    this.hasMissions,
    this.hasCoordinates,
    this.activeTabIndex = 0,
    this.trendPeriod = 'شهري',
    required this.totalIncidents,
    required this.activeIncidents,
    required this.highSeverityIncidents,
    required this.newIncidents,
    required this.closedIncidents,
    required this.documentedWithPhotos,
    required this.statusCounts,
    required this.severityCounts,
    required this.typeCounts,
    required this.branchCounts,
    required this.trendData,
    required this.missionsStats,
    required this.dataQuality,
    required this.latestIncidents,
    required this.staleIncidents,
    required this.availableManagers,
    required this.availableTypes,
    required this.availableBranches,
    this.branchOptions = const [],
  });

  ReportsLoaded copyWith({
    List<CurrentIncidentModel>? allIncidents,
    List<CurrentIncidentModel>? filteredIncidents,
    String? searchQuery,
    String? selectedManager,
    bool clearManager = false,
    int? selectedStatus,
    bool clearStatus = false,
    int? selectedSeverity,
    bool clearSeverity = false,
    String? selectedType,
    bool clearType = false,
    String? selectedBranch,
    bool clearBranch = false,
    int? selectedBranchId,
    bool clearBranchId = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? hasPhotos,
    bool clearHasPhotos = false,
    bool? hasMissions,
    bool clearHasMissions = false,
    bool? hasCoordinates,
    bool clearHasCoordinates = false,
    int? activeTabIndex,
    String? trendPeriod,
    int? totalIncidents,
    int? activeIncidents,
    int? highSeverityIncidents,
    int? newIncidents,
    int? closedIncidents,
    int? documentedWithPhotos,
    Map<String, int>? statusCounts,
    Map<String, int>? severityCounts,
    Map<String, int>? typeCounts,
    Map<String, int>? branchCounts,
    List<MonthlyTrendPoint>? trendData,
    MissionsReportStats? missionsStats,
    DataQualityStats? dataQuality,
    List<CurrentIncidentModel>? latestIncidents,
    List<CurrentIncidentModel>? staleIncidents,
    List<String>? availableManagers,
    List<String>? availableTypes,
    List<String>? availableBranches,
    List<BranchOption>? branchOptions,
  }) {
    return ReportsLoaded(
      allIncidents: allIncidents ?? this.allIncidents,
      filteredIncidents: filteredIncidents ?? this.filteredIncidents,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedManager:
          clearManager ? null : (selectedManager ?? this.selectedManager),
      selectedStatus:
          clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedSeverity:
          clearSeverity ? null : (selectedSeverity ?? this.selectedSeverity),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedBranch:
          clearBranch ? null : (selectedBranch ?? this.selectedBranch),
      selectedBranchId:
          clearBranchId ? null : (selectedBranchId ?? this.selectedBranchId),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      hasPhotos: clearHasPhotos ? null : (hasPhotos ?? this.hasPhotos),
      hasMissions: clearHasMissions ? null : (hasMissions ?? this.hasMissions),
      hasCoordinates:
          clearHasCoordinates ? null : (hasCoordinates ?? this.hasCoordinates),
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      trendPeriod: trendPeriod ?? this.trendPeriod,
      totalIncidents: totalIncidents ?? this.totalIncidents,
      activeIncidents: activeIncidents ?? this.activeIncidents,
      highSeverityIncidents:
          highSeverityIncidents ?? this.highSeverityIncidents,
      newIncidents: newIncidents ?? this.newIncidents,
      closedIncidents: closedIncidents ?? this.closedIncidents,
      documentedWithPhotos:
          documentedWithPhotos ?? this.documentedWithPhotos,
      statusCounts: statusCounts ?? this.statusCounts,
      severityCounts: severityCounts ?? this.severityCounts,
      typeCounts: typeCounts ?? this.typeCounts,
      branchCounts: branchCounts ?? this.branchCounts,
      trendData: trendData ?? this.trendData,
      missionsStats: missionsStats ?? this.missionsStats,
      dataQuality: dataQuality ?? this.dataQuality,
      latestIncidents: latestIncidents ?? this.latestIncidents,
      staleIncidents: staleIncidents ?? this.staleIncidents,
      availableManagers: availableManagers ?? this.availableManagers,
      availableTypes: availableTypes ?? this.availableTypes,
      availableBranches: availableBranches ?? this.availableBranches,
      branchOptions: branchOptions ?? this.branchOptions,
    );
  }

  @override
  List<Object?> get props => [
        allIncidents,
        filteredIncidents,
        searchQuery,
        selectedManager,
        selectedStatus,
        selectedSeverity,
        selectedType,
        selectedBranch,
        selectedBranchId,
        startDate,
        endDate,
        hasPhotos,
        hasMissions,
        hasCoordinates,
        activeTabIndex,
        trendPeriod,
        totalIncidents,
        activeIncidents,
        highSeverityIncidents,
        newIncidents,
        closedIncidents,
        documentedWithPhotos,
        statusCounts,
        severityCounts,
        typeCounts,
        branchCounts,
        trendData,
        missionsStats,
        dataQuality,
        latestIncidents,
        staleIncidents,
        availableManagers,
        availableTypes,
        availableBranches,
        branchOptions,
      ];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
