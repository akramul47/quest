import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';

class HabitDetailHeatmap extends StatefulWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailHeatmap({
    Key? key,
    required this.habit,
    required this.isDark,
  }) : super(key: key);

  @override
  State<HabitDetailHeatmap> createState() => _HabitDetailHeatmapState();
}

class _HabitDetailHeatmapState extends State<HabitDetailHeatmap> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Activity Heatmap',
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
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Less',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: widget.isDark
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
                          color: widget.habit.color.withValues(
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
                        color: widget.isDark
                            ? AppTheme.textLightDark
                            : AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return _buildResponsiveHeatmap(
                  widget.habit,
                  widget.isDark,
                  constraints.maxWidth,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHeatmap(
    Habit habit,
    bool isDark,
    double availableWidth,
  ) {
    // Calculate how many weeks can fit
    const cellSize = 13.0;
    const cellSpacing = 4.0;
    const dayLabelWidth = 30.0;

    // Increased buffer from 8 to 12 to prevent cut-off
    final usableWidth = availableWidth - dayLabelWidth - 12;
    // Calculate exact number of weeks that can fit, allowing up to 53 weeks (full year + 1)
    // No minimum clamp helps on very small screens, max 53 covers a year
    final weeksToShow = (usableWidth / (cellSize + cellSpacing)).floor().clamp(
      1,
      53,
    );

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: weeksToShow * 7 - 1));

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Day labels (left side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 14), // Space for month header alignment
                ...['Mon', '', 'Wed', '', 'Fri', '', 'Sun'].map((label) {
                  return SizedBox(
                    height: cellSize, // Match cell height
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: isDark
                              ? AppTheme.textLightDark
                              : AppTheme.textLight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            const SizedBox(width: 8),
            // Heatmap (right-aligned)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Start from right
                padding: const EdgeInsets.only(
                  right: 2,
                ), // Prevent edge clipping
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, // Hug content
                  children: List.generate(weeksToShow, (weekIndex) {
                    final weekStart = startDate.add(
                      Duration(days: weekIndex * 7),
                    );
                    final prevWeekStart = startDate.add(
                      Duration(days: (weekIndex - 1) * 7),
                    );

                    bool showMonth = false;
                    if (weekIndex == 0) {
                      showMonth = true;
                    } else if (weekStart.month != prevWeekStart.month) {
                      showMonth = true;
                    }

                    // Don't show if it's too close to the end and fits awkwardly?
                    // No, showing adjacent months is fine.

                    String monthLabel = "";
                    if (showMonth) {
                      const months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ];
                      monthLabel = months[weekStart.month - 1];
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        left: weekIndex == 0 ? 0 : cellSpacing,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Month Header
                          Container(
                            height: 14,
                            width:
                                cellSize, // Constrain width to prevent column expansion
                            alignment: Alignment.bottomLeft,
                            child: showMonth
                                ? Text(
                                    monthLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppTheme.textMediumDark
                                          : AppTheme.textMedium,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.visible,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 4),
                          // Cells
                          ...List.generate(7, (dayIndex) {
                            final date = weekStart.add(
                              Duration(days: dayIndex),
                            );
                            final isCompleted = habit.isCompletedOn(date);
                            final value = habit.getValueForDate(date);
                            final isFuture = date.isAfter(now);

                            Color cellColor;
                            if (isFuture) {
                              cellColor = Colors.transparent;
                            } else if (habit.type == HabitType.measurable &&
                                value != null &&
                                value is num) {
                              final numValue = value.toDouble();
                              final intensity = (numValue / 100).clamp(
                                0.0,
                                1.0,
                              );
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
                              margin: EdgeInsets.only(
                                bottom: dayIndex < 6 ? cellSpacing : 0,
                              ),
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: isFuture
                                      ? Colors.transparent
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.1,
                                              )),
                                  width: 0.5,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
