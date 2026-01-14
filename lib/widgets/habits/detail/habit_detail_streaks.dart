import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailStreaks extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailStreaks({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = HabitStatisticsService.instance;
    final bestStreaks = stats.getBestStreaks(habit, limit: 5);
    final currentStreak = stats.getCurrentStreak(habit);

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
              Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Best Streaks',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (bestStreaks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No streaks yet',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                  ),
                ),
              ),
            )
          else
            ...bestStreaks.asMap().entries.map((entry) {
              final index = entry.key;
              final streak = entry.value;
              final isActive =
                  currentStreak != null &&
                  streak.start == currentStreak.start &&
                  streak.end == currentStreak.end;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < bestStreaks.length - 1 ? 12 : 0,
                ),
                child: _buildStreakItem(streak, isActive, isDark),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildStreakItem(dynamic streak, bool isActive, bool isDark) {
    final dateFormat = DateFormat('MMM d, y');
    final startStr = dateFormat.format(streak.start);
    final endStr = dateFormat.format(streak.end);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.orange.withValues(alpha: 0.1)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.orange.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.orange.withValues(alpha: 0.2)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive ? Icons.local_fire_department : Icons.emoji_events,
              color: isActive ? Colors.orange : Colors.amber,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${streak.length} ${streak.length == 1 ? 'day' : 'days'}',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.textDarkMode
                              : AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$startStr - $endStr',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
