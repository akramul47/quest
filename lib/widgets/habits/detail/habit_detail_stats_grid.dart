import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailStatsGrid extends StatelessWidget {
  final Habit habit;
  final bool isDark;
  final int crossAxisCount;

  const HabitDetailStatsGrid({
    Key? key,
    required this.habit,
    required this.isDark,
    required this.crossAxisCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = HabitStatisticsService.instance;
    final summary = stats.getSummary(habit);

    // Calculate average for measurable habits
    double? averageValue;
    if (habit.type == HabitType.measurable) {
      final last30Days = List.generate(30, (i) {
        final date = DateTime.now().subtract(Duration(days: i));
        return habit.getValueForDate(date);
      }).where((v) => v != null && v is num).toList();

      if (last30Days.isNotEmpty) {
        averageValue =
            last30Days.fold(0.0, (sum, v) => sum + (v as num).toDouble()) /
            last30Days.length;
      }
    }

    final statsList = [
      _StatData(
        'Score',
        '${(summary.todayScore * 100).toInt()}',
        '%',
        Icons.stars_rounded,
        habit.color,
      ),
      _StatData(
        'Current',
        '${summary.currentStreak}',
        'days',
        Icons.local_fire_department,
        Colors.orange,
      ),
      if (habit.type != HabitType.measurable)
        _StatData(
          '7-Day',
          '${(summary.weeklyRate * 100).toInt()}',
          '%',
          Icons.trending_up,
          Colors.green,
        ),
      _StatData(
        '30-Day',
        '${(summary.monthlyRate * 100).toInt()}',
        '%',
        Icons.analytics,
        Colors.blue,
      ),
      if (averageValue != null)
        _StatData(
          'Average',
          averageValue.toStringAsFixed(1),
          habit.unit,
          Icons.show_chart,
          habit.color,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: statsList.length,
      itemBuilder: (context, index) {
        final stat = statsList[index];
        return _buildEnhancedStatCard(
          stat.label,
          stat.value,
          stat.unit,
          stat.icon,
          stat.color,
          isDark,
        );
      },
    );
  }

  Widget _buildEnhancedStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withValues(alpha: 0.6)
            : AppTheme.glassBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and value row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.textDarkMode
                              : AppTheme.textDark,
                          height: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        unit,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.textLightDark
                              : AppTheme.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  _StatData(this.label, this.value, this.unit, this.icon, this.color);
}
