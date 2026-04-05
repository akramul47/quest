import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quest/Utils/window_manager_helper.dart';
import 'package:quest/providers/theme_provider.dart';
import 'package:quest/screens/main_navigation_screen.dart';
import 'package:quest/services/storage_service.dart';
import 'package:quest/services/cache/cache.dart';
import 'package:quest/widgets/window_frame.dart';
import 'services/streak_service.dart';

import 'models/todo_list.dart';
import 'providers/habit_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/window_state_provider.dart';
import 'providers/update_provider.dart';

/// Initialize SQLite database and run migration from SharedPreferences if needed
Future<void> _initializeDatabase() async {
  try {
    // Initialize the database
    await DatabaseHelper.instance.initDatabase();

    // Run migration from SharedPreferences if needed
    final migrationService = MigrationService();
    await migrationService.migrateIfNeeded();
  } catch (e) {
    debugPrint('Database initialization failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Google Fonts to handle missing AssetManifest.json
  GoogleFonts.config.allowRuntimeFetching = true;

  // Initialize SQLite database
  await _initializeDatabase();

  // Initialize StreakService
  await StreakService.instance.init();

  // Enable edge-to-edge mode for mobile
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // Configure window manager for desktop platforms
  await setupWindowManager();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoList()..initialize()),
        ChangeNotifierProvider(create: (_) => HabitList()..initialize()),
        ChangeNotifierProvider(create: (_) => FocusProvider()..initialize()),
        ChangeNotifierProvider.value(value: StreakService.instance),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => WindowStateProvider()..initialize(),
        ),
        Provider(create: (_) => StorageService()),
        Provider(create: (_) => CacheRepository()),
        ChangeNotifierProvider(create: (_) => UpdateProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Get effective brightness
          final brightness = themeProvider.effectiveThemeMode == ThemeMode.dark
              ? Brightness.dark
              : themeProvider.effectiveThemeMode == ThemeMode.light
              ? Brightness.light
              : MediaQuery.platformBrightnessOf(context);

          // Update system UI overlay style for mobile based on theme
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            final isDark = brightness == Brightness.dark;
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: isDark
                    ? Brightness.dark
                    : Brightness.light,
                systemNavigationBarColor: isDark
                    ? const Color(0xFF000000)
                    : Colors.white,
                systemNavigationBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
            );
          }

          return MaterialApp(
            title: 'Quest',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentThemeData.lightTheme,
            darkTheme: themeProvider.currentThemeData.darkTheme,
            themeMode: themeProvider.effectiveThemeMode,
            home: isWindows
                ? const WindowFrame(child: MainNavigationScreen())
                : const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
