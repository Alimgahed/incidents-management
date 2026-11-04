import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';
import 'package:incidents_managment/core/future/gis/models/gis_style_config.dart';

class GisFeatureDetailsSheet extends StatelessWidget {
  final GisFeature feature;
  final String layerName;
  final ValueChanged<Map<String, dynamic>>? onAttachToIncident;

  const GisFeatureDetailsSheet({
    super.key,
    required this.feature,
    required this.layerName,
    this.onAttachToIncident,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleForLayer(layerName);
    final center = feature.center;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.70,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Layer Name + OBJECTID
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: style.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.arabicTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'اسم الطبقة: $layerName',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                if (feature.id != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      'ID: #${feature.id}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Feature properties list
            Expanded(
              child: feature.props.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد خصائص إضافية لهذا العنصر',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: feature.props.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final key = feature.props.keys.elementAt(index);
                        final val = feature.props[key];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  key,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  val?.toString() ?? '—',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            // Coordinates preview if available
            if (center != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الإحداثيات: ${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      tooltip: 'نسخ الإحداثيات',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: '${center.latitude}, ${center.longitude}',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم نسخ الإحداثيات إلى الحافظة',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Action button: Attach to Incident / Return selection
            ElevatedButton.icon(
              onPressed: () {
                final payload = {
                  'layer': layerName,
                  'id': feature.id,
                  'lat': center?.latitude,
                  'lon': center?.longitude,
                  'properties': feature.props,
                };

                if (onAttachToIncident != null) {
                  onAttachToIncident!(payload);
                }

                Navigator.of(context).pop(payload);
              },
              icon: const Icon(Icons.link_rounded, color: Colors.white),
              label: const Text(
                'ربط هذا العنصر بالبلاغ / الأزمة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
