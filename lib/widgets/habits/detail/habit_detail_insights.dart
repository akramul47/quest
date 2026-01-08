import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';

class HabitDetailInsights extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailInsights({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights(habit);

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
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Text(
                'Insights',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(insight.icon, size: 18, color: insight.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight.text,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? AppTheme.textMediumDark
                            : AppTheme.textMedium,
                      ),
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

  List<_Insight> _generateInsights(Habit habit) {
    final insights = <_Insight>[];
    final currentStreak = habit.getCurrentStreak();
    final longestStreak = habit.getLongestStreak();
    final rate7 = habit.getCompletionRate(7);
    final rate30 = habit.getCompletionRate(30);

    // Streak insights
    if (currentStreak > 0) {
      if (currentStreak == longestStreak && currentStreak >= 3) {
        insights.add(
          _Insight(
            '🔥 Amazing! You\'re on your best streak ever!',
            Icons.celebration,
            Colors.orange,
          ),
        );
      } else if (currentStreak >= 7) {
        insights.add(
          _Insight(
            'Great job! ${currentStreak} days streak and counting!',
            Icons.trending_up,
            Colors.green,
          ),
        );
      }
    } else {
      insights.add(
        _Insight('Start building your streak today!', Icons.flag, Colors.blue),
      );
    }

    // Consistency insights
    if (rate7 >= 0.85) {
      insights.add(
        _Insight('Excellent consistency this week!', Icons.star, Colors.amber),
      );
    } else if (rate7 < 0.5 && rate30 >= 0.7) {
      insights.add(
        _Insight(
          'Your consistency has dropped this week. Get back on track!',
          Icons.info_outline,
          Colors.orange,
        ),
      );
    }

    // Progress insights
    if (rate30 >= 0.8) {
      insights.add(
        _Insight(
          'Outstanding! 80%+ completion this month.',
          Icons.workspace_premium,
          Colors.purple,
        ),
      );
    } else if (rate30 >= 0.5) {
      insights.add(
        _Insight(
          'Good progress! Keep pushing to reach 80%.',
          Icons.thumb_up,
          Colors.blue,
        ),
      );
    }

    // Longest streak motivation
    if (longestStreak >= 30) {
      insights.add(
        _Insight(
          'You\'ve proven you can maintain habits long-term!',
          Icons.emoji_events,
          Colors.amber,
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        _Insight(
          'Start tracking today to build your habit!',
          Icons.rocket_launch,
          habit.color,
        ),
      );
    }

    return insights;
  }
}

class _Insight {
  final String text;
  final IconData icon;
  final Color color;

  _Insight(this.text, this.icon, this.color);
}
