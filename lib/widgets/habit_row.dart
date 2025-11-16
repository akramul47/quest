import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../Utils/app_theme.dart';

/// A single habit row showing icon, name, and a week of tracking cells
/// with smooth fade-in animation
class HabitRow extends StatefulWidget {
  final Habit habit;
  final List<DateTime> weekDates;
  final Function(DateTime) onDayTap;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final ScrollController? scrollController;

  const HabitRow({
    Key? key,
    required this.habit,
    required this.weekDates,
    required this.onDayTap,
    this.onTap,
    this.onEdit,
    this.onArchive,
    this.scrollController,
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
              ? AppTheme.glassBackgroundDark.withOpacity(0.6)
              : AppTheme.glassBackground.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
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
                      color: widget.habit.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.habit.icon,
                      color: widget.habit.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Habit name and type indicator - Flexible width
                  Expanded(
                    flex: 2,
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

                  const SizedBox(width: 6),

                  // Date cells - infinitely scrollable
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      controller: widget.scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.weekDates.map((date) {
                          return _buildDayCell(date, isDark, context);
                        }).toList(),
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

  Widget _buildDayCell(DateTime date, bool isDark, BuildContext context) {
    final value = widget.habit.getValueForDate(date);
    final isToday = _isToday(date);

    Color cellColor;
    Widget cellContent;

    if (widget.habit.type == HabitType.boolean) {
      // Boolean habit: checkmark or X
      if (value == true) {
        cellColor = widget.habit.color;
        cellContent = Icon(
          Icons.check,
          size: 14,
          color: Colors.white,
        );
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
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05);
        cellContent = const SizedBox.shrink();
      }
    } else {
      // Measurable habit: show value
      if (value != null && value > 0) {
        final intensity = (value as num).clamp(0, 100) / 100;
        cellColor = widget.habit.color.withOpacity(0.2 + (intensity * 0.8));
        cellContent = Text(
          '${value.toInt()}',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: intensity > 0.5 ? Colors.white : widget.habit.color,
          ),
        );
      } else {
        cellColor = isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05);
        cellContent = const SizedBox.shrink();
      }
    }

    return GestureDetector(
      onTap: () => _handleDayTap(context, date, value),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(
                  color: widget.habit.color,
                  width: 1.5,
                )
              : null,
        ),
        child: Center(child: cellContent),
      ),
    );
  }

  void _handleDayTap(BuildContext context, DateTime date, dynamic currentValue) {
    // Just call the parent callback, let parent handle both boolean and measurable
    widget.onDayTap(date);
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
