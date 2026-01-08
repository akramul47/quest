import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

class HabitNameField extends StatelessWidget {
  final TextEditingController nameController;
  final bool isDark;
  final bool isMobile;
  final Color selectedColor;
  final VoidCallback onChanged;

  const HabitNameField({
    Key? key,
    required this.nameController,
    required this.isDark,
    required this.isMobile,
    required this.selectedColor,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Name',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        TextFormField(
          controller: nameController,
          autofocus: !isMobile,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 17,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Morning Meditation',
            hintStyle: GoogleFonts.inter(
              color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
            ),
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
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a habit name';
            }
            return null;
          },
          onChanged: (value) => onChanged(),
        ),
      ],
    );
  }
}
