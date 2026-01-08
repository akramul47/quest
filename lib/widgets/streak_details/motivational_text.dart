import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

class MotivationalText extends StatelessWidget {
  final int streak;
  final bool isActiveToday;
  final bool isFrozen;
  final bool isDark;

  const MotivationalText({
    super.key,
    required this.streak,
    required this.isActiveToday,
    required this.isFrozen,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    if (isFrozen) {
      message = 'Your streak is frozen for today';
    } else if (isActiveToday) {
      message = 'You\'re on fire! Keep it up!';
    } else if (streak == 0) {
      message = 'Start your streak today!';
    } else {
      message = 'Keep the fire alive\ncheck in today!';
    }

    return Text(
      message,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.fireOrange : AppTheme.textDark,
        height: 1.4,
      ),
    );
  }
}
