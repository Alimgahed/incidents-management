import 'package:flutter/material.dart';

class LayerStyle {
  final String name;
  final List<String> aliases;
  final String category; // basemap | water_network | wastewater_network | operations
  final String arabicTitle;
  final int minZoom;
  final Color color;
  final double width;
  final double radius;
  final Color? fill;
  final Color? border;
  final bool dashed;
  final IconData? icon;

  const LayerStyle(
    this.name,
    this.minZoom,
    this.color, {
    this.aliases = const [],
    this.category = 'basemap',
    required this.arabicTitle,
    this.width = 2,
    this.radius = 5,
    this.fill,
    this.border,
    this.dashed = false,
    this.icon,
  });
}

/// Official drawing order (bottom to top) for the full GIS Base Map & Network Layers
const List<LayerStyle> gisLayerStack = [
  // 1. Administrative Boundaries (Base Map Polygons)
  LayerStyle(
    'governorates',
    8,
    Color(0xFF9E9E9E),
    aliases: ['governorate'],
    category: 'basemap',
    arabicTitle: 'حدود المحافظة',
    width: 2.5,
    fill: Color(0x10000000),
    border: Color(0xFF757575),
    dashed: true,
  ),
  LayerStyle(
    'districts',
    10,
    Color(0xFF78909C),
    aliases: ['district', 'admin_districts'],
    category: 'basemap',
    arabicTitle: 'المراكز والمدن الإدارية',
    width: 2,
    fill: Color(0x1437474F),
    border: Color(0xFF607D8B),
    dashed: true,
  ),
  LayerStyle(
    'urban_areas',
    12,
    Color(0xFFCFD8DC),
    aliases: ['urban'],
    category: 'basemap',
    arabicTitle: 'الحيز العمراني والكتل السكنية',
    width: 1.5,
    fill: Color(0x28B0BEC5),
    border: Color(0xFF90A4AE),
  ),
  LayerStyle(
    'sections',
    14,
    Color(0xFFBDBDBD),
    aliases: ['section', 'blocks'],
    category: 'basemap',
    arabicTitle: 'الأقسام والمربعات التخطيطية',
    width: 1,
    fill: Color(0x0A000000),
    border: Color(0xFFBDBDBD),
    dashed: true,
  ),

  // 2. Green Areas & Natural Features
  LayerStyle(
    'green_areas',
    13,
    Color(0xFF4CAF50),
    aliases: ['parks', 'gardens'],
    category: 'basemap',
    arabicTitle: 'المناطق الخضراء والحدائق',
    width: 1,
    fill: Color(0x40A5D6A7),
    border: Color(0xFF66BB6A),
  ),

  // 3. Water Bodies & Canals
  LayerStyle(
    'water_bodies',
    10,
    Color(0xFF1976D2),
    aliases: ['nile', 'river'],
    category: 'basemap',
    arabicTitle: 'نهر النيل والمسطحات المائية',
    width: 1.5,
    fill: Color(0x8090CAF9),
    border: Color(0xFF2196F3),
  ),
  LayerStyle(
    'canals',
    12,
    Color(0xFF0288D1),
    aliases: ['canal', 'waterways'],
    category: 'basemap',
    arabicTitle: 'الترع والمجاري المائية',
    width: 3.5,
    border: Color(0xFF01579B),
  ),
  LayerStyle(
    'drains',
    13,
    Color(0xFF0097A7),
    aliases: ['drain'],
    category: 'basemap',
    arabicTitle: 'المصارف المائية',
    width: 2.5,
    dashed: true,
  ),

  // 4. Buildings & Facility Footprints (Base Map)
  LayerStyle(
    'buildings',
    15,
    Color(0xFFD7CCC8),
    aliases: ['building', 'facilities'],
    category: 'basemap',
    arabicTitle: 'المباني والمنشآت',
    width: 1.5,
    fill: Color(0xFFEFEBE9),
    border: Color(0xFFA1887F),
  ),
  LayerStyle(
    'company_sites',
    13,
    Color(0xFF0D47A1),
    aliases: ['branches_sites'],
    category: 'basemap',
    arabicTitle: 'مقرات ومواقع شركة المياه',
    width: 2,
    fill: Color(0x331976D2),
    border: Color(0xFF0D47A1),
  ),

  // 5. Transportation Network (Streets, Railways, Bridges)
  LayerStyle(
    'railways',
    12,
    Color(0xFF424242),
    aliases: ['railway'],
    category: 'basemap',
    arabicTitle: 'السكك الحديدية',
    width: 3,
    dashed: true,
  ),
  LayerStyle(
    'streets',
    13,
    Color(0xFFFFFFFF),
    aliases: ['street', 'roads'],
    category: 'basemap',
    arabicTitle: 'شبكة الشوارع والطرق',
    width: 4.5,
    border: Color(0xFFBDBDBD),
  ),
  LayerStyle(
    'bridges',
    13,
    Color(0xFFE65100),
    aliases: ['bridge'],
    category: 'basemap',
    arabicTitle: 'الكباري والجسور النيلية',
    radius: 6,
    icon: Icons.alt_route_rounded,
  ),

  // 6. Wastewater Network (Sewer Gravity Lines, Force Mains, Manholes, Lift Stations)
  LayerStyle(
    'sewer_gravity_lines',
    14,
    Color(0xFF795548),
    aliases: ['sewer_pipes', 'sewers', 'collect_sewer'],
    category: 'wastewater_network',
    arabicTitle: 'خطوط وشبكات انحدار الصرف',
    width: 3.5,
    dashed: true,
  ),
  LayerStyle(
    'sewer_force_mains',
    13,
    Color(0xFF4E342E),
    aliases: ['force_mains', 'force_main'],
    category: 'wastewater_network',
    arabicTitle: 'خطوط طرد الصرف الصحي',
    width: 4,
  ),
  LayerStyle(
    'sewer_manholes',
    16,
    Color(0xFF8D6E63),
    aliases: ['manholes', 'manhole', 'collector_manhole'],
    category: 'wastewater_network',
    arabicTitle: 'مطابق وغرف الصرف الصحي',
    radius: 4.5,
    icon: Icons.adjust_rounded,
  ),
  LayerStyle(
    'sewer_lift_stations',
    12,
    Color(0xFF6D4C41),
    aliases: ['lift_stations', 'lift_st', 'spump'],
    category: 'wastewater_network',
    arabicTitle: 'محطات رفع الصرف الصحي',
    radius: 7,
    icon: Icons.upload_rounded,
  ),
  LayerStyle(
    'wastewater_treatment_plants',
    11,
    Color(0xFF3E2723),
    aliases: ['wwtp'],
    category: 'wastewater_network',
    arabicTitle: 'محطات معالجة الصرف الصحي',
    radius: 8.5,
    icon: Icons.recycling_rounded,
  ),

  // 7. Drinking Water Network (Pipes, Valves, Tanks, Plants, Hydrants, Wells)
  LayerStyle(
    'water_pipes',
    14,
    Color(0xFF0277BD),
    aliases: ['pipe', 'pipes', 'water_network'],
    category: 'water_network',
    arabicTitle: 'خطوط وشبكات مياه الشرب',
    width: 3.5,
    border: Color(0xFF01579B),
  ),
  LayerStyle(
    'water_valves',
    15,
    Color(0xFFD32F2F),
    aliases: ['valves', 'valve', 'w_valve'],
    category: 'water_network',
    arabicTitle: 'محابس مياه الشرب',
    radius: 5.5,
    icon: Icons.radio_button_checked_rounded,
  ),
  LayerStyle(
    'valve_chambers',
    15,
    Color(0xFFC2185B),
    aliases: ['chambers'],
    category: 'water_network',
    arabicTitle: 'غرف محابس المياه',
    radius: 5,
  ),
  LayerStyle(
    'water_treatment_plants',
    11,
    Color(0xFF00695C),
    aliases: ['wtp', 'plants'],
    category: 'water_network',
    arabicTitle: 'محطات تنقية مياه الشرب',
    radius: 9,
    icon: Icons.water_drop_rounded,
  ),
  LayerStyle(
    'compact_treatment_plants',
    13,
    Color(0xFF00897B),
    aliases: ['compact_tp'],
    category: 'water_network',
    arabicTitle: 'محطات المياه المدمجة',
    radius: 7,
  ),
  LayerStyle(
    'water_storage_tanks',
    13,
    Color(0xFF1565C0),
    aliases: ['tanks', 'tank'],
    category: 'water_network',
    arabicTitle: 'خزانات المياه الاستراتيجية',
    radius: 7.5,
    icon: Icons.storage_rounded,
  ),
  LayerStyle(
    'water_pump_stations',
    13,
    Color(0xFF2E7D32),
    aliases: ['pump_stations', 'pumps'],
    category: 'water_network',
    arabicTitle: 'روافع ومحطات طلمبات المياه',
    radius: 7,
  ),
  LayerStyle(
    'groundwater_wells',
    14,
    Color(0xFF00838F),
    aliases: ['wells', 'well'],
    category: 'water_network',
    arabicTitle: 'الآبار الارتوازية ومحطات الآبار',
    radius: 6,
  ),
  LayerStyle(
    'fire_hydrants',
    16,
    Color(0xFFE53935),
    aliases: ['hydrant', 'hydrants'],
    category: 'water_network',
    arabicTitle: 'حنفيات حريق مياه الشرب',
    radius: 5,
  ),
  LayerStyle(
    'water_meters',
    15,
    Color(0xFF5E35B1),
    aliases: ['meters', 'meter'],
    category: 'water_network',
    arabicTitle: 'عدادات التدفق والقياس',
    radius: 5,
  ),

  // 8. Landmarks & POIs (Overlay Labels)
  LayerStyle(
    'landmarks',
    14,
    Color(0xFF2E7D32),
    aliases: ['landmark', 'poi'],
    category: 'basemap',
    arabicTitle: 'المعالم البارزة ونقاط الاهتمام',
    radius: 6.5,
    icon: Icons.place_rounded,
  ),

  // 9. Operations, Pipe Breaks & Leaks
  LayerStyle(
    'pipe_breaks',
    11,
    Color(0xFFB71C1C),
    aliases: ['breaks', 'break'],
    category: 'operations',
    arabicTitle: 'بلاغات وأعطال وكسور الشبكات',
    radius: 8,
    icon: Icons.warning_amber_rounded,
  ),
  LayerStyle(
    'water_leaks',
    13,
    Color(0xFFFF8F00),
    aliases: ['leakage', 'leaks'],
    category: 'operations',
    arabicTitle: 'نقاط ومسوح التسريب الجوفي',
    radius: 6,
    icon: Icons.opacity_rounded,
  ),
  LayerStyle(
    'scada_sensors',
    13,
    Color(0xFF6A1B9A),
    aliases: ['scada'],
    category: 'operations',
    arabicTitle: 'حساسات المراقبة والإسكادا',
    radius: 5.5,
    icon: Icons.sensors_rounded,
  ),
  LayerStyle(
    'dma_zones',
    12,
    Color(0xFF3949AB),
    aliases: ['dma'],
    category: 'operations',
    arabicTitle: 'مناطق القياس المنعزلة (DMA)',
    width: 2,
    fill: Color(0x1A3F51B5),
    border: Color(0xFF303F9F),
    dashed: true,
  ),
];

LayerStyle getStyleForLayer(String layerName) {
  final cleanName = layerName.toLowerCase().trim();
  for (final style in gisLayerStack) {
    if (style.name.toLowerCase() == cleanName ||
        style.aliases.any((a) => a.toLowerCase() == cleanName)) {
      return style;
    }
  }
  return LayerStyle(
    layerName,
    12,
    const Color(0xFF0077CC),
    arabicTitle: layerName,
  );
}
