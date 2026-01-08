import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../Utils/app_theme.dart';

class StreakFireIcon extends StatefulWidget {
  final double size;
  final bool isDark;

  const StreakFireIcon({super.key, required this.size, required this.isDark});

  @override
  State<StreakFireIcon> createState() => _StreakFireIconState();
}

class _StreakFireIconState extends State<StreakFireIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _fireController;

  @override
  void initState() {
    super.initState();
    _fireController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        'assets/animations/streak_fire.json',
        controller: _fireController,
        fit: BoxFit.contain,
        onLoaded: (composition) {
          _fireController.duration = composition.duration;
          _fireController.repeat();
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.local_fire_department,
            color: widget.isDark ? AppTheme.fireOrange : AppTheme.primaryColor,
            size: widget.size,
          );
        },
      ),
    );
  }
}
