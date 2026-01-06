import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/focus_provider.dart';
import '../../models/timer_state.dart';

class ControlButtons extends StatelessWidget {
  final FocusProvider provider;
  final bool isDark;
  final bool isMobile;
  final bool isSmall;

  const ControlButtons({
    Key? key,
    required this.provider,
    required this.isDark,
    required this.isMobile,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBreak = provider.currentSessionType != SessionType.focus;
    final primaryColor = isBreak
        ? Colors.green
        : Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine layout mode
        final isCompact = constraints.maxWidth < 400;
        final buttonSpacing = isSmall
            ? (isCompact ? 6.0 : (isMobile ? 8.0 : 10.0))
            : (isCompact ? 8.0 : (isMobile ? 12.0 : 16.0));

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: buttonSpacing,
          runSpacing: isSmall ? 8 : 12,
          children: [
            // Reset/Stop button
            if (provider.status != TimerStatus.idle)
              ControlButton(
                icon: Icons.stop_rounded,
                label: 'Stop',
                onPressed: () => provider.stopTimer(),
                isPrimary: false,
                isDark: isDark,
                isMobile: isMobile,
                isCompact: isCompact,
                isSmall: isSmall,
              ),

            // Main action button (Start/Pause)
            ControlButton(
              icon: provider.status == TimerStatus.running
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              label: provider.status == TimerStatus.running ? 'Pause' : 'Start',
              onPressed: () {
                if (provider.status == TimerStatus.running) {
                  provider.pauseTimer();
                } else {
                  provider.startTimer();
                }
              },
              isPrimary: true,
              isDark: isDark,
              isMobile: isMobile,
              primaryColor: primaryColor,
              isCompact: isCompact,
              isSmall: isSmall,
            ),

            // Skip button (for both focus and break sessions)
            if (provider.status != TimerStatus.idle)
              ControlButton(
                icon: Icons.skip_next_rounded,
                label: 'Skip',
                onPressed: () {
                  if (isBreak) {
                    provider.skipBreak();
                  } else {
                    provider.skipToBreak();
                  }
                },
                isPrimary: false,
                isDark: isDark,
                isMobile: isMobile,
                isCompact: isCompact,
                isSmall: isSmall,
              ),
          ],
        );
      },
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDark;
  final bool isMobile;
  final bool isCompact;
  final bool isSmall;
  final Color? primaryColor;

  const ControlButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    required this.isDark,
    required this.isMobile,
    this.isCompact = false,
    this.isSmall = false,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? Theme.of(context).colorScheme.primary;

    // Responsive sizing based on constraints
    final horizontalPadding = isSmall
        ? (isCompact ? 12.0 : (isMobile ? 14.0 : 18.0))
        : (isCompact ? 16.0 : (isMobile ? 20.0 : 28.0));
    final verticalPadding = isSmall
        ? (isCompact ? 8.0 : (isMobile ? 10.0 : 12.0))
        : (isCompact ? 12.0 : (isMobile ? 14.0 : 18.0));
    final iconSize = isSmall
        ? (isCompact ? 18.0 : (isMobile ? 20.0 : 22.0))
        : (isCompact ? 20.0 : (isMobile ? 22.0 : 26.0));
    final fontSize = isSmall
        ? (isCompact ? 12.0 : (isMobile ? 13.0 : 14.0))
        : (isCompact ? 14.0 : (isMobile ? 15.0 : 17.0));
    final iconTextSpacing = isSmall ? 4.0 : (isCompact ? 6.0 : 8.0);
    final borderRadius = isSmall ? 18.0 : 24.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? color
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: isSmall ? 8 : 12,
                      offset: Offset(0, isSmall ? 2 : 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                size: iconSize,
              ),
              SizedBox(width: iconTextSpacing),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
