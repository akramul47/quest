import 'package:flutter/material.dart';
import '../app_theme_data.dart';

/// The Classic theme — the original blue/indigo palette with Outfit/SpaceMono/Inter fonts.
AppThemeData classicTheme() {
  return AppThemeData(
    // Primary & Secondary
    primaryColor: const Color(0xFF6366F1), // Indigo
    primaryColorDark: const Color(0xFF818CF8), // Lighter indigo for dark mode
    secondaryColor: const Color(0xFFEC4899), // Pink
    secondaryColorDark: const Color(0xFFF472B6), // Lighter pink for dark mode
    // Text — Light mode
    textDark: const Color(0xFF1F2937),
    textMedium: const Color(0xFF6B7280),
    textLight: const Color(0xFF9CA3AF),

    // Text — Dark mode
    textDarkMode: const Color(0xFFE5E7EB),
    textMediumDark: const Color(0xFF9CA3AF),
    textLightDark: const Color(0xFF6B7280),

    // Background gradients — Light
    backgroundGradientStart: Colors.blue.shade50,
    backgroundGradientEnd: Colors.purple.shade50,

    // Background gradients — Dark (AMOLED)
    backgroundGradientStartDark: const Color(0xFF000000),
    backgroundGradientEndDark: const Color(0xFF0A0A0A),

    // Glass — Light
    glassBackground: const Color(0x99FFFFFF),
    glassBackgroundDarker: const Color(0xBBFFFFFF),
    taskCardBackground: const Color(0x88FFFFFF),

    // Glass — Dark
    glassBackgroundDark: const Color(0x99000000),
    glassBackgroundDarkerDark: const Color(0xBB000000),
    taskCardBackgroundDark: const Color(0x88111111),

    // Surface
    surfaceLight: Colors.white,
    surfaceDark: const Color(0xFF000000),
    errorLight: const Color(0xFFDC2626),
    errorDark: const Color(0xFFF87171),

    // Swatch
    swatchColor: const Color(0xFF6366F1),

    // Fonts — legacy
    headerFontFamily: 'Outfit',
    monoFontFamily: 'Space Mono',
    bodyFontFamily: 'Inter',
  );
}
