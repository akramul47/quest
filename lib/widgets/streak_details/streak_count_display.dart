import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

class StreakCountDisplay extends StatelessWidget {
  final int streak;
  final double fontSize;
  final bool isDark;

  const StreakCountDisplay({
    super.key,
    required this.streak,
    required this.fontSize,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$streak',
          style: GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.fireOrange : AppTheme.primaryColor,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Day Streak',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.fireOrange : AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
