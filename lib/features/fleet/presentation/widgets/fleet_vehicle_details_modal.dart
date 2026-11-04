import 'package:flutter/material.dart';
import '../../../valves_map/models/etit_vehicle_model.dart';
import '../../core/theme/fleet_design_system.dart';

/// Displays a comprehensive modal dialog containing every single parsed and raw
/// field returned by the ETIT backend for a vehicle.
void showFleetVehicleDetailsModal(BuildContext context, EtitVehicleModel v) {
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
    MapEntry(
      'توقيت آخر تحديث (lastUpdate)',
      FleetDateFormatter.formatArabicTimestamp(v.lastUpdate),
    ),
    MapEntry('التوقيت الخام (Raw Timestamp)', v.lastUpdate ?? '-'),
    MapEntry('رقم جهاز التتبع IMEI (deviceCode)', v.deviceCode ?? '-'),
    MapEntry('الشركة المصنعة للجهاز (Vendor_Name)', v.vendorName ?? '-'),
    MapEntry('مزود شريحة الاتصال (providerName)', v.providerName ?? '-'),
    MapEntry(
      'رقم الشاسيه (ChassisNumber)',
      (v.chassisNumber ?? '').isNotEmpty ? v.chassisNumber! : 'غير مسجل',
    ),
    MapEntry('خاضعة للمراقبة (isMonitored)', v.isMonitored ? 'نعم' : 'لا'),
  ];

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FleetRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: FleetColors.primaryNavy,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(FleetRadius.xl),
                ),
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
                    const Divider(height: 1, color: FleetColors.borderLight),
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
                              color: FleetColors.textSecondary,
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
                              color: FleetColors.textPrimary,
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
