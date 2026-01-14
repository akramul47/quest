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
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      child: Stack(
        children: [
          // Main content - centered icon and title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(isMobile ? 50 : 12),
                ),
                child: Icon(
                  habit.icon,
                  size: isMobile ? 24 : 40,
                  color: habit.color,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 20),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      habit.name,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 20 : 26,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        textAlign: TextAlign.center,
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
                            Icon(
                              Icons.straighten,
                              size: 12,
                              color: habit.color,
                            ),
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
            ],
          ),

          // Back button on the left with larger tap area
          if (onBack != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.only(
                    left: isMobile ? 4 : 8,
                    right: isMobile ? 12 : 16,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                    size: 24,
                  ),
                ),
              ),
            ),

          // Percentage on the right
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
                          fontSize: isMobile ? 20 : 26,
                          fontWeight: FontWeight.bold,
                          color: habit.color,
                        ),
                      ),
                      TextSpan(
                        text: '%',
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 12 : 16,
                          fontWeight: FontWeight.w600,
                          color: habit.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
