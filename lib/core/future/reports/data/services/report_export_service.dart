import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'export_platform_interface.dart';
import 'export_platform_stub.dart'
    if (dart.library.html) 'export_platform_web.dart'
    if (dart.library.io) 'export_platform_io.dart';

class ReportExportService {
  final ExportPlatformHelper _platformHelper;

  ReportExportService({ExportPlatformHelper? platformHelper})
      : _platformHelper = platformHelper ?? getExportPlatformHelper();

  /// Exports incidents to a CSV file encoded in UTF-8 with BOM for Excel compatibility.
  Future<String> exportIncidentsToCsv({
    required List<CurrentIncidentModel> incidents,
    String? customFileName,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final nowStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = customFileName ?? 'تقرير_الأزمات_$nowStr.csv';

    final csvBuffer = StringBuffer();

    // 1. Column Headers in Arabic
    final headers = [
      'معرف الأزمة',
      'نوع الأزمة',
      'الفرع',
      'مستوى الخطورة',
      'حالة الأزمة',
      'تاريخ الإنشاء',
      'تاريخ آخر تحديث للحالة',
      'تاريخ آخر تحديث للخطورة',
      'المسؤول / المدير',
      'منشئ البلاغ',
      'العنوان',
      'عدد الصور المرفقة',
      'عدد المهام',
      'حالات المهام',
      'خط العرض (X)',
      'خط الطول (Y)',
      'الوصف',
      'ملاحظات إضافية',
    ];

    csvBuffer.writeln(headers.map(_escapeCsv).join(','));

    // 2. Data Rows
    for (final inc in incidents) {
      final severityText = inc.severityName ??
          (inc.currentIncidentSeverity != null
              ? getSeverityArabic(inc.currentIncidentSeverity!)
              : 'غير محدد');

      final statusText = inc.statusName ??
          (inc.currentIncidentStatus != null
              ? getStatusArabic(inc.currentIncidentStatus!)
              : 'غير محدد');

      final branchText = (inc.branchName != null && inc.branchName!.trim().isNotEmpty)
          ? inc.branchName!.trim()
          : (inc.branchId != null ? 'فرع #${inc.branchId}' : 'غير محدد');

      final createdStr = inc.currentIncidentCreatedAt != null
          ? dateFormat.format(inc.currentIncidentCreatedAt!)
          : 'غير متوفر';

      final statusUpdatedStr = inc.currentIncidentStatusUpdatedAt != null
          ? dateFormat.format(inc.currentIncidentStatusUpdatedAt!)
          : '';

      final severityUpdatedStr = inc.currentIncidentSeverityUpdateAt != null
          ? dateFormat.format(inc.currentIncidentSeverityUpdateAt!)
          : '';

      final managerText = inc.managerName?.trim() ?? '';
      final creatorText = inc.username?.trim() ?? '';
      final addressText = inc.address?.trim() ?? '';
      final photosCount = inc.photos?.length ?? 0;

      final missions = inc.currentIncidentWithMissions ?? [];
      final missionsCount = missions.length;
      final missionsSummary = missions.isEmpty
          ? 'لا توجد مهام'
          : missions
              .map((m) =>
                  '${m.missionName ?? "مهمة"}: ${getStatusArabic(m.currentIncidentMissionStatus ?? 1)}')
              .join(' | ');

      final latStr = inc.currentIncidentXAxis?.toString() ?? '';
      final lngStr = inc.currentIncidentYAxis?.toString() ?? '';
      final descText = inc.currentIncidentDescription?.trim() ?? '';
      final notesText = inc.currentIncidentNotes?.trim() ?? '';

      final row = [
        inc.currentIncidentId?.toString() ?? '',
        inc.currentIncidentTypeName ?? 'غير محدد',
        branchText,
        severityText,
        statusText,
        createdStr,
        statusUpdatedStr,
        severityUpdatedStr,
        managerText,
        creatorText,
        addressText,
        photosCount.toString(),
        missionsCount.toString(),
        missionsSummary,
        latStr,
        lngStr,
        descText,
        notesText,
      ];

      csvBuffer.writeln(row.map(_escapeCsv).join(','));
    }

    // 3. UTF-8 BOM bytes (0xEF, 0xBB, 0xBF) so Excel correctly recognizes Arabic encoding
    final utf8Bytes = utf8.encode(csvBuffer.toString());
    final bytesWithBom = <int>[0xEF, 0xBB, 0xBF, ...utf8Bytes];

    return await _platformHelper.saveAndDownloadFile(
      bytes: bytesWithBom,
      filename: fileName,
      mimeType: 'text/csv;charset=utf-8',
    );
  }

  String _escapeCsv(dynamic value) {
    if (value == null) return '""';
    final str = value.toString();
    if (str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return '"$str"';
  }
}
