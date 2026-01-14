import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_habit_config.dart';

/// A single habit row showing icon, name, and fixed visible day columns.
///
/// Optimized: No internal ScrollController - receives pre-computed visible dates.
class HabitRow extends StatefulWidget {
  final Habit habit;
  final List<DateTime> visibleDates;
  final Function(DateTime) onDayTap;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onLongPress;
  final Function(int)? onScroll;

  const HabitRow({
    Key? key,
    required this.habit,
    required this.visibleDates,
    required this.onDayTap,
    this.onTap,
    this.onEdit,
    this.onArchive,
    this.onLongPress,
    this.onScroll,
  }) : super(key: key);

  @override
  State<HabitRow> createState() => _HabitRowState();
}

class _HabitRowState extends State<HabitRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.glassBackgroundDark.withValues(alpha: 0.6)
              : AppTheme.glassBackground.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Habit icon with colored background
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.habit.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.habit.icon,
                      color: widget.habit.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Habit name and type indicator - Fixed width to match header
                  SizedBox(
                    width: ResponsiveHabitConfig.habitInfoMinWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.habit.name,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textDarkMode
                                : AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.habit.type == HabitType.measurable) ...[
                          const SizedBox(height: 1),
                          Text(
                            widget.habit.unit,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: isDark
                                  ? AppTheme.textLightDark
                                  : AppTheme.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12), // Match header spacing
                  // Date cells OR Unarchive button
                  Expanded(
                    flex: 3,
                    child: widget.habit.isArchived
                        ? Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: widget.onArchive,
                                icon: const Icon(
                                  Icons.unarchive_outlined,
                                  size: 20,
                                ),
                                tooltip: "Unarchive",
                                style: IconButton.styleFrom(
                                  foregroundColor: widget.habit.color,
                                  backgroundColor: widget.habit.color
                                      .withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Listener(
                            onPointerSignal: (event) {
                              if (event is PointerScrollEvent &&
                                  widget.onScroll != null) {
                                // Scroll right (positive) = older dates, left (negative) = newer dates
                                final delta = event.scrollDelta.dx != 0
                                    ? event.scrollDelta.dx
                                    : event.scrollDelta.dy;
                                if (delta > 0) {
                                  // Scroll down/right = show older dates
                                  widget.onScroll!(1);
                                } else if (delta < 0) {
                                  // Scroll up/left = show newer dates
                                  widget.onScroll!(-1);
                                }
                              }
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: RepaintBoundary(
                                child: ClipRect(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SizedBox(
                                        width: constraints.maxWidth,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: widget.visibleDates.map((
                                              date,
                                            ) {
                                              return _buildDayCell(
                                                date,
                                                isDark,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, bool isDark) {
    final value = widget.habit.getValueForDate(date);
    final isToday = ResponsiveHabitConfig.isToday(date);

    Color cellColor;
    Widget cellContent;

    if (widget.habit.type == HabitType.boolean) {
      // Boolean habit: checkmark or X
      if (value == true) {
        cellColor = widget.habit.color;
        cellContent = const Icon(Icons.check, size: 14, color: Colors.white);
      } else if (value == false) {
        cellColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        cellContent = Icon(
          Icons.close,
          size: 14,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
        );
      } else {
        // Not tracked yet
        cellColor = isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05);
        cellContent = const SizedBox.shrink();
      }
    } else {
      // Measurable habit: show value
      if (value is num && value > 0) {
        final intensity = value.clamp(0, 100) / 100;
        cellColor = widget.habit.color.withValues(
          alpha: 0.2 + (intensity * 0.8),
        );
        cellContent = Text(
          '${value.toInt()}',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: intensity > 0.5 ? Colors.white : widget.habit.color,
          ),
        );
      } else if (value == true) {
        // Boolean value from when habit was boolean type
        cellColor = widget.habit.color;
        cellContent = const Icon(Icons.check, size: 14, color: Colors.white);
      } else {
        cellColor = isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05);
        cellContent = const SizedBox.shrink();
      }
    }

    return GestureDetector(
      onTap: () => widget.onDayTap(date),
      child: Container(
        width: ResponsiveHabitConfig.cellSize,
        height: ResponsiveHabitConfig.cellSize,
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHabitConfig.cellMargin,
        ),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: widget.habit.color, width: 1.5)
              : null,
        ),
        child: Center(child: cellContent),
      ),
    );
  }
}
