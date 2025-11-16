import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/window_controls_bar.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final isDesktop = deviceType == DeviceType.desktop;
    final bool showWindowControls = (isTablet || isDesktop) && !kIsWeb && Platform.isWindows;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundGradientStartDark
          : AppTheme.backgroundGradientStart,
      // Only show AppBar on mobile or non-Windows platforms
      appBar: !showWindowControls ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<HabitList>(
          builder: (context, habitList, child) {
            final habit = habitList.getHabitById(widget.habitId);
            return Text(
              habit?.name ?? 'Habit Details',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            );
          },
        ),
      ) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.backgroundGradientStartDark,
                    AppTheme.backgroundGradientEndDark,
                  ]
                : [
                    AppTheme.backgroundGradientStart,
                    AppTheme.backgroundGradientEnd,
                  ],
          ),
        ),
        child: Column(
          children: [
            // Window controls bar for tablet/desktop Windows
            if (showWindowControls)
              WindowControlsBar(showBackButton: true, showDragIndicator: false),
            
            Expanded(
              child: Consumer<HabitList>(
                builder: (context, habitList, child) {
                  final habit = habitList.getHabitById(widget.habitId);

                  if (habit == null) {
                    return const Center(child: Text('Habit not found'));
                  }

                  // Responsive layout
                  if (isMobile) {
                    return _buildMobileLayout(habit, isDark);
                  } else if (isTablet) {
                    return _buildTabletLayout(habit, isDark);
                  } else {
                    return _buildDesktopLayout(habit, isDark);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile layout (single column)
  Widget _buildMobileLayout(Habit habit, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(habit, isDark, true),
          const SizedBox(height: 20),
          _buildStatsGrid(habit, isDark, 2),
          const SizedBox(height: 20),
          _buildMonthlyChart(habit, isDark),
          const SizedBox(height: 20),
          _buildCalendarHeatmap(habit, isDark),
          const SizedBox(height: 20),
          _buildStreaksSection(habit, isDark),
          const SizedBox(height: 20),
          _buildInsightsSection(habit, isDark),
        ],
      ),
    );
  }

  // Tablet layout (mixed)
  Widget _buildTabletLayout(Habit habit, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(habit, isDark, false),
          const SizedBox(height: 24),
          _buildStatsGrid(habit, isDark, 4),
          const SizedBox(height: 24),
          _buildMonthlyChart(habit, isDark),
          const SizedBox(height: 24),
          _buildCalendarHeatmap(habit, isDark),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStreaksSection(habit, isDark)),
              const SizedBox(width: 16),
              Expanded(child: _buildInsightsSection(habit, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  // Desktop layout (two-column)
  Widget _buildDesktopLayout(Habit habit, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(habit, isDark, false),
          const SizedBox(height: 32),
          _buildStatsGrid(habit, isDark, 4),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildMonthlyChart(habit, isDark),
                    const SizedBox(height: 24),
                    _buildCalendarHeatmap(habit, isDark),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildStreaksSection(habit, isDark),
                    const SizedBox(height: 24),
                    _buildInsightsSection(habit, isDark),
                    const SizedBox(height: 24),
                    _buildTimeAnalysisSection(habit, isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(Habit habit, bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.7)
            : AppTheme.glassBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: habit.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              habit.icon,
              size: isMobile ? 40 : 48,
              color: habit.color,
            ),
          ),
          SizedBox(width: isMobile ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  habit.question ?? 'Track your progress daily',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 14 : 16,
                    color: isDark
                        ? AppTheme.textMediumDark
                        : AppTheme.textMedium,
                  ),
                ),
                if (habit.type == HabitType.measurable) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: habit.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: habit.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.straighten,
                          size: 16,
                          color: habit.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Measured in ${habit.unit}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
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
    );
  }

  Widget _buildStatsGrid(Habit habit, bool isDark, int crossAxisCount) {
    final currentStreak = habit.getCurrentStreak();
    final longestStreak = habit.getLongestStreak();
    final completionRate7 = habit.getCompletionRate(7);
    final completionRate30 = habit.getCompletionRate(30);
    
    // Calculate average for measurable habits
    double? averageValue;
    if (habit.type == HabitType.measurable) {
      final last30Days = List.generate(30, (i) {
        final date = DateTime.now().subtract(Duration(days: i));
        return habit.getValueForDate(date);
      }).where((v) => v != null).toList();
      
      if (last30Days.isNotEmpty) {
        averageValue = last30Days.fold(0.0, (sum, v) => sum + (v as num).toDouble()) / last30Days.length;
      }
    }

    final stats = [
      _StatData(
        'Current',
        '$currentStreak',
        'days',
        Icons.local_fire_department,
        Colors.orange,
      ),
      _StatData(
        'Best',
        '$longestStreak',
        'days',
        Icons.emoji_events,
        Colors.amber,
      ),
      if (habit.type != HabitType.measurable)
        _StatData(
          '7-Day',
          '${(completionRate7 * 100).toInt()}',
          '%',
          Icons.trending_up,
          Colors.green,
        ),
      _StatData(
        '30-Day',
        '${(completionRate30 * 100).toInt()}',
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
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
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
            ? AppTheme.glassBackgroundDark.withOpacity(0.6)
            : AppTheme.glassBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
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
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
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
                          color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
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
                          color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
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

  Widget _buildMonthlyChart(Habit habit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.6)
            : AppTheme.glassBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Monthly Overview',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: habit.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Last 30 days',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: habit.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMonthlyProgressLine(habit, isDark),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgressLine(Habit habit, bool isDark) {
    final now = DateTime.now();
    final days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));
    
    final completionRates = <double>[];
    for (int i = 0; i < days.length; i++) {
      final weekDays = days.sublist(0, i + 1 > 7 ? i + 1 : 7);
      final completed = weekDays.where((d) => habit.isCompletedOn(d)).length;
      completionRates.add(weekDays.isNotEmpty ? completed / weekDays.length : 0);
    }

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: Size.infinite,
            painter: _ProgressLinePainter(
              completionRates: completionRates,
              color: habit.color,
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
    );
  }

  Widget _buildCalendarHeatmap(Habit habit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.6)
            : AppTheme.glassBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Activity Heatmap',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Less',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ...List.generate(5, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: habit.color.withOpacity(0.2 + (i * 0.2)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        'More',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHeatmapGrid(habit, isDark),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(Habit habit, bool isDark) {
    final now = DateTime.now();
    final weeks = 12; // Show 12 weeks
    final startDate = now.subtract(Duration(days: weeks * 7 - 1));

    return Column(
      children: [
        // Week day labels
        Row(
          children: [
            const SizedBox(width: 30),
            ...['Mon', 'Wed', 'Fri'].map((day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 8),
        // Heatmap grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            Column(
              children: ['Mon', '', 'Wed', '', 'Fri', '', 'Sun'].map((label) {
                return SizedBox(
                  height: 16,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 8),
            // Heatmap cells
            Expanded(
              child: SizedBox(
                height: 16 * 7,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: weeks * 7,
                  itemBuilder: (context, index) {
                    final date = startDate.add(Duration(days: index));
                    final isCompleted = habit.isCompletedOn(date);
                    final value = habit.getValueForDate(date);
                    final isFuture = date.isAfter(now);

                    Color cellColor;
                    if (isFuture) {
                      cellColor = Colors.transparent;
                    } else if (habit.type == HabitType.measurable && value != null) {
                      // Calculate intensity based on value
                      final numValue = (value as num).toDouble();
                      // Use a simple normalization (can be improved with actual target)
                      final intensity = (numValue / 100).clamp(0.0, 1.0);
                      cellColor = habit.color.withOpacity(0.3 + (intensity * 0.7));
                    } else if (isCompleted) {
                      cellColor = habit.color.withOpacity(0.8);
                    } else {
                      cellColor = isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: isFuture
                              ? Colors.transparent
                              : (isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1)),
                          width: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreaksSection(Habit habit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.6)
            : AppTheme.glassBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Streaks',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStreakBar(
            'Current Streak',
            habit.getCurrentStreak(),
            habit.getLongestStreak(),
            Colors.orange,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildStreakBar(
            'Longest Streak',
            habit.getLongestStreak(),
            habit.getLongestStreak(),
            Colors.amber,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBar(
    String label,
    int value,
    int maxValue,
    Color color,
    bool isDark,
  ) {
    final percentage = maxValue > 0 ? value / maxValue : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
            Text(
              '$value ${value == 1 ? 'day' : 'days'}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightsSection(Habit habit, bool isDark) {
    final insights = _generateInsights(habit);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.6)
            : AppTheme.glassBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber,
                size: 22,
              ),
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
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      insight.icon,
                      size: 18,
                      color: insight.color,
                    ),
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
              )),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysisSection(Habit habit, bool isDark) {
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
            ? AppTheme.glassBackgroundDark.withOpacity(0.6)
            : AppTheme.glassBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.blue,
                size: 22,
              ),
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
          _buildTimeStat('Days Tracking', '$daysSinceStart days', Icons.event, isDark),
          const SizedBox(height: 12),
          _buildTimeStat('Completion Rate', '${((totalDays / daysSinceStart) * 100).toInt()}%', Icons.percent, isDark),
          const SizedBox(height: 12),
          _buildTimeStat('Started', DateFormat('MMM d, yyyy').format(firstDate), Icons.calendar_today, isDark),
        ],
      ),
    );
  }

  Widget _buildTimeStat(String label, String value, IconData icon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
      ],
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
        insights.add(_Insight(
          '🔥 Amazing! You\'re on your best streak ever!',
          Icons.celebration,
          Colors.orange,
        ));
      } else if (currentStreak >= 7) {
        insights.add(_Insight(
          'Great job! ${currentStreak} days streak and counting!',
          Icons.trending_up,
          Colors.green,
        ));
      }
    } else {
      insights.add(_Insight(
        'Start building your streak today!',
        Icons.flag,
        Colors.blue,
      ));
    }

    // Consistency insights
    if (rate7 >= 0.85) {
      insights.add(_Insight(
        'Excellent consistency this week!',
        Icons.star,
        Colors.amber,
      ));
    } else if (rate7 < 0.5 && rate30 >= 0.7) {
      insights.add(_Insight(
        'Your consistency has dropped this week. Get back on track!',
        Icons.info_outline,
        Colors.orange,
      ));
    }

    // Progress insights
    if (rate30 >= 0.8) {
      insights.add(_Insight(
        'Outstanding! 80%+ completion this month.',
        Icons.workspace_premium,
        Colors.purple,
      ));
    } else if (rate30 >= 0.5) {
      insights.add(_Insight(
        'Good progress! Keep pushing to reach 80%.',
        Icons.thumb_up,
        Colors.blue,
      ));
    }

    // Longest streak motivation
    if (longestStreak >= 30) {
      insights.add(_Insight(
        'You\'ve proven you can maintain habits long-term!',
        Icons.emoji_events,
        Colors.amber,
      ));
    }

    if (insights.isEmpty) {
      insights.add(_Insight(
        'Start tracking today to build your habit!',
        Icons.rocket_launch,
        habit.color,
      ));
    }

    return insights;
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

class _Insight {
  final String text;
  final IconData icon;
  final Color color;

  _Insight(this.text, this.icon, this.color);
}

class _ProgressLinePainter extends CustomPainter {
  final List<double> completionRates;
  final Color color;
  final bool isDark;

  _ProgressLinePainter({
    required this.completionRates,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (completionRates.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    
    fillPath.moveTo(0, size.height);

    for (int i = 0; i < completionRates.length; i++) {
      final x = (size.width / (completionRates.length - 1)) * i;
      final y = size.height - (completionRates[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < completionRates.length; i++) {
      final x = (size.width / (completionRates.length - 1)) * i;
      final y = size.height - (completionRates[i] * size.height);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
