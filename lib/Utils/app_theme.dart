import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light mode glass effect constants
  static const glassBackground = Color(0x99FFFFFF);
  static const glassBackgroundDarker = Color(0xBBFFFFFF);
  static const taskCardBackground = Color(0x88FFFFFF);

  // Dark mode glass effect constants (with subtle transparency)
  static const glassBackgroundDark = Color(0x99000000);
  static const glassBackgroundDarkerDark = Color(0xBB000000);
  static const taskCardBackgroundDark = Color(0x88111111);

  // Primary theme colors
  static const primaryColor = Color(0xFF6366F1); // Indigo
  static const primaryColorDark = Color(
    0xFF818CF8,
  ); // Lighter indigo for dark mode
  static const secondaryColor = Color(0xFFEC4899); // Pink
  static const secondaryColorDark = Color(
    0xFFF472B6,
  ); // Lighter pink for dark mode

  // Text colors - Light mode
  static const textDark = Color(0xFF1F2937);
  static const textMedium = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);

  // Text colors - Dark mode
  static const textDarkMode = Color(0xFFE5E7EB);
  static const textMediumDark = Color(0xFF9CA3AF);
  static const textLightDark = Color(0xFF6B7280);

  // Background gradient colors - Light mode
  static final backgroundGradientStart = Colors.blue.shade50;
  static final backgroundGradientEnd = Colors.purple.shade50;

  // Background gradient colors - Dark mode (AMOLED Black with subtle gradient)
  static const backgroundGradientStartDark = Color(0xFF000000); // Pure black
  static const backgroundGradientEndDark = Color(
    0xFF0A0A0A,
  ); // Near black with subtle tone

  // Crystal Gold tier colors
  static const crystalGoldPrimary = Color(0xFFFFD700); // Gold
  static const crystalGoldSecondary = Color(0xFFFFA500); // Orange gold
  static const crystalGoldGlow = Color(0xFFFFE55C); // Light gold glow

  // Streak colors (fire theme)
  static const fireOrange = Color(0xFFFF8C42);
  static const fireOrangeDark = Color(0xFFFF6B00);
  static const warmBrown = Color(0xFF1A0A00);
  static const mutedOrange = Color(0xFFB86B3F);
  static const inactiveGray = Color(0xFF3D3D3D);

  // Glass effect decorations - Light mode
  static BoxDecoration glassEffect = BoxDecoration(
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

  // Glass effect decorations - Dark mode
  static BoxDecoration glassEffectDark = BoxDecoration(
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

  static BoxDecoration taskCardEffect = BoxDecoration(
    color: taskCardBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
    ],
  );

  static BoxDecoration taskCardEffectDark = BoxDecoration(
    color: taskCardBackgroundDark,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
  );

  // Text styles
  static TextStyle headerStyle = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: textDark,
  );

  static TextStyle taskTextStyle = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: textDark,
  );

  static TextStyle sectionHeaderStyle = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: textDark,
  );

  // Get the ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        background: Colors.white,
        error: const Color(0xFFDC2626),
        brightness: Brightness.light,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textDark,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textDark,
        ),
        displaySmall: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w200, // Change if necesary
          color: textDark,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: textDark, size: 24),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: glassBackground,
      ),

      // Input decoration theme
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
          borderSide: const BorderSide(color: primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Floating Action Button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.2),
        thickness: 1,
        space: 24,
      ),
    );
  }

  // Dark Theme (True AMOLED Black)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColorDark,
        primary: primaryColorDark,
        secondary: secondaryColorDark,
        surface: const Color(0xFF000000), // Pure black
        background: const Color(0xFF000000), // Pure black
        error: const Color(0xFFF87171),
        brightness: Brightness.dark,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textDarkMode,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textDarkMode,
        ),
        displaySmall: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDarkMode,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDarkMode,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDarkMode,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDarkMode,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w200,
          color: textDarkMode,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDarkMode,
        ),
        iconTheme: const IconThemeData(color: textDarkMode),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: textDarkMode, size: 24),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: glassBackgroundDark,
      ),

      // Input decoration theme
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
          borderSide: const BorderSide(color: primaryColorDark),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Floating Action Button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F1F1F),
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColorDark;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
        space: 24,
      ),
    );
  }
}

// Animation durations and curves
class TaskAnimations {
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;

  static SlideTransition slideIn(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: defaultCurve)),
      child: child,
    );
  }

  static Widget fadeScale(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
    );
  }
}
