import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_cubit.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_state.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';
import 'package:incidents_managment/core/future/gis/models/gis_style_config.dart';

class GisLayerControlDrawer extends StatelessWidget {
  const GisLayerControlDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GisCubit, GisState>(
      builder: (context, state) {
        final cubit = context.read<GisCubit>();

        // If availableLayers from server is empty, build layer list from gisLayerStack catalog
        final allLayers = state.availableLayers.isNotEmpty
            ? state.availableLayers
            : gisLayerStack.map((s) => GisLayerInfo(
                name: s.name,
                aliases: s.aliases,
                geometryType: s.radius > 5 ? 'point' : (s.width > 2 ? 'line' : 'polygon'),
                category: s.category,
                titleAr: s.arabicTitle,
                minZoom: s.minZoom,
                defaultEnabled: true,
              )).toList();

        final hasLayers = allLayers.isNotEmpty;

        // Apply category filter
        final filteredLayers = allLayers.where((l) {
          if (state.activeCategoryFilter == 'all') return true;
          return l.category.toLowerCase() == state.activeCategoryFilter.toLowerCase();
        }).toList();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F3B6C),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.layers_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'إدارة طبقات خريطة الـ GIS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // OSM Auxiliary Toggle (Disabled by default, Native GIS base map is primary)
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: state.useOsm ? const Color(0xFF0284C7) : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'خريطة OpenStreetMap المساعدة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                'خريطة أساس GIS المتجهة هي الأساسية تلقائياً',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.grey,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: state.useOsm,
                          activeThumbColor: const Color(0xFF0284C7),
                          activeTrackColor:
                              const Color(0xFF0284C7).withValues(alpha: 0.35),
                          onChanged: (val) => cubit.toggleOsm(val),
                        ),
                      ],
                    ),
                  ),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'الكل', state.activeCategoryFilter, cubit),
                        const SizedBox(width: 6),
                        _buildFilterChip('basemap', 'خريطة الأساس', state.activeCategoryFilter, cubit),
                        const SizedBox(width: 6),
                        _buildFilterChip('water_network', 'مياه الشرب', state.activeCategoryFilter, cubit),
                        const SizedBox(width: 6),
                        _buildFilterChip('wastewater_network', 'الصرف الصحي', state.activeCategoryFilter, cubit),
                        const SizedBox(width: 6),
                        _buildFilterChip('operations', 'الطوارئ والتشغيل', state.activeCategoryFilter, cubit),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Quick actions counter & Select All
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الطبقات المفعلة (${state.enabledLayers.length}/${allLayers.length})',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        if (hasLayers)
                          TextButton(
                            onPressed: () {
                              for (final l in filteredLayers) {
                                if (!state.enabledLayers.contains(l.name)) {
                                  cubit.toggleLayer(l.name);
                                }
                              }
                            },
                            child: const Text(
                              'تفعيل المعروض',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontFamily: 'Cairo',
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Layers list or Empty state
                  Expanded(
                    child: !hasLayers
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.layers_clear_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'لا توجد طبقات جغرافية محملة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: filteredLayers.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final layerInfo = filteredLayers[index];
                              final style = getStyleForLayer(layerInfo.name);
                              final isEnabled =
                                  state.enabledLayers.contains(layerInfo.name) ||
                                  style.aliases.any((a) => state.enabledLayers.contains(a));
                              final isVisibleAtCurrentZoom =
                                  state.currentZoom >= style.minZoom;

                              final displayTitle = layerInfo.titleAr.isNotEmpty
                                  ? layerInfo.titleAr
                                  : style.arabicTitle;

                              return CheckboxListTile(
                                value: isEnabled,
                                activeColor: const Color(0xFF0284C7),
                                onChanged: (_) => cubit.toggleLayer(layerInfo.name),
                                secondary: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: style.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black26,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      style.icon ?? (style.radius > 5 ? Icons.circle : Icons.polyline_rounded),
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  displayTitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                    color: isEnabled
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      layerInfo.name, // The client alias (real table name is never shown!)
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isVisibleAtCurrentZoom
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isVisibleAtCurrentZoom
                                              ? const Color(0xFFA7F3D0)
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Text(
                                        isVisibleAtCurrentZoom
                                            ? 'ظاهرة حالياً'
                                            : 'تكبير Z${style.minZoom}+',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontFamily: 'Cairo',
                                          color: isVisibleAtCurrentZoom
                                              ? const Color(0xFF065F46)
                                              : Colors.grey.shade500,
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
      },
    );
  }

  Widget _buildFilterChip(String key, String label, String activeKey, GisCubit cubit) {
    final isSelected = activeKey == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Cairo',
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0F3B6C),
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (_) => cubit.setCategoryFilter(key),
    );
  }
}
