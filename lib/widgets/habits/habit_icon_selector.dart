import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';

class HabitIconSelector extends StatelessWidget {
  final IconData selectedIcon;
  final ValueChanged<IconData> onIconChanged;
  final Color selectedColor;
  final bool isDark;
  final bool isMobile;

  static const List<IconData> availableIcons = [
    Icons.favorite,
    Icons.fitness_center,
    Icons.book,
    Icons.water_drop,
    Icons.bedtime,
    Icons.restaurant,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.music_note,
    Icons.brush,
    Icons.school,
    Icons.work,
    Icons.coffee,
    Icons.pets,
    Icons.nature,
    Icons.sunny,
    Icons.medication,
    Icons.psychology,
    Icons.spa,
    Icons.family_restroom,
    Icons.celebration,
    Icons.emoji_events,
    Icons.lightbulb,
    Icons.palette,
  ];

  const HabitIconSelector({
    Key? key,
    required this.selectedIcon,
    required this.onIconChanged,
    required this.selectedColor,
    required this.isDark,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose an Icon',
          style: GoogleFonts.outfit(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 14),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.glassBackgroundDark.withValues(alpha: 0.3)
                : AppTheme.glassBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 6 : 8,
              crossAxisSpacing: isMobile ? 8 : 12,
              mainAxisSpacing: isMobile ? 8 : 12,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final icon = availableIcons[index];
              final isSelected = selectedIcon == icon;

              return GestureDetector(
                onTap: () => onIconChanged(icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withValues(alpha: 0.2)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? selectedColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 24 : 28,
                    color: isSelected
                        ? selectedColor
                        : (isDark
                              ? AppTheme.textMediumDark
                              : AppTheme.textMedium),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
