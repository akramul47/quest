import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/focus_provider.dart';

class DurationSelector extends StatelessWidget {
  final FocusProvider provider;
  final bool isDark;
  final bool isMobile;
  final bool isSmall;

  const DurationSelector({
    Key? key,
    required this.provider,
    required this.isDark,
    required this.isMobile,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = isSmall ? 12.0 : 14.0;
    final spacing = isSmall ? (isMobile ? 6.0 : 8.0) : (isMobile ? 8.0 : 12.0);
    final titleSpacing = isSmall ? 10.0 : 16.0;

    return Column(
      children: [
        Text(
          'Quick Start',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: titleSpacing),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: [
            DurationChip(
              provider: provider,
              minutes: 20,
              isDark: isDark,
              isMobile: isMobile,
              isSmall: isSmall,
            ),
            DurationChip(
              provider: provider,
              minutes: 25,
              isDark: isDark,
              isMobile: isMobile,
              isSmall: isSmall,
            ),
            DurationChip(
              provider: provider,
              minutes: 30,
              isDark: isDark,
              isMobile: isMobile,
              isSmall: isSmall,
            ),
          ],
        ),
      ],
    );
  }
}

class DurationChip extends StatelessWidget {
  final FocusProvider provider;
  final int minutes;
  final bool isDark;
  final bool isMobile;
  final bool isSmall;

  const DurationChip({
    Key? key,
    required this.provider,
    required this.minutes,
    required this.isDark,
    required this.isMobile,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.settings.focusDuration == minutes;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final horizontalPadding = isSmall ? (isMobile ? 14.0 : 16.0) : 20.0;
    final verticalPadding = isSmall ? (isMobile ? 8.0 : 10.0) : 12.0;
    final fontSize = isSmall ? 12.0 : 14.0;
    final borderRadius = isSmall ? 12.0 : 16.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => provider.setFocusDuration(minutes),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(borderRadius),
            border: isSelected
                ? Border.all(
                    color: primaryColor.withOpacity(0.5),
                    width: isSmall ? 1.0 : 1.5,
                  )
                : null,
          ),
          child: Text(
            '$minutes min',
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }
}
