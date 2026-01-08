import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quest/Utils/app_theme.dart';
import 'package:quest/providers/theme_provider.dart';
import 'package:quest/screens/main_navigation_screen.dart';
import 'package:quest/services/storage_service.dart';
import 'package:quest/services/windows_service.dart';
import 'package:quest/services/cache/cache.dart';
import 'services/streak_service.dart';

import 'models/todo_list.dart';
import 'providers/habit_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/window_state_provider.dart';

// Platform detection helpers
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isDesktopPlatform =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

// Helper function to ensure window position is within screen bounds
Future<Offset> _getSafeWindowPosition(Offset position, Size windowSize) async {
  try {
    final primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final screenSize = primaryDisplay.size;
    final screenPosition = primaryDisplay.visiblePosition ?? const Offset(0, 0);

    // Calculate safe bounds (ensure at least 100px of window is visible)
    const minVisibleSize = 100.0;

    double safeX = position.dx;
    double safeY = position.dy;

    // Check right edge
    if (safeX + minVisibleSize > screenPosition.dx + screenSize.width) {
      safeX = screenPosition.dx + screenSize.width - minVisibleSize;
    }

    // Check left edge
    if (safeX + windowSize.width < screenPosition.dx + minVisibleSize) {
      safeX = screenPosition.dx;
    }

    // Check bottom edge
    if (safeY + minVisibleSize > screenPosition.dy + screenSize.height) {
      safeY = screenPosition.dy + screenSize.height - minVisibleSize;
    }

    // Check top edge
    if (safeY < screenPosition.dy) {
      safeY = screenPosition.dy;
    }

    // If position is completely out of bounds, center the window
    if (safeX < screenPosition.dx - windowSize.width + minVisibleSize ||
        safeX > screenPosition.dx + screenSize.width - minVisibleSize ||
        safeY < screenPosition.dy - 50 ||
        safeY > screenPosition.dy + screenSize.height - minVisibleSize) {
      safeX = screenPosition.dx + (screenSize.width - windowSize.width) / 2;
      safeY = screenPosition.dy + (screenSize.height - windowSize.height) / 2;
    }

    return Offset(safeX, safeY);
  } catch (e) {
    debugPrint('Failed to get safe window position: $e');
    // Fallback to original position if screen retrieval fails
    return position;
  }
}

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
  // This allows fonts to be loaded from HTTP when assets are unavailable
  GoogleFonts.config.allowRuntimeFetching = true;

  // Initialize SQLite database
  await _initializeDatabase();

  // Initialize StreakService
  await StreakService.instance.init();

  // Note: System UI overlay will be configured dynamically based on theme in MaterialApp
  // This ensures proper status bar colors for both light and dark modes

  // Enable edge-to-edge mode for mobile
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // Only configure window manager on desktop platforms
  if (isDesktopPlatform) {
    try {
      await WindowManager.instance.ensureInitialized();

      // Load saved window state
      final storageService = StorageService();
      final windowState = await storageService.loadWindowState();

      // Configure window properties for desktop
      await windowManager.waitUntilReadyToShow().then((_) async {
        // Set minimum size
        await windowManager.setMinimumSize(const Size(350, 500));

        if (isWindows) {
          // Restore saved state or use defaults for Windows
          if (windowState != null) {
            final windowSize = Size(
              windowState['width'] as double,
              windowState['height'] as double,
            );
            await windowManager.setSize(windowSize);

            if (windowState['x'] != null && windowState['y'] != null) {
              final savedPosition = Offset(
                windowState['x'] as double,
                windowState['y'] as double,
              );
              final safePosition = await _getSafeWindowPosition(
                savedPosition,
                windowSize,
              );
              await windowManager.setPosition(safePosition);
            }
            await windowManager.setAlwaysOnTop(
              windowState['isAlwaysOnTop'] as bool,
            );
            if (windowState['isMaximized'] as bool) {
              await windowManager.maximize();
            }
          } else {
            // Default Windows settings (sidebar mode)
            await windowManager.setSize(const Size(400, 700));
            await windowManager.setAlwaysOnTop(true);
          }
          // Windows-specific settings
          await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
          await windowManager.setBackgroundColor(Colors.transparent);
        } else {
          // macOS/Linux
          if (windowState != null) {
            final windowSize = Size(
              windowState['width'] as double,
              windowState['height'] as double,
            );
            await windowManager.setSize(windowSize);

            if (windowState['x'] != null && windowState['y'] != null) {
              final savedPosition = Offset(
                windowState['x'] as double,
                windowState['y'] as double,
              );
              final safePosition = await _getSafeWindowPosition(
                savedPosition,
                windowSize,
              );
              await windowManager.setPosition(safePosition);
            }
            if (windowState['isMaximized'] as bool) {
              await windowManager.maximize();
            }
          } else {
            // Default size for macOS/Linux
            await windowManager.setSize(const Size(900, 700));
          }
        }

        // Set window to be resizable
        await windowManager.setResizable(true);
        await windowManager.show();
      });

      // Setup auto-start only on Windows
      if (isWindows) {
        await WindowsService.setupAutoStart();
      }
    } catch (e) {
      debugPrint('Window manager initialization failed: $e');
    }
  }

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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
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

class WindowFrame extends StatefulWidget {
  final Widget child;

  const WindowFrame({super.key, required this.child});

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> with WindowListener {
  bool _isHovered = false; // Track if window frame is hovered
  bool _isHeaderHovered = false; // Track if header is hovered
  bool _isMaximized = false; // Track maximized state

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadWindowState();
  }

  // Load initial window state
  Future<void> _loadWindowState() async {
    try {
      final isMaximized = await windowManager.isMaximized();
      final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
      setState(() {
        _isMaximized = isMaximized;
      });
      // Update provider with current state
      if (mounted) {
        final windowStateProvider = context.read<WindowStateProvider>();
        if (windowStateProvider.isAlwaysOnTop != isAlwaysOnTop) {
          await windowStateProvider.setAlwaysOnTop(isAlwaysOnTop);
        }
      }
    } catch (e) {
      debugPrint('Failed to load window state: $e');
    }
  }

  // Save window state
  Future<void> _saveWindowState() async {
    try {
      final size = await windowManager.getSize();
      final position = await windowManager.getPosition();
      final storageService = StorageService();

      if (!mounted) return;
      final windowStateProvider = context.read<WindowStateProvider>();

      await storageService.saveWindowState(
        width: size.width,
        height: size.height,
        x: position.dx,
        y: position.dy,
        isMaximized: _isMaximized,
        isAlwaysOnTop: windowStateProvider.isAlwaysOnTop,
      );
    } catch (e) {
      debugPrint('Failed to save window state: $e');
    }
  }

  // Toggle maximize/restore
  Future<void> _toggleMaximize() async {
    try {
      if (_isMaximized) {
        await windowManager.unmaximize();
        setState(() {
          _isMaximized = false;
        });
      } else {
        await windowManager.maximize();
        setState(() {
          _isMaximized = true;
        });
      }
      await _saveWindowState();
    } catch (e) {
      debugPrint('Failed to toggle maximize: $e');
    }
  }

  @override
  void onWindowResize() {
    super.onWindowResize();
    _saveWindowState();
  }

  @override
  void onWindowMove() {
    super.onWindowMove();
    _saveWindowState();
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    setState(() {
      _isMaximized = true;
    });
    _saveWindowState();
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    setState(() {
      _isMaximized = false;
    });
    _saveWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF000000).withValues(alpha: 0.98)
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if mobile view (width < 600px) - tablet/desktop get window controls in screens
            final isMobileView = constraints.maxWidth < 600;

            return Column(
              children: [
                // Show hover header only for mobile view on Windows
                if (isMobileView)
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHeaderHovered = true),
                      onExit: (_) => setState(() => _isHeaderHovered = false),
                      child: GestureDetector(
                        onPanStart: (details) {
                          try {
                            windowManager.startDragging();
                          } catch (e) {
                            debugPrint('Failed to start dragging: $e');
                          }
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.primaryColorDark.withValues(
                                    alpha: 0.1,
                                  )
                                : Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Drag indicator
                              Icon(
                                Icons.drag_indicator,
                                size: 20,
                                color: isDark
                                    ? AppTheme.primaryColorDark
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              // "Drag to move" text - only shows when hovering over header
                              if (_isHeaderHovered)
                                Expanded(
                                  child: Text(
                                    'Drag to move',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppTheme.primaryColorDark
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (!_isHeaderHovered) const Spacer(),
                              // Always on top toggle button
                              Consumer<WindowStateProvider>(
                                builder: (context, windowStateProvider, child) {
                                  return IconButton(
                                    icon: Icon(
                                      windowStateProvider.isAlwaysOnTop
                                          ? Icons.push_pin
                                          : Icons.push_pin_outlined,
                                      size: 18,
                                      color: windowStateProvider.isAlwaysOnTop
                                          ? (isDark
                                                ? AppTheme.primaryColorDark
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.primary)
                                          : (isDark
                                                ? AppTheme.primaryColorDark
                                                      .withValues(alpha: 0.6)
                                                : Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.6)),
                                    ),
                                    onPressed: () async {
                                      await windowStateProvider
                                          .toggleAlwaysOnTop();
                                      await _saveWindowState();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: windowStateProvider.isAlwaysOnTop
                                        ? 'Unpin window'
                                        : 'Pin window on top',
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              // Minimize button
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  try {
                                    windowManager.minimize();
                                  } catch (e) {
                                    debugPrint('Failed to minimize: $e');
                                  }
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Minimize',
                              ),
                              const SizedBox(width: 8),
                              // Maximize/Restore button
                              IconButton(
                                icon: Icon(
                                  _isMaximized
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                  size: 18,
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: _toggleMaximize,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: _isMaximized ? 'Restore' : 'Maximize',
                              ),
                              const SizedBox(width: 8),
                              // Close button
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  try {
                                    windowManager.hide();
                                  } catch (e) {
                                    debugPrint('Failed to hide: $e');
                                  }
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Close',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(child: widget.child),
              ],
            );
          },
        ),
      ),
    );
  }
}
