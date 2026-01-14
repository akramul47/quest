import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailOverviewCard extends StatelessWidget {
  final Habit habit;
  final bool isDark;
  final bool isMobile;
  final VoidCallback? onBack;

  const HabitDetailOverviewCard({
    Key? key,
    required this.habit,
    required this.isDark,
    required this.isMobile,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isMobile
          ? const EdgeInsets.all(12)
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withValues(alpha: 0.7)
            : AppTheme.glassBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
          ],
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 20),
            decoration: BoxDecoration(
              color: habit.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isMobile ? 50 : 12),
            ),
            child: Icon(
              habit.icon,
              size: isMobile ? 24 : 48,
              color: habit.color,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 20 : 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
                if (habit.question != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    habit.question!,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 12 : 16,
                      color: isDark
                          ? AppTheme.textMediumDark
                          : AppTheme.textMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (habit.type == HabitType.measurable) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: habit.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: habit.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.straighten, size: 12, color: habit.color),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.unit}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: habit.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: isMobile ? 12 : 20),
          // Score Percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: habit.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${(HabitStatisticsService.instance.getTodayScore(habit).value * 100).toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: habit.color,
                    ),
                  ),
                  TextSpan(
                    text: '%',
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.w600,
                      color: habit.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
