import 'dart:async';
import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';

class MobileHomeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final DashboardCubit dashboardCubit;
  final VoidCallback onFilterTap;

  const MobileHomeSearchBar({
    super.key,
    required this.controller,
    required this.dashboardCubit,
    required this.onFilterTap,
  });

  @override
  State<MobileHomeSearchBar> createState() => _MobileHomeSearchBarState();
}

class _MobileHomeSearchBarState extends State<MobileHomeSearchBar> {
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final hasTextNow = widget.controller.text.isNotEmpty;
    if (_hasText != hasTextNow) {
      if (mounted) {
        setState(() => _hasText = hasTextNow);
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.dashboardCubit.updateSearchQuery(value);
      }
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    widget.controller.clear();
    widget.dashboardCubit.updateSearchQuery('');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = widget.dashboardCubit.hasActiveFilters;

    return Row(
      children: [
        // Filter Action Button
        GestureDetector(
          onTap: widget.onFilterTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasActiveFilters ? appColor : const Color(0xFFE5E7EB),
                width: hasActiveFilters ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilters ? appColor : secondaryTextColor,
                  size: 20,
                ),
                if (hasActiveFilters)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Search Input Field
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13, color: primaryTextColor),
              decoration: InputDecoration(
                hintText: 'ابحث عن أزمة أو فرع أو عنوان أو مسؤول...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: disabledTextColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: secondaryTextColor,
                  size: 20,
                ),
                suffixIcon: _hasText
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
      ],
    );
  }
}
