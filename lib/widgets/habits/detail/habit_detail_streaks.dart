import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';
import '../../../services/habit_statistics_service.dart';

class HabitDetailStreaks extends StatefulWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailStreaks({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  State<HabitDetailStreaks> createState() => _HabitDetailStreaksState();
}

class _HabitDetailStreaksState extends State<HabitDetailStreaks> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final stats = HabitStatisticsService.instance;
    final bestStreaks = stats.getBestStreaks(widget.habit, limit: 3);
    final currentStreak = stats.getCurrentStreak(widget.habit);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
        padding: const EdgeInsets.all(20),
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
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Best Streaks',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? AppTheme.textDarkMode
                          : AppTheme.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (bestStreaks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No streaks yet',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: widget.isDark
                          ? AppTheme.textLightDark
                          : AppTheme.textLight,
                    ),
                  ),
                ),
              )
            else
              ...bestStreaks.asMap().entries.map((entry) {
                final index = entry.key;
                final streak = entry.value;
                final isActive =
                    currentStreak != null &&
                    streak.start == currentStreak.start &&
                    streak.end == currentStreak.end;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < bestStreaks.length - 1 ? 12 : 0,
                  ),
                  child: _buildStreakItem(streak, isActive, widget.isDark),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(dynamic streak, bool isActive, bool isDark) {
    final dateFormat = DateFormat('MMM d, y');
    final startStr = dateFormat.format(streak.start);
    final endStr = dateFormat.format(streak.end);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.habit.color.withValues(alpha: 0.15),
                  widget.habit.color.withValues(alpha: 0.05),
                ],
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 0.3),
                      ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? widget.habit.color.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.2)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? widget.habit.color.withValues(alpha: 0.15)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.local_fire_department : Icons.emoji_events,
              color: isActive ? widget.habit.color : Colors.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${streak.length} ${streak.length == 1 ? 'day' : 'days'}',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.textDarkMode
                              : AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: widget.habit.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.habit.color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: widget.habit.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      startStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textMediumDark
                            : AppTheme.textMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: isDark
                            ? AppTheme.textLightDark
                            : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      endStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textMediumDark
                            : AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
