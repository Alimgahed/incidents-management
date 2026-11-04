import 'package:latlong2/latlong.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';

/// Realistic sample GIS data for Minya area when the backend geodatabase is offline or in development.
class GisMockData {
  static final List<GisLayerInfo> defaultLayers = [
    const GisLayerInfo(
      name: 'pipe',
      aliases: ['pipes'],
      geometryType: 'line',
    ),
    const GisLayerInfo(
      name: 'w_valve',
      aliases: ['valves'],
      geometryType: 'point',
    ),
    const GisLayerInfo(
      name: 'street',
      aliases: ['streets', 'roads'],
      geometryType: 'line',
    ),
    const GisLayerInfo(
      name: 'canals',
      aliases: ['waterways'],
      geometryType: 'line',
    ),
    const GisLayerInfo(
      name: 'building',
      aliases: ['buildings'],
      geometryType: 'polygon',
    ),
    const GisLayerInfo(
      name: 'railway',
      aliases: ['railways'],
      geometryType: 'line',
    ),
    const GisLayerInfo(
      name: 'districts',
      aliases: ['admin_districts'],
      geometryType: 'polygon',
    ),
    const GisLayerInfo(
      name: 'landmark',
      aliases: ['poi'],
      geometryType: 'point',
    ),
  ];

  static GisCollection getMockCollection(String layerName) {
    switch (layerName.toLowerCase()) {
      case 'pipe':
        return GisCollection(
          'pipe',
          false,
          [
            GisFeature(
              101,
              {
                'OBJECTID': 101,
                'DIAMETER': 500,
                'MATERIAL': 'حديد زهر مطيل (Ductile)',
                'PRESSURE': '10 bar',
                'INSTALL_YEAR': 2018,
                'STATUS': 'يعمل بكفاءة',
                'NETWORK': 'شبكة مياه المنيا الرئيسية',
              },
              lines: [
                [
                  const LatLng(28.0840, 30.7450),
                  const LatLng(28.0870, 30.7500),
                  const LatLng(28.0900, 30.7550),
                  const LatLng(28.0940, 30.7600),
                ],
              ],
            ),
            GisFeature(
              102,
              {
                'OBJECTID': 102,
                'DIAMETER': 300,
                'MATERIAL': 'بولي إيثيلين عالي الكثافة (HDPE)',
                'PRESSURE': '6 bar',
                'INSTALL_YEAR': 2021,
                'STATUS': 'تحت الصيانة الدورية',
                'NETWORK': 'فرعي حي غرب',
              },
              lines: [
                [
                  const LatLng(28.0870, 30.7500),
                  const LatLng(28.0850, 30.7560),
                  const LatLng(28.0820, 30.7620),
                ],
              ],
            ),
            GisFeature(
              103,
              {
                'OBJECTID': 103,
                'DIAMETER': 200,
                'MATERIAL': 'بولي كلوريد الفينيل (uPVC)',
                'PRESSURE': '4 bar',
                'INSTALL_YEAR': 2015,
                'STATUS': 'يعمل',
                'NETWORK': 'خط كورنيش النيل',
              },
              lines: [
                [
                  const LatLng(28.0900, 30.7550),
                  const LatLng(28.0920, 30.7510),
                  const LatLng(28.0950, 30.7480),
                ],
              ],
            ),
          ],
          count: 3,
        );

      case 'w_valve':
        return GisCollection(
          'w_valve',
          false,
          [
            GisFeature(
              501,
              {
                'OBJECTID': 501,
                'VALVE_TYPE': 'محبس قفل هواء (Air Release)',
                'DIAMETER': 300,
                'STATUS': 'مفتوح بالكامل (Open)',
                'LAST_INSPECTED': '2026-10-15',
                'CHAMBER_CONDITION': 'جيدة ولا توجد تسريبات',
              },
              points: [const LatLng(28.0870, 30.7500)],
            ),
            GisFeature(
              502,
              {
                'OBJECTID': 502,
                'VALVE_TYPE': 'محبس سكاكين رئيسي (Gate Valve)',
                'DIAMETER': 500,
                'STATUS': 'مفتوح (Open)',
                'LAST_INSPECTED': '2026-09-30',
                'CHAMBER_CONDITION': 'تحتاج تنظيف غرفة المحبس',
              },
              points: [const LatLng(28.0900, 30.7550)],
            ),
            GisFeature(
              503,
              {
                'OBJECTID': 503,
                'VALVE_TYPE': 'محبس غسيل وتفريغ (Washout)',
                'DIAMETER': 200,
                'STATUS': 'مغلق (Closed)',
                'LAST_INSPECTED': '2026-10-28',
                'CHAMBER_CONDITION': 'ممتازة',
              },
              points: [const LatLng(28.0850, 30.7560)],
            ),
          ],
          count: 3,
        );

      case 'canals':
        return GisCollection(
          'canals',
          false,
          [
            GisFeature(
              201,
              {
                'OBJECTID': 201,
                'NAME': 'ترعة الإبراهيمية',
                'WIDTH_M': 25,
                'FLOW_TYPE': 'مجرى مائي رئيسي',
              },
              lines: [
                [
                  const LatLng(28.0750, 30.7400),
                  const LatLng(28.0820, 30.7430),
                  const LatLng(28.0890, 30.7460),
                  const LatLng(28.0960, 30.7490),
                  const LatLng(28.1030, 30.7520),
                ],
              ],
            ),
          ],
          count: 1,
        );

      case 'railway':
        return GisCollection(
          'railway',
          false,
          [
            GisFeature(
              301,
              {
                'OBJECTID': 301,
                'LINE': 'خط سكك حديد الصعيد (القاهرة - أسوان)',
                'TRACKS': 2,
              },
              lines: [
                [
                  const LatLng(28.0750, 30.7420),
                  const LatLng(28.0830, 30.7450),
                  const LatLng(28.0910, 30.7480),
                  const LatLng(28.0990, 30.7510),
                ],
              ],
            ),
          ],
          count: 1,
        );

      case 'street':
        return GisCollection(
          'street',
          false,
          [
            GisFeature(
              401,
              {
                'OBJECTID': 401,
                'STREET_NAME': 'شارع كورنيش النيل',
                'LANES': 4,
                'PAVEMENT_TYPE': 'أسفلت ممتاز',
              },
              lines: [
                [
                  const LatLng(28.0800, 30.7580),
                  const LatLng(28.0870, 30.7600),
                  const LatLng(28.0940, 30.7620),
                ],
              ],
            ),
            GisFeature(
              402,
              {
                'OBJECTID': 402,
                'STREET_NAME': 'شارع الجمهورية / المحطة',
                'LANES': 2,
                'PAVEMENT_TYPE': 'أسفلت',
              },
              lines: [
                [
                  const LatLng(28.0870, 30.7460),
                  const LatLng(28.0870, 30.7530),
                  const LatLng(28.0870, 30.7600),
                ],
              ],
            ),
          ],
          count: 2,
        );

      case 'building':
        return GisCollection(
          'building',
          false,
          [
            GisFeature(
              601,
              {
                'OBJECTID': 601,
                'NAME': 'محطة مياه المنيا الرئيسية (المرشحة)',
                'TYPE': 'منشأة مياه حكومية',
                'CAPACITY': '120,000 م3/يوم',
              },
              polygons: [
                [
                  [
                    const LatLng(28.0860, 30.7510),
                    const LatLng(28.0880, 30.7510),
                    const LatLng(28.0880, 30.7535),
                    const LatLng(28.0860, 30.7535),
                    const LatLng(28.0860, 30.7510),
                  ],
                ],
              ],
            ),
            GisFeature(
              602,
              {
                'OBJECTID': 602,
                'NAME': 'مبنى ديوان عام شركة مياه الشرب والصرف الصحي',
                'TYPE': 'إداري',
              },
              polygons: [
                [
                  [
                    const LatLng(28.0890, 30.7520),
                    const LatLng(28.0910, 30.7520),
                    const LatLng(28.0910, 30.7540),
                    const LatLng(28.0890, 30.7540),
                    const LatLng(28.0890, 30.7520),
                  ],
                ],
              ],
            ),
          ],
          count: 2,
        );

      case 'districts':
        return GisCollection(
          'districts',
          false,
          [
            GisFeature(
              701,
              {
                'OBJECTID': 701,
                'DISTRICT_NAME': 'حي شمال المنيا',
                'POPULATION': 185000,
              },
              polygons: [
                [
                  [
                    const LatLng(28.0850, 30.7350),
                    const LatLng(28.1050, 30.7350),
                    const LatLng(28.1050, 30.7700),
                    const LatLng(28.0850, 30.7700),
                    const LatLng(28.0850, 30.7350),
                  ],
                ],
              ],
            ),
          ],
          count: 1,
        );

      case 'landmark':
        return GisCollection(
          'landmark',
          false,
          [
            GisFeature(
              801,
              {
                'OBJECTID': 801,
                'NAME': 'ميدان المحطة - المنيا',
                'CATEGORY': 'ميدان عام ومحور مواصلات',
              },
              points: [const LatLng(28.0872, 30.7455)],
            ),
            GisFeature(
              802,
              {
                'OBJECTID': 802,
                'NAME': 'خزان مياه المنيا العالي',
                'CATEGORY': 'برج تخزين مياه',
                'HEIGHT_M': 45,
              },
              points: [const LatLng(28.0895, 30.7530)],
            ),
          ],
          count: 2,
        );

      default:
        return GisCollection.empty;
    }
  }
}
