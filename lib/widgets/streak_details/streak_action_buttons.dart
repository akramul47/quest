import 'package:flutter/material.dart';
import '../../services/streak_service.dart';

class StreakActionButtons extends StatelessWidget {
  final StreakService streakService;
  final int freezeDays;
  final bool canRestore;
  final bool isDark;
  final VoidCallback onFreeze;
  final VoidCallback onRestore;

  const StreakActionButtons({
    super.key,
    required this.streakService,
    required this.freezeDays,
    required this.canRestore,
    required this.isDark,
    required this.onFreeze,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (freezeDays > 0 && !streakService.isFrozenToday)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onFreeze,
              icon: const Icon(Icons.ac_unit, size: 18),
              label: const Text('Freeze Today'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (freezeDays > 0 && canRestore) const SizedBox(width: 12),
        if (canRestore)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('Restore'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: BorderSide(color: Colors.purple.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
