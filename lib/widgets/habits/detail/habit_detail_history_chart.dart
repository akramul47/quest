import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailHistoryChart extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailHistoryChart({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = HabitStatisticsService.instance;
    // Get last 12 months
    final history = stats.getCompletionByMonth(habit, 12);

    // Sort by date (oldest first) for the chart
    final sortedEntries = history.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

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
              Icon(
                Icons.bar_chart_rounded,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'History',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: sortedEntries.isEmpty
                ? Center(
                    child: Text(
                      'No history yet',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? AppTheme.textLightDark
                            : AppTheme.textLight,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 1.0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => isDark
                              ? Colors.black.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.9),
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = sortedEntries[groupIndex].key;
                            final monthName = DateFormat(
                              'MMMM yyyy',
                            ).format(date);
                            final value = (rod.toY * 100).toInt();
                            return BarTooltipItem(
                              '$monthName\n',
                              GoogleFonts.inter(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '$value% Completed',
                                  style: GoogleFonts.inter(
                                    color: habit.color,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= sortedEntries.length) {
                                return const SizedBox.shrink();
                              }
                              final date = sortedEntries[index].key;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat(
                                    'MMM',
                                  ).format(date)[0], // J, F, M...
                                  style: GoogleFonts.inter(
                                    color: isDark
                                        ? AppTheme.textLightDark
                                        : AppTheme.textLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 0.25,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: sortedEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value.value; // 0.0 to 1.0

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              color: habit.color,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 1.0,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
