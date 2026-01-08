import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitCreateButton extends StatelessWidget {
  final VoidCallback onCreate;
  final Color selectedColor;
  final bool isEditing;
  final bool isMobile;

  const HabitCreateButton({
    Key? key,
    required this.onCreate,
    required this.selectedColor,
    required this.isEditing,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 56 : 60,
      child: FilledButton(
        onPressed: onCreate,
        style: FilledButton.styleFrom(
          backgroundColor: selectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: selectedColor.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isEditing ? Icons.save_rounded : Icons.add_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'Update Habit' : 'Create Habit',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 18 : 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
