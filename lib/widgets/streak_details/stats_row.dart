import 'package:flutter/material.dart';
import '../../Utils/app_theme.dart';
import 'hover_stat_card.dart';

class StatsRow extends StatelessWidget {
  final int freezeDays;
  final int restoreTokens;
  final int longestStreak;
  final bool isDark;

  const StatsRow({
    super.key,
    required this.freezeDays,
    required this.restoreTokens,
    required this.longestStreak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HoverStatCard(
            icon: Icons.ac_unit,
            value: '$freezeDays',
            label: 'Freeze Days',
            iconColor: Colors.blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HoverStatCard(
            icon: Icons.replay_circle_filled,
            value: '$restoreTokens',
            label: 'Restore',
            iconColor: Colors.purple,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HoverStatCard(
            icon: Icons.emoji_events,
            value: '$longestStreak',
            label: 'Best',
            iconColor: isDark ? AppTheme.fireOrange : AppTheme.primaryColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}
