import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:quest/services/storage_service.dart';
import 'package:quest/services/windows_service.dart';

// Platform detection helpers
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isDesktopPlatform =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

/// Configures window manager for desktop platforms
Future<void> setupWindowManager() async {
  if (!isDesktopPlatform) return;

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
            final safePosition = await getSafeWindowPosition(
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
            final safePosition = await getSafeWindowPosition(
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

/// Ensures window position is within screen bounds
Future<Offset> getSafeWindowPosition(Offset position, Size windowSize) async {
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
