import 'package:flutter/material.dart';
import '../app_theme_data.dart';

/// The Serene theme — calm earth tones with thin, modern typography.
/// Headers: Raleway (elegant, thin). Body: Nunito Sans (clean, airy). Mono: Fira Code.
AppThemeData sereneTheme() {
  return const AppThemeData(
    // Primary & Secondary
    primaryColor: Color(0xFF5B7553), // Olive green
    primaryColorDark: Color(0xFF7A9E72), // Sage green
    secondaryColor: Color(0xFFC4A77D), // Warm tan
    secondaryColorDark: Color(0xFFD4B896), // Light tan
    // Text — Light mode
    textDark: Color(0xFF2C3E2C), // Dark green
    textMedium: Color(0xFF5A6B5A), // Muted green
    textLight: Color(0xFF8A9B8A), // Soft green
    // Text — Dark mode
    textDarkMode: Color(0xFFD8E0D4), // Light sage
    textMediumDark: Color(0xFF98A890), // Medium sage
    textLightDark: Color(0xFF627862), // Dim sage
    // Background gradients — Light
    backgroundGradientStart: Color(0xFFF5F1EB), // Warm cream
    backgroundGradientEnd: Color(0xFFEDE8E0), // Light khaki
    // Background gradients — Dark (deep forest)
    backgroundGradientStartDark: Color(0xFF1A1E1A),
    backgroundGradientEndDark: Color(0xFF0F120F),

    // Glass — Light
    glassBackground: Color(0x99F5F1EB),
    glassBackgroundDarker: Color(0xBBF5F1EB),
    taskCardBackground: Color(0x88FFFFFF),

    // Glass — Dark
    glassBackgroundDark: Color(0x991A1E1A),
    glassBackgroundDarkerDark: Color(0xBB1A1E1A),
    taskCardBackgroundDark: Color(0x88151915),

    // Surface
    surfaceLight: Color(0xFFFAFAF7),
    surfaceDark: Color(0xFF000000),
    errorLight: Color(0xFFC62828),
    errorDark: Color(0xFFEF5350),

    // Swatch
    swatchColor: Color(0xFF5B7553),

    // Fonts — soft, rounded headers + thin modern body
    headerFontFamily: 'Quicksand',
    monoFontFamily: 'DM Mono',
    bodyFontFamily: 'DM Sans',
  );
}
