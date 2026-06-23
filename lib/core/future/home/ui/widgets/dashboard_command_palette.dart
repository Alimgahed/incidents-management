import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';

import 'package:incidents_managment/core/future/home/logic/incident_picker_bridge.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';

const _kDashboardPaletteNav = <({int index, String title, IconData icon})>[
  (index: 0, title: 'لوحة التحكم', icon: Icons.space_dashboard_outlined),
  (index: 1, title: 'الخريطة', icon: Icons.map_outlined),
  (index: 2, title: 'المستخدمين', icon: Icons.groups_outlined),
  (index: 4, title: 'إضافة أزمة', icon: Icons.add_circle_outline_rounded),
  (index: 5, title: 'أنواع الأزمات', icon: Icons.category_outlined),
  (index: 6, title: 'جميع المهام', icon: Icons.assignment_outlined),
  (index: 7, title: 'ربط مهام بالأزمة', icon: Icons.hub_outlined),
];

/// Opens the command palette (also bound to Ctrl/Cmd+K via [DashboardCommandPaletteHost]).
///
/// Dialog routes do not inherit [BlocProvider]s — we re-inject the cubits with `.value`.
void showDashboardCommandPalette(BuildContext context) {
  final mapCubit = context.read<IncidentMapCubit>();
  final homeCubit = context.read<HomeCubit>();

  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider<IncidentMapCubit>.value(value: mapCubit),
        BlocProvider<HomeCubit>.value(value: homeCubit),
      ],
      child: const _CommandPaletteDialog(nav: _kDashboardPaletteNav),
    ),
  );
}

/// Registers Ctrl/Cmd+K while this widget is mounted.
class DashboardCommandPaletteHost extends StatefulWidget {
  final Widget child;

  const DashboardCommandPaletteHost({super.key, required this.child});

  @override
  State<DashboardCommandPaletteHost> createState() => _DashboardCommandPaletteHostState();
}

class _DashboardCommandPaletteHostState extends State<DashboardCommandPaletteHost> {
  bool Function(KeyEvent)? _handler;

  @override
  void initState() {
    super.initState();
    _handler = (KeyEvent event) {
      if (event is! KeyDownEvent) return false;
      if (event.logicalKey != LogicalKeyboardKey.keyK) return false;
      final pressed = HardwareKeyboard.instance.logicalKeysPressed;
      final mod = pressed.contains(LogicalKeyboardKey.controlLeft) ||
          pressed.contains(LogicalKeyboardKey.controlRight) ||
          pressed.contains(LogicalKeyboardKey.metaLeft) ||
          pressed.contains(LogicalKeyboardKey.metaRight);
      if (!mod) return false;
      if (!mounted) return false;
      showDashboardCommandPalette(context);
      return true;
    };
    HardwareKeyboard.instance.addHandler(_handler!);
  }

  @override
  void dispose() {
    if (_handler != null) {
      HardwareKeyboard.instance.removeHandler(_handler!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _CommandPaletteDialog extends StatefulWidget {
  final List<({int index, String title, IconData icon})> nav;

  const _CommandPaletteDialog({required this.nav});

  @override
  State<_CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<_CommandPaletteDialog> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _norm(String? s) => (s ?? '').toLowerCase();

  List<CurrentIncidentModel> _filteredIncidents(IncidentMapCubit map) {
    final q = _controller.text.trim().toLowerCase();
    final list = map.incidents;
    if (q.isEmpty) return list.take(12).toList();
    return list.where((i) {
      final id = '${i.currentIncidentId ?? ''}';
      final desc = _norm(i.currentIncidentDescription);
      final type = _norm(i.currentIncidentTypeName);
      final branch = _norm(i.branchName);
      return id.contains(q) || desc.contains(q) || type.contains(q) || branch.contains(q);
    }).take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    final map = context.read<IncidentMapCubit>();
    final home = context.read<HomeCubit>();
    final q = _controller.text.trim().toLowerCase();

    final navHits = widget.nav.where((e) {
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) || '${e.index}'.contains(q);
    }).toList();

    final incidents = _filteredIncidents(map);

    final mq = MediaQuery.sizeOf(context);
    final dialogW = (mq.width - 48).clamp(280.0, 560.0);
    final dialogH = (mq.height * 0.72).clamp(320.0, 560.0);

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 72, left: 24, right: 24, bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: dialogW,
        height: dialogH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'انتقل إلى قسم أو ابحث عن أزمة…',
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (navHits.isNotEmpty) ...[
                    const _SectionTitle('التنقل السريع'),
                    ...navHits.map(
                      (e) => ListTile(
                        leading: Icon(e.icon),
                        title: Text(e.title),
                        subtitle: Text('قسم ${e.index + 1}', style: const TextStyle(fontSize: 12)),
                        onTap: () {
                          home.changeState(e.index);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                  if (incidents.isNotEmpty) ...[
                    const _SectionTitle('الأزمات'),
                    ...incidents.map((i) {
                      final h = incidentDescriptionHeadline(i.currentIncidentDescription).trim();
                      final titleText = h.isEmpty
                          ? (i.currentIncidentTypeName ?? 'أزمة #${i.currentIncidentId}')
                          : h;
                      final subParts = <String>[
                        if ((i.currentIncidentTypeName ?? '').trim().isNotEmpty) i.currentIncidentTypeName!,
                        'رقم ${i.currentIncidentId}',
                        if ((i.branchName ?? '').trim().isNotEmpty) i.branchName!,
                      ];
                      return ListTile(
                        leading: const Icon(Icons.emergency_outlined),
                        title: Text(
                          titleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          subParts.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          home.changeState(0);
                          getIt<IncidentPickerBridge>().requestSelect(i);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                  if (navHits.isEmpty && incidents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        q.isEmpty ? 'اكتب للبحث…' : 'لا توجد نتائج',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Ctrl+K أو ⌘+K',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
