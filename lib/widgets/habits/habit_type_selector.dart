import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../models/habit.dart';

class HabitTypeSelector extends StatelessWidget {
  final HabitType selectedType;
  final ValueChanged<HabitType> onTypeChanged;
  final TextEditingController unitController;
  final Color selectedColor;
  final bool isDark;
  final bool isMobile;
  final VoidCallback onChanged;

  const HabitTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.unitController,
    required this.selectedColor,
    required this.isDark,
    required this.isMobile,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking Type',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                isDark,
                HabitType.boolean,
                Icons.check_circle_outline,
                'Yes/No',
                'Simple daily check-in',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                isDark,
                HabitType.measurable,
                Icons.show_chart,
                'Measurable',
                'Track numeric values',
              ),
            ),
          ],
        ),
        if (selectedType == HabitType.measurable) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: unitController,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              labelText: 'Unit of Measurement',
              hintText: 'e.g., miles, pages, minutes, cups',
              hintStyle: GoogleFonts.inter(
                color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
              ),
              prefixIcon: Icon(Icons.straighten, color: selectedColor),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (selectedType == HabitType.measurable &&
                  (value == null || value.trim().isEmpty)) {
                return 'Please enter a unit (e.g., miles, pages)';
              }
              return null;
            },
            onChanged: (value) => onChanged(),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeOption(
    bool isDark,
    HabitType type,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.15)
              : (isDark
                    ? AppTheme.glassBackgroundDark.withValues(alpha: 0.3)
                    : AppTheme.glassBackground.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? selectedColor
                  : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? selectedColor
                    : (isDark ? AppTheme.textDarkMode : AppTheme.textDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
