import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/focus_provider.dart';

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
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Today\'s Progress',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatItem(
                icon: Icons.check_circle_outline,
                value: '${provider.completedFocusSessions}',
                label: 'Sessions',
                isDark: isDark,
              ),
              StatItem(
                icon: Icons.timer_outlined,
                value: '${provider.totalFocusTimeToday ~/ 60}',
                label: 'Minutes',
                isDark: isDark,
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

  const StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
