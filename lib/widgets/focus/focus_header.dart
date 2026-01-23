import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/focus_provider.dart';
import 'session_label.dart';

class FocusHeader extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final VoidCallback? onSettingsTap;

  const FocusHeader({
    Key? key,
    required this.isDark,
    required this.isMobile,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final focusProvider = Provider.of<FocusProvider>(context);
    final primaryColor = isDark
        ? const Color(0xFFBB86FC)
        : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered session label - truly centered based on screen width
          Center(
            child: SessionLabel(
              provider: focusProvider,
              isDark: isDark,
              isMobile: isMobile,
              isSmall: false,
            ),
          ),

          // Settings button positioned absolutely on the right
          Positioned(
            right: 0,
            child: _SettingsButton(
              isDark: isDark,
              primaryColor: primaryColor,
              onTap: onSettingsTap ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatefulWidget {
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  const _SettingsButton({
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: _isHovered
              ? Border.all(
                  color: widget.primaryColor.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.6),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: widget.primaryColor.withValues(alpha: 0.15),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Center(
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: widget.primaryColor.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
