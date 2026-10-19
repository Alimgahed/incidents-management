import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/missions/missions_card.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class AllMissionsMobile extends StatefulWidget {
  const AllMissionsMobile({super.key});

  @override
  State<AllMissionsMobile> createState() => _AllMissionsMobileState();
}

class _AllMissionsMobileState extends State<AllMissionsMobile> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AllMissionsCubit>().clearSearch();
    setState(() {
      _isSearchActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: MobileSystemBars.standard,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: BlocBuilder<AllMissionsCubit, GetAllMissionState>(
            builder: (context, state) {
              return state.when(
                initial: () => const Center(child: Loadding()),
                loading: () => const Center(child: Loadding()),
                error: (message) => const Center(child: Error()),
                loaded: (missions) => _buildContent(context, missions),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniStartFloat,
          floatingActionButton: _buildFloatingAddButton(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<AllMissionModel> allMissions) {
    final categories = allMissions
        .map((e) => e.className)
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    final filteredMissions = allMissions.where((m) {
      final matchesCategory = _selectedCategory == null ||
          m.className == _selectedCategory;
      return matchesCategory;
    }).toList();

    return RefreshIndicator(
      color: appColor,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await context.read<AllMissionsCubit>().getAllMissions();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Top Header Banner
          SliverToBoxAdapter(
            child: _buildHeaderBanner(context),
          ),

          // 2. Executive Hero Summary Card & Search/Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  _buildSummaryHeroCard(allMissions.length),
                  const SizedBox(height: 14),
                  _buildSearchBarAndFilter(context, categories),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 3. Missions List
          if (filteredMissions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredMissions[index];
                    return MissionCard(mission: item, index: index);
                  },
                  childCount: filteredMissions.length,
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo (Right in RTL)
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
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

                    // Back Button (Left in RTL)
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
                const Text(
                  'سجل جميع المهام',
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
  Widget _buildSummaryHeroCard(int totalMissions) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E56A0),
            Color(0xFF163E75),
            Color(0xFF0F2B56),
          ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Icon Container (Right in RTL)
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
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Metric Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalMissions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'إجمالي المهام المعرفة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'مهام التدخل القياسية في النظام',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Decorative Graphic (Left in RTL)
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
                  Icons.task_alt_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SEARCH BAR & FILTER ---
  Widget _buildSearchBarAndFilter(
      BuildContext context, List<String> categories) {
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
                setState(() => _isSearchActive = val.isNotEmpty);
                context.read<AllMissionsCubit>().searchMissions(val);
              },
              style: const TextStyle(fontSize: 13, color: primaryTextColor),
              decoration: InputDecoration(
                hintText: 'ابحث عن مهمة...',
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
                suffixIcon: _isSearchActive
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: disabledTextColor,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Filter Button (Left in RTL)
        GestureDetector(
          onTap: () => _showFilterDialog(context, categories),
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

  void _showFilterDialog(BuildContext context, List<String> categories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
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
                    'تصفية حسب تصنيف المهمة',
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
                (cat) => ListTile(
                  title: Text(
                    cat,
                    style: TextStyle(
                      fontWeight: _selectedCategory == cat
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedCategory == cat
                          ? const Color(0xFF1B64F2)
                          : primaryTextColor,
                    ),
                  ),
                  trailing: _selectedCategory == cat
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF1B64F2))
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
            await context.pushNamed(Routes.addMissions);
            if (context.mounted) {
              context.read<AllMissionsCubit>().getAllMissions();
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'إضافة مهمة جديدة',
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

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 64,
            color: Color(0xFFCBD5E1),
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد مهام مطابقة للبحث',
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
