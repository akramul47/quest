import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../Utils/app_theme.dart';

class HabitDateHeader extends StatelessWidget {
  final List<DateTime> visibleDates;
  final ScrollController scrollController;
  final bool isDark;

  const HabitDateHeader({
    Key? key,
    required this.visibleDates,
    required this.scrollController,
    required this.isDark,
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
          // Spacer for icon + habit name column
          const SizedBox(width: 44),

          const Expanded(
            flex: 2,
            child: SizedBox(), // Space for habit names
          ),

          const SizedBox(width: 6),

          // Date cells - infinitely scrollable
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: visibleDates.map((date) {
                  final isToday = _isToday(date);
                  return Container(
                    width: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(date).substring(0, 1),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isToday
                                ? (isDark
                                      ? AppTheme.primaryColorDark
                                      : AppTheme.primaryColor)
                                : (isDark
                                      ? AppTheme.textLightDark
                                      : AppTheme.textLight),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('d').format(date),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isToday
                                ? (isDark
                                      ? AppTheme.primaryColorDark
                                      : AppTheme.primaryColor)
                                : (isDark
                                      ? AppTheme.textMediumDark
                                      : AppTheme.textMedium),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
