import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class AllIncidentTypeMobileScreen extends StatefulWidget {
  const AllIncidentTypeMobileScreen({super.key});

  @override
  State<AllIncidentTypeMobileScreen> createState() =>
      _AllIncidentTypeMobileScreenState();
}

class _AllIncidentTypeMobileScreenState
    extends State<AllIncidentTypeMobileScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: MobileSystemBars.standard,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
            body: BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Loadding(),
                  loaded: (incidentTypes) => _buildBody(context, incidentTypes),
                  error: (message) => const Error(),
                );
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniStartFloat,
            floatingActionButton: _buildFloatingAddButton(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<IncidentType> allTypes) {
    // Filtered list
    final filteredTypes = allTypes.where((type) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          type.incidentTypeName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (type.className != null &&
              type.className!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ));

      final matchesCategory =
          _selectedCategory == null || type.className == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    // Get unique categories for filtering
    final categories = allTypes
        .map((e) => e.className)
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    return RefreshIndicator(
      color: appColor,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await context.read<AllIncidentTypeCubit>().getAllIncidentTypes();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Top Header Banner
          SliverToBoxAdapter(child: _buildHeaderBanner(context)),

          // Summary Hero Card & Search/Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  // Executive Hero Card
                  _buildSummaryHeroCard(allTypes.length),
                  const SizedBox(height: 14),
                  // Search Bar & Filter Button
                  _buildSearchBarAndFilter(context, categories),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Incident Types List
          if (filteredTypes.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = filteredTypes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _IncidentTypeItemCard(
                      incidentType: item,
                      onTap: () {
                        _showIncidentMissionsBottomSheet(context, item);
                      },
                    ),
                  );
                }, childCount: filteredTypes.length),
              ),
            ),
        ],
      ),
    );
  }

  // --- TOP HEADER BANNER ---
  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F3B6C),
        image: DecorationImage(
          image: AssetImage('assets/images/header_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A2240).withValues(alpha: 0.94),
              const Color(0xFF0F3866).withValues(alpha: 0.88),
              const Color(0xFF164780).withValues(alpha: 0.97),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                // Top App Bar with Logo and Back Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo Icon (Right in RTL)
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.water_drop_rounded,
                                color: appColor,
                                size: 28,
                              ),
                        ),
                      ),
                    ),

                    // Back Button (Left in RTL, pointing back/right)
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title & Subtitle
                const Text(
                  'أنواع الأزمات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'شركة مياه الشرب والصرف الصحي بالمنيا',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SUMMARY HERO CARD ---
  Widget _buildSummaryHeroCard(int totalTypes) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E56A0), Color(0xFF163E75), Color(0xFF0F2B56)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163E75).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Ambient Circles
            Positioned(
              left: -20,
              bottom: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Content Row: Layer icon on right (start), graph icon on left (end)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  // Layer Stack Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.layers_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalTypes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'إجمالي الأنواع',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'موزعة على جميع الفئات',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Signal Bars Graphic on the end
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEARCH BAR & FILTER BUTTON ---
  Widget _buildSearchBarAndFilter(
    BuildContext context,
    List<String> categories,
  ) {
    return Row(
      children: [
        // Search Input Field (Right in RTL)
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: const TextStyle(fontSize: 13, color: primaryTextColor),
              decoration: InputDecoration(
                hintText: 'ابحث عن نوع أزمة...',
                hintStyle: const TextStyle(
                  fontSize: 12.5,
                  color: disabledTextColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: secondaryTextColor,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: disabledTextColor,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Filter Icon Button with badge if filtered (Left in RTL)
        GestureDetector(
          onTap: () => _showCategoryFilterSheet(context, categories),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedCategory != null
                    ? const Color(0xFF1B64F2)
                    : const Color(0xFFE2E8F0),
                width: _selectedCategory != null ? 1.6 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: _selectedCategory != null
                      ? const Color(0xFF1B64F2)
                      : secondaryTextColor,
                  size: 22,
                ),
                if (_selectedCategory != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B64F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- FLOATING ACTION BUTTON ---
  Widget _buildFloatingAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E56A0).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFF164780),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            await context.pushNamed(Routes.addIncidentType);
            if (context.mounted) {
              context.read<AllIncidentTypeCubit>().getAllIncidentTypes();
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'إضافة نوع أزمة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- BOTTOM SHEET FOR MISSIONS RELATED ---
  void _showIncidentMissionsBottomSheet(
    BuildContext context,
    IncidentType incidentType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _IncidentTypeMissionsModal(incidentType: incidentType),
      ),
    );
  }

  // --- CATEGORY FILTER MODAL ---
  void _showCategoryFilterSheet(BuildContext context, List<String> categories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تصفية حسب الفئة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    if (_selectedCategory != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedCategory = null);
                          Navigator.pop(ctx);
                        },
                        child: const Text('إلغاء التصفية'),
                      ),
                  ],
                ),
                const Divider(),
                ...categories.map(
                  (category) => ListTile(
                    title: Text(
                      category,
                      style: TextStyle(
                        fontWeight: _selectedCategory == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedCategory == category
                            ? const Color(0xFF1B64F2)
                            : primaryTextColor,
                      ),
                    ),
                    trailing: _selectedCategory == category
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF1B64F2),
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedCategory = category);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Color(0xFFCBD5E1)),
          SizedBox(height: 16),
          Text(
            'لا توجد أنواع أزمات مطابقة للبحث',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'جرّب البحث باسم آخر أو إزالة التصفية',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// INCIDENT TYPE ITEM CARD (MATCHING MOCKUP)
// ==========================================
class _IncidentTypeItemCard extends StatelessWidget {
  final IncidentType incidentType;
  final VoidCallback onTap;

  const _IncidentTypeItemCard({
    required this.incidentType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final missionsCount = incidentType.missions?.length ?? 0;
    final styleInfo = _getTypeStyle(incidentType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEEF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Right side in Arabic: Colored Category Icon Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: styleInfo.bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      styleInfo.icon,
                      color: styleInfo.iconColor,
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Middle: Title, Category, Missions count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        incidentType.incidentTypeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Category Row
                      Row(
                        children: [
                          const Icon(
                            Icons.group_work_rounded,
                            size: 15,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'الفئة: ${incidentType.className ?? "عام"}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Missions Count Pill with check icon
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: Color(0xFF1E56A0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$missionsCount مهمة',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // 3. Left side in Arabic: Action Chevron (Points to previous/open)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _TypeStyle _getTypeStyle(IncidentType type) {
    final name = type.incidentTypeName.toLowerCase();
    final cat = (type.className ?? '').toLowerCase();

    if (name.contains('مبني') ||
        name.contains('حريق') ||
        name.contains('أمن') ||
        cat.contains('أمن')) {
      return _TypeStyle(
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
      );
    } else if (name.contains('سيرفر') ||
        name.contains('تكنولوجيا') ||
        name.contains('اختراق') ||
        cat.contains('تكنولوجيا')) {
      return _TypeStyle(
        icon: Icons.laptop_mac_rounded,
        iconColor: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
      );
    } else if (name.contains('ماسورة') ||
        name.contains('مياه') ||
        name.contains('كسر') ||
        name.contains('شبكات') ||
        cat.contains('مياه')) {
      return _TypeStyle(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF0284C7),
        bgColor: const Color(0xFFF0F9FF),
      );
    } else {
      return _TypeStyle(
        icon: Icons.crisis_alert_rounded,
        iconColor: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
      );
    }
  }
}

class _TypeStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  _TypeStyle({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

// ==========================================
// MISSIONS BOTTOM SHEET DIALOG
// ==========================================
class _IncidentTypeMissionsModal extends StatelessWidget {
  final IncidentType incidentType;

  const _IncidentTypeMissionsModal({required this.incidentType});

  @override
  Widget build(BuildContext context) {
    final missions = incidentType.missions ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E56A0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF1E56A0),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مهام: ${incidentType.incidentTypeName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الفئة: ${incidentType.className ?? "غير محدد"}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // Missions List
          if (missions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 56,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'لا توجد مهام مسجلة لهذا النوع',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'يمكنك ربط مهام عمل قياسية بهذا النوع من قائمة العمليات',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: missions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final mission = missions[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Order Badge
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E56A0), Color(0xFF163E75)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${mission.order ?? (index + 1)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Mission details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mission.missionName ?? 'مهمة بدون اسم',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (mission.missionClassName != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  mission.missionClassName!,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
