import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme_data.dart';
import 'themes/serene_theme.dart';

/// Central theme accessor. All existing call-sites (`AppTheme.primaryColor`,
/// `AppTheme.glassEffect`, etc.) continue to work unchanged — they now
/// delegate to the active [AppThemeData] at runtime.
class AppTheme {
  AppTheme._();

  /// The currently active theme data. Set by [ThemeProvider] at startup
  /// and on every theme toggle.
  static AppThemeData _current = sereneTheme(); // default

  static AppThemeData get current => _current;

  /// Called by [ThemeProvider] to swap the active theme.
  static void setTheme(AppThemeData theme) {
    _current = theme;
  }

  // ── Delegating color accessors (backwards-compatible) ────────────────

  // Light mode glass
  static Color get glassBackground => _current.glassBackground;
  static Color get glassBackgroundDarker => _current.glassBackgroundDarker;
  static Color get taskCardBackground => _current.taskCardBackground;

  // Dark mode glass
  static Color get glassBackgroundDark => _current.glassBackgroundDark;
  static Color get glassBackgroundDarkerDark =>
      _current.glassBackgroundDarkerDark;
  static Color get taskCardBackgroundDark => _current.taskCardBackgroundDark;

  // Primary / secondary
  static Color get primaryColor => _current.primaryColor;
  static Color get primaryColorDark => _current.primaryColorDark;
  static Color get secondaryColor => _current.secondaryColor;
  static Color get secondaryColorDark => _current.secondaryColorDark;

  // Text — light
  static Color get textDark => _current.textDark;
  static Color get textMedium => _current.textMedium;
  static Color get textLight => _current.textLight;

  // Text — dark
  static Color get textDarkMode => _current.textDarkMode;
  static Color get textMediumDark => _current.textMediumDark;
  static Color get textLightDark => _current.textLightDark;

  // Background gradients — light
  static Color get backgroundGradientStart => _current.backgroundGradientStart;
  static Color get backgroundGradientEnd => _current.backgroundGradientEnd;

  // Background gradients — dark
  static Color get backgroundGradientStartDark =>
      _current.backgroundGradientStartDark;
  static Color get backgroundGradientEndDark =>
      _current.backgroundGradientEndDark;

  // ── Streak / fire colors (global — do not change per theme) ──────────
  static const crystalGoldPrimary = Color(0xFFFFD700);
  static const crystalGoldSecondary = Color(0xFFFFA500);
  static const crystalGoldGlow = Color(0xFFFFE55C);

  static const fireOrange = Color(0xFFFF8C42);
  static const fireOrangeDark = Color(0xFFFF6B00);
  static const warmBrown = Color(0xFF1A0A00);
  static const mutedOrange = Color(0xFFB86B3F);
  static const inactiveGray = Color(0xFF3D3D3D);

  // ── Delegating BoxDecoration accessors ───────────────────────────────

  static BoxDecoration get glassEffect => _current.glassEffect;
  static BoxDecoration get glassEffectDark => _current.glassEffectDark;
  static BoxDecoration get taskCardEffect => _current.taskCardEffect;
  static BoxDecoration get taskCardEffectDark => _current.taskCardEffectDark;

  // ── Delegating text style accessors (use theme-aware fonts) ──────────

  static TextStyle get headerStyle => _current.headerTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: _current.textDark,
  );

  static TextStyle get taskTextStyle => _current.headerTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: _current.textDark,
  );

  static TextStyle get sectionHeaderStyle => _current.headerTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: _current.textDark,
  );

  // ── ThemeData (delegated) ────────────────────────────────────────────

  static ThemeData get lightTheme => _current.lightTheme;
  static ThemeData get darkTheme => _current.darkTheme;
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
