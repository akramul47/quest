import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailMonthlyChart extends StatefulWidget {
  final Habit habit;
  final bool isDark;
  final bool isMobile;

  const HabitDetailMonthlyChart({
    Key? key,
    required this.habit,
    required this.isDark,
    this.isMobile = false,
  }) : super(key: key);

  @override
  State<HabitDetailMonthlyChart> createState() =>
      _HabitDetailMonthlyChartState();
}

class _HabitDetailMonthlyChartState extends State<HabitDetailMonthlyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      // Custom curve: slow, smooth, and relaxing at the end
      curve: const Cubic(0.22, 0.61, 0.36, 1.0), // Similar to easeOutQuint
    );
    // Start animation after page loads completely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    // Replay animation on hover with smooth pace
    _animationController.duration = const Duration(milliseconds: 800);
    _animationController.forward(from: 0);
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    // Reset duration for next entry animation
    _animationController.duration = const Duration(milliseconds: 1500);
  }

  @override
  Widget build(BuildContext context) {
    final stats = HabitStatisticsService.instance;
    final scoreHistory = stats.getScoreHistory(widget.habit, 30);
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

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate how many points to show based on animation progress
          final progress = _animation.value;
          final visibleCount = (progress * spots.length).ceil();

          // Build animated spots - show only up to current progress
          List<FlSpot> animatedSpots = [];
          if (spots.isNotEmpty && visibleCount > 0) {
            // Add all fully visible spots
            for (int i = 0; i < visibleCount - 1 && i < spots.length; i++) {
              animatedSpots.add(spots[i]);
            }

            // Add the interpolated last point (the traveling dot position)
            if (visibleCount <= spots.length) {
              final lastFullIndex = visibleCount - 1;
              final fractionalProgress =
                  (progress * spots.length) - lastFullIndex;

              if (lastFullIndex < spots.length) {
                if (lastFullIndex == 0 || fractionalProgress >= 1.0) {
                  // Just add the point as is
                  animatedSpots.add(spots[lastFullIndex]);
                } else if (lastFullIndex > 0) {
                  // Interpolate between previous and current point
                  final prevSpot = spots[lastFullIndex - 1];
                  final currSpot = spots[lastFullIndex];
                  final interpX =
                      prevSpot.x +
                      (currSpot.x - prevSpot.x) * fractionalProgress;
                  final interpY =
                      prevSpot.y +
                      (currSpot.y - prevSpot.y) * fractionalProgress;
                  animatedSpots.add(FlSpot(interpX, interpY));
                }
              }
            }
          }

          // Ensure we have at least 2 points for the line
          if (animatedSpots.length < 2 && spots.length >= 2) {
            animatedSpots = [spots[0]];
            if (progress > 0) {
              final interpX =
                  spots[0].x +
                  (spots[1].x - spots[0].x) *
                      (progress * spots.length).clamp(0.0, 1.0);
              final interpY =
                  spots[0].y +
                  (spots[1].y - spots[0].y) *
                      (progress * spots.length).clamp(0.0, 1.0);
              animatedSpots.add(FlSpot(interpX, interpY));
            } else {
              animatedSpots.add(spots[0]);
            }
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
            padding: const EdgeInsets.all(20),
            // Glass morphism style matching history chart
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppTheme.glassBackgroundDark.withValues(alpha: 0.6)
                  : AppTheme.glassBackground.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? widget.habit.color.withValues(alpha: 0.3)
                    : (widget.isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.3)),
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.habit.color.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
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
                          color: widget.isDark
                              ? AppTheme.textMediumDark
                              : AppTheme.textMedium,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Progress',
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
                    // Current Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.habit.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.habit.color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$currentPercent%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.habit.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Chart Area
                SizedBox(
                  height: widget.isMobile ? 140 : 250, // Responsive height
                  child: animatedSpots.length < 2
                      ? Center(
                          child: Text(
                            'Not enough data',
                            style: GoogleFonts.inter(
                              color: widget.isDark
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
                                getTooltipColor: (_) => widget.isDark
                                    ? Colors.black.withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.9),
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 8,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    // Use original values for tooltip
                                    final originalY = spots
                                        .firstWhere(
                                          (s) => s.x == spot.x,
                                          orElse: () => spot,
                                        )
                                        .y;
                                    return LineTooltipItem(
                                      '${(originalY * 100).toInt()}%',
                                      GoogleFonts.inter(
                                        color: widget.habit.color,
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
                                      color: widget.isDark
                                          ? Colors.white24
                                          : Colors.black12,
                                      strokeWidth: 2,
                                      dashArray: [4, 4],
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                                radius: 6,
                                                color: widget.habit.color,
                                                strokeWidth: 2,
                                                strokeColor: widget.isDark
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
                                color: widget.isDark
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
                                spots: animatedSpots,
                                isCurved: true,
                                curveSmoothness: 0.35,
                                color: widget.habit.color,
                                gradient: LinearGradient(
                                  colors: [
                                    widget.habit.color.withValues(alpha: 0.5),
                                    widget.habit.color,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  checkToShowDot: (spot, barData) {
                                    // Show dot on the last visible point (traveling dot)
                                    return spot.x == barData.spots.last.x;
                                  },
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 5,
                                          color: widget.habit.color,
                                          strokeWidth: 2,
                                          strokeColor: widget.isDark
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
                                      widget.habit.color.withValues(
                                        alpha: 0.2 * _animation.value,
                                      ),
                                      widget.habit.color.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                        color: widget.isDark
                            ? AppTheme.textLightDark
                            : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      'Today',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? AppTheme.textMediumDark
                            : AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
