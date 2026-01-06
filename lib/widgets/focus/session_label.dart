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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : (isMobile ? 20 : 24),
        vertical: isSmall ? 8 : (isMobile ? 10 : 12),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.4 : 0.3),
          width: 1.5,
        ),
        boxShadow: isSmall
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 4 : 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBreak ? Icons.coffee_rounded : Icons.psychology_rounded,
              size: isSmall ? 14 : (isMobile ? 16 : 18),
              color: color,
            ),
          ),
          SizedBox(width: isSmall ? 8 : 12),
          Text(
            provider.sessionTypeLabel,
            style: GoogleFonts.outfit(
              fontSize: isSmall ? 13 : (isMobile ? 14 : 15),
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
