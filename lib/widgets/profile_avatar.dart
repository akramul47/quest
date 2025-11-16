import 'package:flutter/material.dart';
import 'dart:ui';
import '../Utils/app_theme.dart';

class ProfileAvatar extends StatefulWidget {
  final VoidCallback? onTap;
  final double size;

  const ProfileAvatar({
    Key? key,
    this.onTap,
    this.size = 40,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isHovered = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Use app's primary color for the avatar
    final primaryColor = isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor;
    final borderColor = primaryColor.withOpacity(0.5);

    final avatar = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        // Glass/crystal effect with gradient and backdrop blur
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.6),
                ],
        ),
        boxShadow: [
          // Subtle glow effect with primary color
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                      ]
                    : [
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.4),
                      ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                size: widget.size * 0.5,
                color: primaryColor.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.onTap == null) {
      return avatar;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: avatar,
        ),
      ),
    );
  }
}
