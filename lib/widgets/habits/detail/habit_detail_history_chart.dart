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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppTheme.glassBackgroundDark.withValues(alpha: 0.6)
            : AppTheme.glassBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
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
          SizedBox(height: 350, child: _buildBarChart()),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    // 1. Prepare Data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Map of Date -> Value (Count or Sum)
    final Map<DateTime, double> chartData = {};
    DateTime from;
    String tooltipDateFormat;
    bool isMonthlyAgg = false;

    switch (_period) {
      case HistoryPeriod.week:
        // Last 7 days
        from = today.subtract(const Duration(days: 6));
        tooltipDateFormat = 'MMM d';
        for (int i = 0; i < 7; i++) {
          final date = today.subtract(Duration(days: 6 - i));
          chartData[date] = _getDailyValue(date);
        }
        break;

      case HistoryPeriod.days: // Month view (Daily bars)
        // Last 30 days
        from = today.subtract(const Duration(days: 29));
        tooltipDateFormat = 'MMM d';
        for (int i = 0; i < 30; i++) {
          final date = today.subtract(Duration(days: 29 - i));
          chartData[date] = _getDailyValue(date);
        }
        break;

      case HistoryPeriod.months: // Year view (Monthly bars)
        // Last 12 months
        from = DateTime(
          today.year - 1,
          today.month + 1,
          1,
        ); // Start of calc 1 yr ago
        tooltipDateFormat = 'MMMM yyyy';
        isMonthlyAgg = true;

        // Iterate last 12 months
        for (int i = 11; i >= 0; i--) {
          final monthStart = DateTime(today.year, today.month - i, 1);
          // Sum up counts for this month
          double monthTotal = 0;
          final daysInMonth = DateUtils.getDaysInMonth(
            monthStart.year,
            monthStart.month,
          );
          for (int d = 1; d <= daysInMonth; d++) {
            final date = DateTime(monthStart.year, monthStart.month, d);
            if (date.isAfter(today)) break;
            monthTotal += _getDailyValue(date);
          }
          chartData[monthStart] = monthTotal;
        }
        break;
    }

    final sortedEntries = chartData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty || sortedEntries.every((e) => e.value == 0)) {
      // Show empty chart placeholder or just empty chart?
      // Keeping chart but empty is better so layout doesn't jump
    }

    // 2. Determine Max Y for scaling
    double maxY = 0;
    for (var e in sortedEntries) {
      // Corrected from chatData.values
      if (e.value > maxY) maxY = e.value;
    }
    // Add some padding to top
    if (maxY == 0) maxY = 1;

    // Adjust maxY for "visual breathing room"
    double topY = maxY * 1.2;
    // For counts (integers), ensure topY is at least slightly higher
    if (topY < maxY + 1) topY = maxY + 1;

    // 3. Interval
    int labelInterval = 1;
    if (_period == HistoryPeriod.days) labelInterval = 5;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        maxY: topY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => widget.isDark
                ? Colors.black.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = sortedEntries[groupIndex].key;
              final dateStr = DateFormat(tooltipDateFormat).format(date);
              final val = rod.toY;
              final valStr = val % 1 == 0
                  ? val.toInt().toString()
                  : val.toStringAsFixed(1);

              return BarTooltipItem(
                '$dateStr\n',
                GoogleFonts.inter(
                  color: widget.isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'Count: $valStr',
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
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedEntries.length)
                  return const SizedBox.shrink();

                final val = sortedEntries[index].value;
                if (val == 0)
                  return const SizedBox.shrink(); // Hide 0 labels? Or show?

                // Only show label if it doesn't overlap excessively?
                // Simple logic: Show all (fl_chart handles some collision, or we can skip)
                if (_period == HistoryPeriod.days && index % 2 != 0)
                  return const SizedBox.shrink(); // Reduce clutter for Days view

                return Text(
                  val % 1 == 0
                      ? val.toInt().toString()
                      : val.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    color: widget.habit.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedEntries.length)
                  return const SizedBox.shrink();

                final date = sortedEntries[index].key;
                String text = '';
                bool showLabel = false;

                if (_period == HistoryPeriod.months) {
                  // Month label
                  text = DateFormat('MMM').format(date);
                  showLabel = true;
                  // Year change? (e.g. show Year if Jan?)
                  if (date.month == 1) {
                    text += "\n${date.year}";
                  }
                } else if (_period == HistoryPeriod.days) {
                  if (index % 5 == 0) {
                    text = DateFormat('d').format(date);
                    showLabel = true;
                  }
                } else {
                  // Week
                  text = DateFormat('E').format(date);
                  showLabel = true;
                }

                if (!showLabel) return const SizedBox.shrink();

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
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: topY / 4, // 4 grid lines?
          getDrawingHorizontalLine: (value) => FlLine(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: sortedEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final val = entry.value.value;

          double rodWidth = 12;
          if (_period == HistoryPeriod.week) rodWidth = 20;
          if (_period == HistoryPeriod.days) rodWidth = 6;
          if (_period == HistoryPeriod.months) rodWidth = 12;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: val,
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
                  toY: topY,
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

  double _getDailyValue(DateTime date) {
    final val = widget.habit.getValueForDate(date);
    if (val == true) return 1.0;
    if (val is num) return val.toDouble();
    return 0.0;
  }
}
