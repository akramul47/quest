import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/app_theme.dart';
import '../../../models/habit.dart';

class HabitDetailMonthlyChart extends StatelessWidget {
  final Habit habit;
  final bool isDark;

  const HabitDetailMonthlyChart({
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
                  'Monthly Overview',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Last 30 days',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: habit.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMonthlyProgressLine(habit, isDark),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgressLine(Habit habit, bool isDark) {
    final now = DateTime.now();
    final days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));

    final completionRates = <double>[];
    for (int i = 0; i < days.length; i++) {
      final weekDays = days.sublist(0, i + 1 > 7 ? i + 1 : 7);
      final completed = weekDays.where((d) => habit.isCompletedOn(d)).length;
      completionRates.add(
        weekDays.isNotEmpty ? completed / weekDays.length : 0,
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: Size.infinite,
            painter: _ProgressLinePainter(
              completionRates: completionRates,
              color: habit.color,
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '30 days ago',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
              ),
            ),
            Text(
              'Today',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressLinePainter extends CustomPainter {
  final List<double> completionRates;
  final Color color;
  final bool isDark;

  _ProgressLinePainter({
    required this.completionRates,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (completionRates.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    fillPath.moveTo(0, size.height);

    for (int i = 0; i < completionRates.length; i++) {
      final x = (size.width / (completionRates.length - 1)) * i;
      final y = size.height - (completionRates[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < completionRates.length; i++) {
      final x = (size.width / (completionRates.length - 1)) * i;
      final y = size.height - (completionRates[i] * size.height);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
