import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../services/streak_service.dart';

class WeekCalendar extends StatelessWidget {
  final StreakService streakService;
  final bool isDark;

  const WeekCalendar({
    super.key,
    required this.streakService,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Start from Sunday (weekday 7 becomes 0, so subtract weekday % 7)
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(13)
            : Colors.white.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(26)
              : AppTheme.primaryColor.withAlpha(26),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final isToday = _isToday(date);
          final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
          final isActive = _wasActiveOnDate(streakService, date);

          return DayIndicator(
            dayLetter: days[index],
            dayNumber: date.day,
            isToday: isToday,
            isPast: isPast,
            isActive: isActive,
            isDark: isDark,
          );
        }),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _wasActiveOnDate(StreakService streakService, DateTime date) {
    final lastActive = streakService.streak?.lastActiveDate;
    if (lastActive == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    final streak = streakService.currentStreak;

    if (checkDate.isAfter(today)) return false;
    final daysAgo = today.difference(checkDate).inDays;
    return daysAgo < streak;
  }
}

class DayIndicator extends StatelessWidget {
  final String dayLetter;
  final int dayNumber;
  final bool isToday;
  final bool isPast;
  final bool isActive;
  final bool isDark;

  const DayIndicator({
    super.key,
    required this.dayLetter,
    required this.dayNumber,
    required this.isToday,
    required this.isPast,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Widget? checkMark;

    if (isToday) {
      bgColor = isDark ? AppTheme.fireOrangeDark : AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isPast && isActive) {
      bgColor = Colors.transparent;
      textColor = isDark ? AppTheme.mutedOrange : AppTheme.textMedium;
      checkMark = Icon(
        Icons.check,
        size: 18,
        color: isDark ? AppTheme.fireOrange : AppTheme.primaryColor,
      );
    } else {
      bgColor = isDark ? AppTheme.inactiveGray : Colors.grey.shade200;
      textColor = isDark ? Colors.white54 : AppTheme.textLight;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayLetter,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : AppTheme.textMedium,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(
            child:
                checkMark ??
                Text(
                  '$dayNumber',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
