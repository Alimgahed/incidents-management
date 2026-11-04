import 'package:flutter/material.dart';

class LayerStyle {
  final String name;
  final String arabicTitle;
  final int minZoom;
  final Color color;
  final double width;
  final double radius;
  final Color? fill;
  final Color? border;
  final bool dashed;

  const LayerStyle(
    this.name,
    this.minZoom,
    this.color, {
    required this.arabicTitle,
    this.width = 2,
    this.radius = 5,
    this.fill,
    this.border,
    this.dashed = false,
  });
}

/// Official drawing order (bottom to top) according to GIS Layer API specification.
const List<LayerStyle> gisLayerStack = [
  LayerStyle(
    'districts',
    10,
    Color(0xFF888888),
    arabicTitle: 'المراكز والأحياء',
    width: 2,
    dashed: true,
  ),
  LayerStyle(
    'building',
    17,
    Color(0xFFB9A99A),
    arabicTitle: 'المباني والمنشآت',
    fill: Color(0xFFE3D9CF),
    border: Color(0xFF8C7B6B),
  ),
  LayerStyle(
    'railway',
    12,
    Color(0xFF555555),
    arabicTitle: 'السكك الحديدية',
    width: 2.5,
    dashed: true,
  ),
  LayerStyle(
    'canals',
    13,
    Color(0xFF7AB8E8),
    arabicTitle: 'الترع والمصارف',
    width: 3.5,
  ),
  LayerStyle(
    'street',
    14,
    Color(0xFFFFFFFF),
    arabicTitle: 'الشوارع والطرق',
    width: 4,
    border: Color(0xFFC9C3B8),
  ),
  LayerStyle(
    'pipe',
    15,
    Color(0xFF0077CC),
    arabicTitle: 'خطوط وشبكات المياه',
    width: 3.5,
  ),
  LayerStyle(
    'landmark',
    15,
    Color(0xFF2A8A4A),
    arabicTitle: 'المعالم ونقاط الاهتمام',
    radius: 6,
  ),
  LayerStyle(
    'w_valve',
    16,
    Color(0xFFDD0000),
    arabicTitle: 'محابس المياه',
    radius: 5.5,
  ),
];

LayerStyle getStyleForLayer(String layerName) {
  final match = gisLayerStack.firstWhere(
    (s) => s.name.toLowerCase() == layerName.toLowerCase(),
    orElse: () => LayerStyle(
      layerName,
      12,
      const Color(0xFF0077CC),
      arabicTitle: layerName,
    ),
  );
  return match;
}
