import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../models/habit.dart';

class HabitAdvancedOptions extends StatelessWidget {
  final HabitType selectedType;
  final bool showGoalField;
  final ValueChanged<bool> onShowGoalChanged;
  final TextEditingController goalController;
  final TextEditingController unitController;
  final Color selectedColor;
  final bool showQuestionField;
  final ValueChanged<bool> onShowQuestionChanged;
  final TextEditingController questionController;
  final bool isDark;
  final bool isMobile;

  const HabitAdvancedOptions({
    Key? key,
    required this.selectedType,
    required this.showGoalField,
    required this.onShowGoalChanged,
    required this.goalController,
    required this.unitController,
    required this.selectedColor,
    required this.showQuestionField,
    required this.onShowQuestionChanged,
    required this.questionController,
    required this.isDark,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Options',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),

        // Goal field toggle
        if (selectedType == HabitType.measurable)
          _buildAdvancedOption(
            isDark,
            Icons.flag_outlined,
            'Daily Goal',
            'Set a target to reach each day',
            showGoalField,
            onShowGoalChanged,
          ),

        if (showGoalField && selectedType == HabitType.measurable) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: goalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Daily Goal',
              hintText: 'e.g., 5',
              suffix: Text(
                unitController.text.isEmpty ? 'units' : unitController.text,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                ),
              ),
              prefixIcon: Icon(Icons.flag, color: selectedColor),
              filled: true,
              fillColor: isDark
                  ? AppTheme.glassBackgroundDark.withValues(alpha: 0.3)
                  : AppTheme.glassBackground.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: selectedColor, width: 2),
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Question field toggle
        _buildAdvancedOption(
          isDark,
          Icons.quiz_outlined,
          'Custom Question',
          'Add a motivational question',
          showQuestionField,
          onShowQuestionChanged,
        ),

        if (showQuestionField) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: questionController,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Question',
              hintText: 'e.g., Did you meditate today?',
              prefixIcon: Icon(Icons.quiz, color: selectedColor),
              filled: true,
              fillColor: isDark
                  ? AppTheme.glassBackgroundDark.withValues(alpha: 0.3)
                  : AppTheme.glassBackground.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: selectedColor, width: 2),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedOption(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.glassBackgroundDark.withValues(alpha: 0.3)
            : AppTheme.glassBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: selectedColor,
        title: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 32, top: 4),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
            ),
          ),
        ),
      ),
    );
  }
}
