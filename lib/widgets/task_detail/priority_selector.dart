import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/todo.dart';
import '../../Utils/app_theme.dart';

class PrioritySelector extends StatelessWidget {
  final TodoPriority selectedPriority;
  final Function(TodoPriority) onPriorityChanged;
  final bool isDark;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPriorityButton(
            context,
            'Main Quest',
            TodoPriority.mainQuest,
            Icons.star,
          ),
          const SizedBox(width: 8),
          _buildPriorityButton(
            context,
            'Side Quest',
            TodoPriority.sideQuest,
            Icons.assignment,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityButton(
    BuildContext context,
    String label,
    TodoPriority priority,
    IconData icon,
  ) {
    final isSelected = selectedPriority == priority;
    return InkWell(
      onTap: () => onPriorityChanged(priority),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppTheme.primaryColorDark
                    : Theme.of(context).colorScheme.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : isDark
                ? AppTheme.primaryColorDark
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
