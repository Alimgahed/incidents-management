import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_cubit.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_state.dart';
import 'package:incidents_managment/core/future/gis/models/gis_style_config.dart';

class GisLayerControlDrawer extends StatelessWidget {
  const GisLayerControlDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GisCubit, GisState>(
      builder: (context, state) {
        final cubit = context.read<GisCubit>();

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
                            'إدارة طبقات الخريطة (GIS)',
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

                  // OpenStreetMap underlay toggle
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          color: Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'خريطة الأساس (OSM)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                'إظهار شوارع OpenStreetMap بالخلفية',
                                style: TextStyle(
                                  fontSize: 11,
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

                  // Quick actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الطبقات المتجهة (${state.enabledLayers.length}/${gisLayerStack.length})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            for (final s in gisLayerStack) {
                              if (!state.enabledLayers.contains(s.name)) {
                                cubit.toggleLayer(s.name);
                              }
                            }
                          },
                          child: const Text(
                            'تفعيل الكل',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Layers list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: gisLayerStack.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final style = gisLayerStack[index];
                        final isEnabled = state.enabledLayers.contains(style.name);
                        final isVisibleAtCurrentZoom =
                            state.currentZoom >= style.minZoom;

                        return CheckboxListTile(
                          value: isEnabled,
                          activeColor: const Color(0xFF0284C7),
                          onChanged: (_) => cubit.toggleLayer(style.name),
                          secondary: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: style.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black26,
                                width: 1,
                              ),
                            ),
                          ),
                          title: Text(
                            style.arabicTitle,
                            style: TextStyle(
                              fontSize: 13.5,
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
                                style.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: isVisibleAtCurrentZoom
                                      ? Colors.green.shade50
                                      : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'زووم ≥ ${style.minZoom}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isVisibleAtCurrentZoom
                                        ? Colors.green.shade800
                                        : Colors.amber.shade900,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
