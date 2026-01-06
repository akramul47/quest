import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/focus_provider.dart';
import '../../models/timer_state.dart';
import '../../Utils/app_theme.dart';

class FocusStatistics extends StatelessWidget {
  final FocusProvider provider;
  final bool isDark;
  final bool isMobile;

  const FocusStatistics({
    Key? key,
    required this.provider,
    required this.isDark,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = provider.currentSessionType == SessionType.focus
        ? Theme.of(context).colorScheme.primary
        : Colors.green;

    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 28),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(
            isDark ? 0.08 : 0.04,
          ),
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Today\'s Stats',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.insights_rounded,
                size: 16,
                color: primaryColor.withOpacity(0.6),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatItem(
                  icon: Icons.auto_awesome_rounded,
                  value: '${provider.completedFocusSessions}',
                  label: 'sessions',
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
              ),
              Container(
                height: 40,
                width: 1.5,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
              ),
              Expanded(
                child: StatItem(
                  icon: Icons.timer_rounded,
                  value: '${provider.totalFocusTimeToday ~/ 60}',
                  label: 'minutes',
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;
  final Color primaryColor;

  const StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: primaryColor),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.textDark,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toLowerCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
