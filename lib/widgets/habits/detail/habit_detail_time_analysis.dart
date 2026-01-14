import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';

class HabitDetailTimeAnalysis extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailTimeAnalysis({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalDays = habit.getTotalCompletedDays();

    DateTime firstDate = DateTime.now();
    if (habit.history.keys.isNotEmpty) {
      final dates = habit.history.keys
          .map((key) => DateTime.parse(key))
          .toList();
      firstDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    }

    final daysSinceStart = DateTime.now().difference(firstDate).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withValues(alpha: 0.6)
            : AppTheme.glassBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue, size: 22),
              const SizedBox(width: 8),
              Text(
                'Time Stats',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimeStat(
            'Days Tracking',
            '$daysSinceStart days',
            Icons.event,
            isDark,
          ),

          const SizedBox(height: 12),
          _buildTimeStat(
            'Started',
            DateFormat('MMM d, yyyy').format(firstDate),
            Icons.calendar_today,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStat(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
