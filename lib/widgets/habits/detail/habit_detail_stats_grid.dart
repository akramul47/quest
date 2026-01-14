import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailStatsGrid extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailStatsGrid({
    Key? key,
    required this.habit,
    required this.isDark,
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
        'Streak', // Renamed 'Current' to 'Streak' for clarity if allowed, or keep 'Current'. User said 'streak'.
        '${summary.currentStreak}',
        'days',
        Icons.local_fire_department,
        Colors.orange,
      ),
      _StatData(
        '30-Day',
        '${(summary.monthlyRate * 100).toInt()}',
        '%',
        Icons.analytics,
        Colors.blue,
      ),
    ];

    final statsCards = statsList.asMap().entries.map((entry) {
      final stat = entry.value;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: entry.key < statsList.length - 1 ? 8.0 : 0,
          ),
          child: _PremiumStatCard(
            label: stat.label,
            value: stat.value,
            unit: stat.unit,
            icon: stat.icon,
            color: stat.color,
            isDark: isDark,
          ),
        ),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statsCards,
    );
  }
}

class _PremiumStatCard extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _PremiumStatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  State<_PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<_PremiumStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? [
                    AppTheme.glassBackgroundDark.withValues(alpha: 0.7),
                    AppTheme.glassBackgroundDark.withValues(alpha: 0.5),
                  ]
                : [
                    AppTheme.glassBackground.withValues(alpha: 0.8),
                    AppTheme.glassBackground.withValues(alpha: 0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.3)
                : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.3)),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: widget.isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(_isHovered ? 8 : 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.color.withValues(alpha: 0.2),
                    widget.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: _isHovered ? 24 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.value,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark
                              ? AppTheme.textDarkMode
                              : AppTheme.textDark,
                          height: 1,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          widget.unit,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: widget.isDark
                                ? AppTheme.textLightDark
                                : AppTheme.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? AppTheme.textLightDark
                          : AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
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
