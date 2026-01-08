import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';

class HabitDetailHeatmap extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailHeatmap({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          color: isDark
                              ? AppTheme.textLightDark
                              : AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ...List.generate(5, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: habit.color.withValues(
                              alpha: 0.2 + (i * 0.2),
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        'More',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isDark
                              ? AppTheme.textLightDark
                              : AppTheme.textLight,
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
            ...['Mon', 'Wed', 'Fri'].map(
              (day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                  ),
                ),
              ),
            ),
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
                      color: isDark
                          ? AppTheme.textLightDark
                          : AppTheme.textLight,
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
                    } else if (habit.type == HabitType.measurable &&
                        value != null) {
                      // Calculate intensity based on value
                      final numValue = (value as num).toDouble();
                      // Use a simple normalization (can be improved with actual target)
                      final intensity = (numValue / 100).clamp(0.0, 1.0);
                      cellColor = habit.color.withValues(
                        alpha: 0.3 + (intensity * 0.7),
                      );
                    } else if (isCompleted) {
                      cellColor = habit.color.withValues(alpha: 0.8);
                    } else {
                      cellColor = isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: isFuture
                              ? Colors.transparent
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1)),
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
}
