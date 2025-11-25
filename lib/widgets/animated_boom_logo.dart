import 'package:flutter/material.dart';

/// Simple BOOM logo widget - displays static logo image
class AnimatedBoomLogo extends StatelessWidget {
  final bool isDark;
  final double size;
  final Color primaryColor;

  const AnimatedBoomLogo({
    Key? key,
    required this.isDark,
    this.size = 200,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/boom.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image fails to load
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
