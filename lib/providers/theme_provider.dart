import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/app_theme.dart';
import '../Utils/app_theme_data.dart';
import '../Utils/themes/classic_theme.dart';
import '../Utils/themes/serene_theme.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  AppThemeType _appTheme = AppThemeType.serene; // default

  static const String _themeModeKey = 'theme_mode';
  static const String _appThemeKey = 'app_theme';

  AppThemeMode get themeMode => _themeMode;
  AppThemeType get appTheme => _appTheme;

  /// Returns the [AppThemeData] for the currently selected app theme.
  AppThemeData get currentThemeData => resolveThemeData(_appTheme);

  ThemeProvider() {
    _loadPreferences();
  }

  static AppThemeData resolveThemeData(AppThemeType type) {
    switch (type) {
      case AppThemeType.serene:
        return sereneTheme();
      case AppThemeType.classic:
        return classicTheme();
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final savedMode = prefs.getString(_themeModeKey);
      if (savedMode != null) {
        _themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedMode,
          orElse: () => AppThemeMode.system,
        );
      }

      // Load app theme
      final savedAppTheme = prefs.getString(_appThemeKey);
      if (savedAppTheme != null) {
        _appTheme = AppThemeType.values.firstWhere(
          (t) => t.name == savedAppTheme,
          orElse: () => AppThemeType.serene,
        );
      }

      // Sync the static AppTheme accessor
      AppTheme.setTheme(resolveThemeData(_appTheme));

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load theme preferences: $e');
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }

  Future<void> setAppTheme(AppThemeType type) async {
    if (_appTheme == type) return;

    _appTheme = type;
    final themeData = resolveThemeData(type);
    AppTheme.setTheme(themeData);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appThemeKey, type.name);
    } catch (e) {
      debugPrint('Failed to save app theme: $e');
    }
  }

  ThemeMode get effectiveThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String get themeModeDisplayName {
    switch (_themeMode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}
