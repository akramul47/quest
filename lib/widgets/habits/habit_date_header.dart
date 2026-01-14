import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_habit_config.dart';

/// Optimized date header that renders only visible columns.
///
/// Uses fixed-width rendering instead of ScrollController for better performance.
/// Supports mouse wheel scrolling on desktop/web for date navigation.
class HabitDateHeader extends StatelessWidget {
  final List<DateTime> visibleDates;
  final bool isDark;
  final int dataOffset;
  final void Function(int delta)? onScroll; // Called with scroll delta

  const HabitDateHeader({
    Key? key,
    required this.visibleDates,
    required this.isDark,
    this.dataOffset = 0,
    this.onScroll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withOpacity(0.4)
            : AppTheme.glassBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Spacer for icon + habit name column (fixed width instead of flex)
          const SizedBox(width: 44),

          // Habit name section - use minimum needed width
          SizedBox(
            width: ResponsiveHabitConfig.habitInfoMinWidth,
            child: const SizedBox(), // Space for habit names
          ),

          const SizedBox(
            width: 12,
          ), // Reduced from 6 to 12 for better separation
          // Fixed-width date cells with mouse wheel support
          Expanded(
            flex: 3,
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent && onScroll != null) {
                  // Scroll right (positive) = older dates, left (negative) = newer dates
                  final delta = event.scrollDelta.dx != 0
                      ? event.scrollDelta.dx
                      : event.scrollDelta.dy;
                  if (delta > 0) {
                    // Scroll down/right = show older dates
                    onScroll!(1);
                  } else if (delta < 0 && dataOffset > 0) {
                    // Scroll up/left = show newer dates (but not past today)
                    onScroll!(-1);
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
                            physics: const NeverScrollableScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: visibleDates.map((date) {
                                return _DateCell(date: date, isDark: isDark);
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
    );
  }
}

/// Individual date cell widget - extracted for potential const optimization.
class _DateCell extends StatelessWidget {
  final DateTime date;
  final bool isDark;

  const _DateCell({required this.date, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isToday = ResponsiveHabitConfig.isToday(date);

    return Container(
      width: ResponsiveHabitConfig.cellSize,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHabitConfig.cellMargin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('E').format(date).substring(0, 1),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              color: isToday
                  ? (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                  : (isDark ? AppTheme.textLightDark : AppTheme.textLight),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('d').format(date),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
              color: isToday
                  ? (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                  : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
            ),
          ),
        ],
      ),
    );
  }
}
