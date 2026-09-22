import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const HoverCard({super.key, required this.child, this.onTap});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
