import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

class HabitColorSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final bool isDark;
  final bool isMobile;

  static const List<Color> colors = [
    Color(0xFFFF6B6B),
    Color(0xFFEE5A6F),
    Color(0xFFC56CF0),
    Color(0xFF9B59B6),
    Color(0xFF667EEA),
    Color(0xFF4FACFE),
    Color(0xFF00D2FF),
    Color(0xFF06BEB6),
    Color(0xFF11998E),
    Color(0xFF38EF7D),
    Color(0xFFFFA726),
    Color(0xFFFFD93D),
    Color(0xFFFF1493),
    Color(0xFF00BFA5),
    Color(0xFF6200EA),
    Color(0xFFFF6D00),
    Color(0xFF2962FF),
    Color(0xFFAEEA00),
  ];

  const HabitColorSelector({
    Key? key,
    required this.selectedColor,
    required this.onColorChanged,
    required this.isDark,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick a Color',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        if (!isMobile)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return Center(child: _buildColorItem(colors[index]));
            },
          )
        else
          Wrap(
            spacing: isMobile ? 12 : 16,
            runSpacing: isMobile ? 12 : 16,
            children: colors.map(_buildColorItem).toList(),
          ),
      ],
    );
  }

  Widget _buildColorItem(Color color) {
    final isSelected = selectedColor.value == color.value;
    final colorSize = isMobile ? 48.0 : 56.0;

    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: colorSize,
        height: colorSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: isMobile ? 24 : 28,
              )
            : null,
      ),
    );
  }
}
