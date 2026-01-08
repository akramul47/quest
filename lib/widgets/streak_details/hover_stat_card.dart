import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

/// Interactive stat card with hover animation
class HoverStatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool isDark;

  const HoverStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.isDark,
  });

  @override
  State<HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<HoverStatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: _isHovering
                    ? (widget.isDark
                          ? Colors.white.withAlpha(25)
                          : Colors.white.withAlpha(230))
                    : (widget.isDark
                          ? Colors.white.withAlpha(13)
                          : Colors.white.withAlpha(179)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovering
                      ? widget.iconColor.withAlpha(100)
                      : (widget.isDark
                            ? Colors.white.withAlpha(26)
                            : AppTheme.primaryColor.withAlpha(26)),
                  width: _isHovering ? 1.5 : 1.0,
                ),
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: widget.iconColor.withAlpha(60),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: _isHovering ? 28 : 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.value,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? Colors.white60
                          : AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
