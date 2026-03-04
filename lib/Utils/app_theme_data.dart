import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enum representing available app theme types.
enum AppThemeType {
  serene,
  classic;

  String get displayName {
    switch (this) {
      case AppThemeType.serene:
        return 'Serene';
      case AppThemeType.classic:
        return 'Classic';
    }
  }

  String get description {
    switch (this) {
      case AppThemeType.serene:
        return 'Calm earth tones';
      case AppThemeType.classic:
        return 'Bold & vibrant';
    }
  }
}

/// Immutable data class holding all color/decoration/font tokens that vary
/// per theme. Each app theme (Classic, Serene, etc.) provides its own instance.
class AppThemeData {
  // ── Primary & Secondary ──────────────────────────────────────────────
  final Color primaryColor;
  final Color primaryColorDark;
  final Color secondaryColor;
  final Color secondaryColorDark;

  // ── Text colors — Light mode ─────────────────────────────────────────
  final Color textDark;
  final Color textMedium;
  final Color textLight;

  // ── Text colors — Dark mode ──────────────────────────────────────────
  final Color textDarkMode;
  final Color textMediumDark;
  final Color textLightDark;

  // ── Background gradients — Light mode ────────────────────────────────
  final Color backgroundGradientStart;
  final Color backgroundGradientEnd;

  // ── Background gradients — Dark mode ─────────────────────────────────
  final Color backgroundGradientStartDark;
  final Color backgroundGradientEndDark;

  // ── Glass / card backgrounds — Light mode ────────────────────────────
  final Color glassBackground;
  final Color glassBackgroundDarker;
  final Color taskCardBackground;

  // ── Glass / card backgrounds — Dark mode ─────────────────────────────
  final Color glassBackgroundDark;
  final Color glassBackgroundDarkerDark;
  final Color taskCardBackgroundDark;

  // ── Surface ──────────────────────────────────────────────────────────
  final Color surfaceLight;
  final Color surfaceDark;
  final Color errorLight;
  final Color errorDark;

  // ── Swatch color for preview ─────────────────────────────────────────
  final Color swatchColor;

  // ── Font families ────────────────────────────────────────────────────
  /// Font for headers, display text (e.g. Outfit, Quicksand)
  final String headerFontFamily;

  /// Font for monospaced text (e.g. Space Mono, JetBrains Mono)
  final String monoFontFamily;

  /// Font for body text (e.g. Inter, DM Sans)
  final String bodyFontFamily;

  const AppThemeData({
    required this.primaryColor,
    required this.primaryColorDark,
    required this.secondaryColor,
    required this.secondaryColorDark,
    required this.textDark,
    required this.textMedium,
    required this.textLight,
    required this.textDarkMode,
    required this.textMediumDark,
    required this.textLightDark,
    required this.backgroundGradientStart,
    required this.backgroundGradientEnd,
    required this.backgroundGradientStartDark,
    required this.backgroundGradientEndDark,
    required this.glassBackground,
    required this.glassBackgroundDarker,
    required this.taskCardBackground,
    required this.glassBackgroundDark,
    required this.glassBackgroundDarkerDark,
    required this.taskCardBackgroundDark,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.errorLight,
    required this.errorDark,
    required this.swatchColor,
    required this.headerFontFamily,
    required this.monoFontFamily,
    required this.bodyFontFamily,
  });

  // ── Font helpers ─────────────────────────────────────────────────────

  /// Header font TextStyle via Google Fonts (e.g. Outfit, Quicksand).
  TextStyle headerTextStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = -0.5,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      headerFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Mono font TextStyle via Google Fonts (e.g. Space Mono, JetBrains Mono).
  TextStyle monoTextStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      monoFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Body font TextStyle via Google Fonts (e.g. Inter, DM Sans).
  TextStyle bodyTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.getFont(
      bodyFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ── Glass effect BoxDecorations ──────────────────────────────────────

  BoxDecoration get glassEffect => BoxDecoration(
    color: glassBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  BoxDecoration get glassEffectDark => BoxDecoration(
    color: glassBackgroundDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  BoxDecoration get taskCardEffect => BoxDecoration(
    color: taskCardBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
    ],
  );

  BoxDecoration get taskCardEffectDark => BoxDecoration(
    color: taskCardBackgroundDark,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8),
    ],
  );

  // ── ThemeData builders ───────────────────────────────────────────────

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceLight,
        background: surfaceLight,
        error: errorLight,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        displayLarge: headerTextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textDark,
        ),
        displayMedium: headerTextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textDark,
        ),
        displaySmall: monoTextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: monoTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: bodyTextStyle(fontSize: 16, color: textDark),
        bodyMedium: bodyTextStyle(fontSize: 14, color: textDark),
        labelLarge: bodyTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w200,
          color: textDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: monoTextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        iconTheme: IconThemeData(color: textDark),
      ),
      iconTheme: IconThemeData(color: textDark, size: 24),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: glassBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: bodyTextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.2),
        thickness: 1,
        space: 24,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColorDark,
        primary: primaryColorDark,
        secondary: secondaryColorDark,
        surface: surfaceDark,
        background: surfaceDark,
        error: errorDark,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        displayLarge: headerTextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textDarkMode,
        ),
        displayMedium: headerTextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textDarkMode,
        ),
        displaySmall: monoTextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDarkMode,
        ),
        headlineMedium: monoTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDarkMode,
        ),
        bodyLarge: bodyTextStyle(fontSize: 16, color: textDarkMode),
        bodyMedium: bodyTextStyle(fontSize: 14, color: textDarkMode),
        labelLarge: bodyTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w200,
          color: textDarkMode,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: monoTextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDarkMode,
        ),
        iconTheme: IconThemeData(color: textDarkMode),
      ),
      iconTheme: IconThemeData(color: textDarkMode, size: 24),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: glassBackgroundDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColorDark),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F1F1F),
        contentTextStyle: bodyTextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColorDark;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        space: 24,
      ),
    );
  }
}
