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
import '../widgets/habits/detail/habit_detail_overview_card.dart';
import '../widgets/habits/detail/habit_detail_stats_grid.dart';
import '../widgets/habits/detail/habit_detail_monthly_chart.dart';
import '../widgets/habits/detail/habit_detail_heatmap.dart';
import '../widgets/habits/detail/habit_detail_streaks.dart';
import '../widgets/habits/detail/habit_detail_insights.dart';
import '../widgets/habits/detail/habit_detail_time_analysis.dart';

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
    final bool showWindowControls =
        (isTablet || isDesktop) && !kIsWeb && Platform.isWindows;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundGradientStartDark
          : AppTheme.backgroundGradientStart,
      // Only show AppBar on mobile or non-Windows platforms
      appBar: !showWindowControls
          ? AppBar(
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
            )
          : null,
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
          HabitDetailOverviewCard(habit: habit, isDark: isDark, isMobile: true),
          const SizedBox(height: 20),
          HabitDetailStatsGrid(habit: habit, isDark: isDark, crossAxisCount: 2),
          const SizedBox(height: 20),
          HabitDetailMonthlyChart(habit: habit, isDark: isDark),
          const SizedBox(height: 20),
          HabitDetailHeatmap(habit: habit, isDark: isDark),
          const SizedBox(height: 20),
          HabitDetailStreaks(habit: habit, isDark: isDark),
          const SizedBox(height: 20),
          HabitDetailInsights(habit: habit, isDark: isDark),
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
          HabitDetailOverviewCard(
            habit: habit,
            isDark: isDark,
            isMobile: false,
          ),
          const SizedBox(height: 24),
          HabitDetailStatsGrid(habit: habit, isDark: isDark, crossAxisCount: 4),
          const SizedBox(height: 24),
          HabitDetailMonthlyChart(habit: habit, isDark: isDark),
          const SizedBox(height: 24),
          HabitDetailHeatmap(habit: habit, isDark: isDark),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HabitDetailStreaks(habit: habit, isDark: isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HabitDetailInsights(habit: habit, isDark: isDark),
              ),
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
          HabitDetailOverviewCard(
            habit: habit,
            isDark: isDark,
            isMobile: false,
          ),
          const SizedBox(height: 32),
          HabitDetailStatsGrid(habit: habit, isDark: isDark, crossAxisCount: 4),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    HabitDetailMonthlyChart(habit: habit, isDark: isDark),
                    const SizedBox(height: 24),
                    HabitDetailHeatmap(habit: habit, isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    HabitDetailStreaks(habit: habit, isDark: isDark),
                    const SizedBox(height: 24),
                    HabitDetailInsights(habit: habit, isDark: isDark),
                    const SizedBox(height: 24),
                    HabitDetailTimeAnalysis(habit: habit, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
