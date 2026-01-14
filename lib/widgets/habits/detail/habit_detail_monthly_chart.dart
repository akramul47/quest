import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailMonthlyChart extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailMonthlyChart({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = HabitStatisticsService.instance;
    final scoreHistory = stats.getScoreHistory(habit, 30);
    // Convert to list sorted by date
    final sortedEntries = scoreHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Create spots, ensuring at least 2 points for a line
    List<FlSpot> spots = [];
    if (sortedEntries.isNotEmpty) {
      spots = sortedEntries
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value.value))
          .toList();
    }

    // Calculate current percentage
    int currentPercent = 0;
    if (sortedEntries.isNotEmpty) {
      currentPercent = (sortedEntries.last.value * 100).toInt();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      // Glass morphism style matching history chart
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    color: isDark
                        ? AppTheme.textMediumDark
                        : AppTheme.textMedium,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progress Score',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              // Current Score Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: habit.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Current: ',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? AppTheme.textMediumDark
                            : AppTheme.textMedium,
                      ),
                    ),
                    Text(
                      '$currentPercent%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: habit.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Area
          SizedBox(
            height: 140, // Slightly taller for better visualization
            child: spots.length < 2
                ? Center(
                    child: Text(
                      'Not enough data',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? AppTheme.textLightDark
                            : AppTheme.textLight,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => isDark
                              ? Colors.black.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.9),
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${(spot.y * 100).toInt()}%',
                                GoogleFonts.inter(
                                  color: habit.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        getTouchedSpotIndicator: (barData, spotIndexes) {
                          return spotIndexes.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: isDark ? Colors.white24 : Colors.black12,
                                strokeWidth: 2,
                                dashArray: [4, 4],
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 6,
                                          color: habit.color,
                                          strokeWidth: 2,
                                          strokeColor: isDark
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                              ),
                            );
                          }).toList();
                        },
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
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: const FlTitlesData(
                        show: false,
                      ), // Clean look requested
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: -0.05, // Slight buffer
                      maxY: 1.05,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: habit.color,
                          gradient: LinearGradient(
                            colors: [
                              habit.color.withValues(alpha: 0.5),
                              habit.color,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) {
                              // Show dot only on the last point
                              return spot.x == barData.spots.last.x;
                            },
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: habit.color,
                                strokeWidth: 2,
                                strokeColor: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                habit.color.withValues(alpha: 0.2),
                                habit.color.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(
                      milliseconds: 400,
                    ), // Implicit animation
                    curve: Curves.easeInOut,
                  ),
          ),

          const SizedBox(height: 12),
          // Footer Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '30 days ago',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                ),
              ),
              Text(
                'Today',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
