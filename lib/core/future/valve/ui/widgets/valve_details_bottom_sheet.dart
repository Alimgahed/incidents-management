import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/ui/widgets/valve_icon_widget.dart';

class ValveDetailsBottomSheet extends StatelessWidget {
  final ValveModel valve;
  final VoidCallback onNavigateToValve;
  final VoidCallback onClose;

  const ValveDetailsBottomSheet({
    super.key,
    required this.valve,
    required this.onNavigateToValve,
    required this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required ValveModel valve,
    required VoidCallback onNavigateToValve,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: ValveDetailsBottomSheet(
          valve: valve,
          onNavigateToValve: () {
            Navigator.of(ctx).pop();
            onNavigateToValve();
          },
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = (valve.status != null && valve.status!.trim().isNotEmpty)
        ? valve.status!.trim()
        : 'جيد';
    final isGood = statusText == 'Good' || statusText == 'جيد' || statusText == 'يعمل';

    final yearText = valve.inServiceYear != null
        ? '${valve.inServiceYear}'
        : '2018';

    final directionText = (valve.direction != null && valve.direction!.trim().isNotEmpty)
        ? valve.direction!.trim()
        : 'يمين (مع عقارب الساعة)';

    final turnsText = valve.numOfTurns != null
        ? '${valve.numOfTurns} لفات'
        : '8 لفات';

    final pipeTypeText = (valve.valveType?.displayName != null &&
            valve.valveType!.displayName!.trim().isNotEmpty)
        ? valve.valveType!.displayName!.trim()
        : 'حديد زهر';

    final diameterValue = valve.pipeDiameter ?? valve.diameter ?? 200;
    final diameterText = '$diameterValue مم';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 2. Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Valve Avatar + Title + ID
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: ValveIconWidget(
                        size: 24,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تفاصيل المحبس',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'رقم المحبس: V-${valve.id ?? '10234'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Close Button (Left in RTL)
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. Grid of 6 Attributes (3 rows x 2 cols)
          Row(
            children: [
              // Col 1: الحالة
              Expanded(
                child: _buildAttributeCard(
                  icon: Icons.settings_outlined,
                  label: 'الحالة',
                  customValue: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isGood ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isGood ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Col 2: سنة التركيب
              Expanded(
                child: _buildAttributeCard(
                  icon: Icons.calendar_month_outlined,
                  label: 'سنة التركيب',
                  textValue: yearText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Col 1: اتجاه الفتح
              Expanded(
                child: _buildAttributeCard(
                  icon: Icons.sync_alt_rounded,
                  label: 'اتجاه الفتح',
                  textValue: directionText,
                ),
              ),
              const SizedBox(width: 12),
              // Col 2: عدد اللفات
              Expanded(
                child: _buildAttributeCard(
                  icon: Icons.autorenew_rounded,
                  label: 'عدد اللفات',
                  textValue: turnsText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Col 1: نوع الماسورة
              Expanded(
                child: _buildAttributeCard(
                  icon: Icons.view_stream_rounded,
                  label: 'نوع الماسورة',
                  textValue: pipeTypeText,
                ),
              ),
              const SizedBox(width: 12),
              // Col 2: قطر الماسورة
              Expanded(
                child: _buildAttributeCard(
                  icon: Icons.do_not_disturb_alt_rounded,
                  label: 'قطر الماسورة',
                  textValue: diameterText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4. Action Button "الانتقال إلى المحبس"
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onNavigateToValve,
              icon: const Icon(
                Icons.navigation_rounded,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                'الانتقال إلى المحبس',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3B6C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeCard({
    required IconData icon,
    required String label,
    String? textValue,
    Widget? customValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  fontFamily: 'Cairo',
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (customValue != null)
            Align(
              alignment: Alignment.centerLeft,
              child: customValue,
            )
          else if (textValue != null)
            Text(
              textValue,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
