import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/focus_provider.dart';
import '../../models/timer_state.dart';

class SessionLabel extends StatelessWidget {
  final FocusProvider provider;
  final bool isDark;
  final bool isMobile;
  final bool isSmall;

  const SessionLabel({
    Key? key,
    required this.provider,
    required this.isDark,
    required this.isMobile,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBreak = provider.currentSessionType != SessionType.focus;
    final color = isBreak
        ? Colors.green
        : Theme.of(context).colorScheme.primary;

    // Responsive sizing based on screen constraints
    final horizontalPadding = isSmall
        ? (isMobile ? 14.0 : 18.0)
        : (isMobile ? 20.0 : 24.0);
    final verticalPadding = isSmall
        ? (isMobile ? 6.0 : 8.0)
        : (isMobile ? 10.0 : 12.0);
    final iconSize = isSmall
        ? (isMobile ? 14.0 : 16.0)
        : (isMobile ? 16.0 : 18.0);
    final fontSize = isSmall
        ? (isMobile ? 12.0 : 13.0)
        : (isMobile ? 14.0 : 15.0);
    final iconPadding = isSmall ? 4.0 : 6.0;
    final spacing = isSmall ? 8.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.25 : 0.15),
            color.withOpacity(isDark ? 0.15 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.4 : 0.3),
          width: isSmall ? 1.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: isSmall ? 8 : 12,
            offset: Offset(0, isSmall ? 2 : 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBreak ? Icons.coffee_rounded : Icons.psychology_rounded,
              size: iconSize,
              color: color,
            ),
          ),
          SizedBox(width: spacing),
          Text(
            provider.sessionTypeLabel,
            style: GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
