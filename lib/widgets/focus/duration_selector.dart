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
    return Column(
      children: [
        if (!isSmall) ...[
          Text(
            'Quick Start',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: isSmall ? 6 : (isMobile ? 8 : 12),
          runSpacing: isSmall ? 6 : 8,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => provider.setFocusDuration(minutes),
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 14 : 20,
            vertical: isSmall ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(isDark ? 0.2 : 0.1)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
            border: isSelected
                ? Border.all(color: primaryColor.withOpacity(0.5), width: 1.5)
                : null,
          ),
          child: Text(
            '$minutes min',
            style: GoogleFonts.inter(
              fontSize: isSmall ? 13 : 14,
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
