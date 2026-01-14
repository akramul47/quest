import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

enum HistoryPeriod { week, days, months }

class HabitDetailHistoryChart extends StatefulWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailHistoryChart({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  State<HabitDetailHistoryChart> createState() =>
      _HabitDetailHistoryChartState();
}

class _HabitDetailHistoryChartState extends State<HabitDetailHistoryChart> {
  HistoryPeriod _period = HistoryPeriod.days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppTheme.glassBackgroundDark.withValues(alpha: 0.6)
            : AppTheme.glassBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: widget.isDark
                        ? AppTheme.textMediumDark
                        : AppTheme.textMedium,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'History',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? AppTheme.textDarkMode
                          : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              // Dropdown
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: widget.habit.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<HistoryPeriod>(
                    value: _period,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.habit.color,
                      size: 16,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.habit.color,
                    ),
                    dropdownColor: widget.isDark
                        ? const Color(0xFF2C2C2C)
                        : Colors.white,
                    isDense: true,
                    items: const [
                      DropdownMenuItem(
                        value: HistoryPeriod.week,
                        child: Text('Week'),
                      ),
                      DropdownMenuItem(
                        value: HistoryPeriod.days,
                        child: Text('Month'),
                      ),
                      DropdownMenuItem(
                        value: HistoryPeriod.months,
                        child: Text('Year'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _period = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final stats = HabitStatisticsService.instance;
    Map<DateTime, double> history;
    String tooltipFormat;
    String axisFormat;

    switch (_period) {
      case HistoryPeriod.week:
        // Compute raw completion for last 7 days
        history = {};
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        for (int i = 0; i < 7; i++) {
          final date = today.subtract(Duration(days: 6 - i));
          final val = widget.habit.getValueForDate(date);
          double dVal = 0.0;
          if (val == true) {
            dVal = 1.0;
          } else if (val is num && val > 0) {
            dVal = 1.0;
          }
          history[date] = dVal;
        }
        tooltipFormat = 'MMM d, yyyy';
        axisFormat = 'E'; // Show day name (Mon, Tue)
        break;
      case HistoryPeriod.days:
        // Compute raw completion for last 30 days (0 or 1) to match Frequency view
        history = {};
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        for (int i = 0; i < 30; i++) {
          final date = today.subtract(Duration(days: 29 - i));
          final val = widget.habit.getValueForDate(date);
          double dVal = 0.0;
          if (val == true) {
            dVal = 1.0;
          } else if (val is num && val > 0) {
            dVal = 1.0; // Treat any progress as 'active' for frequency bar
          }
          history[date] = dVal;
        }
        tooltipFormat = 'MMM d, yyyy';
        axisFormat = 'd';
        break;
      case HistoryPeriod.months:
        history = stats.getCompletionByMonth(widget.habit, 12);
        tooltipFormat = 'MMMM yyyy';
        axisFormat = 'MMM';
        break;
    }

    final sortedEntries = history.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) {
      return Center(
        child: Text(
          'No history yet',
          style: GoogleFonts.inter(
            color: widget.isDark ? AppTheme.textLightDark : AppTheme.textLight,
          ),
        ),
      );
    }

    // Determine interval for axis labels to avoid overlapping
    int labelInterval = 1;
    if (_period == HistoryPeriod.days) labelInterval = 5; // Every 5 days

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween, // Distribute evenly
        maxY: 1.0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => widget.isDark
                ? Colors.black.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = sortedEntries[groupIndex].key;
              final dateStr = DateFormat(tooltipFormat).format(date);
              final value = (rod.toY * 100).toInt();
              return BarTooltipItem(
                '$dateStr\n',
                GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '$value% Completed',
                    style: GoogleFonts.inter(
                      color: widget.habit.color,
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
              reservedSize: 30, // Make room for labels
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedEntries.length) {
                  return const SizedBox.shrink();
                }

                // Skip labels based on interval
                if (index % labelInterval != 0) return const SizedBox.shrink();

                final date = sortedEntries[index].key;
                String text;
                if (_period == HistoryPeriod.months) {
                  text = DateFormat('MMM').format(date);
                } else if (_period == HistoryPeriod.week) {
                  text = DateFormat('E').format(date)[0]; // M, T, W...
                } else {
                  text = DateFormat('d MMM').format(date);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      color: widget.isDark
                          ? AppTheme.textLightDark
                          : AppTheme.textLight,
                      fontSize: 10,
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
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            strokeWidth: 1,
            dashArray: [4, 4], // Dashed grid lines
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: sortedEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value.value.clamp(0.0, 1.0);

          // Dynamic width based on count
          double rodWidth = 12;
          if (_period == HistoryPeriod.week) rodWidth = 24;
          if (_period == HistoryPeriod.days) rodWidth = 6;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    widget.habit.color.withValues(alpha: 0.7),
                    widget.habit.color,
                  ],
                ),
                width: rodWidth,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 1.0,
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.black.withValues(alpha: 0.02),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
