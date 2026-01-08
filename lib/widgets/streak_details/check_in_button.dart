import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

class CheckInButton extends StatelessWidget {
  final bool isActiveToday;
  final bool isDark;
  final VoidCallback onPressed;

  const CheckInButton({
    super.key,
    required this.isActiveToday,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActiveToday ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppTheme.fireOrange : AppTheme.primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          disabledBackgroundColor: isDark
              ? AppTheme.fireOrange.withValues(alpha: 0.3)
              : AppTheme.primaryColor.withValues(alpha: 0.3),
          disabledForegroundColor: isDark ? Colors.black54 : Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          isActiveToday ? 'You\'re on fire! 🔥' : 'Check in today!',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
