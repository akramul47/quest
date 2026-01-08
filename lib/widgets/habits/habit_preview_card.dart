import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../models/habit.dart';

class HabitPreviewCard extends StatelessWidget {
  final Color selectedColor;
  final IconData selectedIcon;
  final TextEditingController nameController;
  final HabitType selectedType;
  final TextEditingController unitController;
  final bool isDark;
  final bool isMobile;

  const HabitPreviewCard({
    Key? key,
    required this.selectedColor,
    required this.selectedIcon,
    required this.nameController,
    required this.selectedType,
    required this.unitController,
    required this.isDark,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            selectedColor.withValues(alpha: 0.2),
            selectedColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selectedColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: selectedColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              selectedIcon,
              size: isMobile ? 40 : 48,
              color: selectedColor,
            ),
          ),
          SizedBox(width: isMobile ? 20 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: nameController,
                  builder: (context, value, _) {
                    return Text(
                      value.text.isEmpty ? 'Your Habit' : value.text,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                      ),
                    );
                  },
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  selectedType == HabitType.measurable
                      ? 'Track ${unitController.text.isEmpty ? 'values' : unitController.text}'
                      : 'Yes/No tracking',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 14 : 16,
                    color: isDark
                        ? AppTheme.textMediumDark
                        : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
