import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

// Conditional imports
import 'package:window_manager/window_manager.dart'
    if (dart.library.html) '../services/window_manager_stub.dart';
import 'package:tray_manager/tray_manager.dart'
    if (dart.library.html) '../services/tray_manager_stub.dart';

class SystemTrayService {
  static const String _tooltipMessage = 'Quest';

  static Future<String> _getIconPath() async {
    final ByteData data = await rootBundle.load('assets/app_icon.ico');
    final Directory tempDir = await getTemporaryDirectory();
    final String iconPath = '${tempDir.path}/app_icon.ico';

    final File iconFile = File(iconPath);
    await iconFile.writeAsBytes(data.buffer.asUint8List());

    return iconPath;
  }

  static Future<void> initSystemTray() async {
    // Only initialize system tray on desktop platforms
    if (kIsWeb || (!kIsWeb && !Platform.isWindows && !Platform.isMacOS && !Platform.isLinux)) {
      return;
    }

    try {
      final String iconPath = await _getIconPath();

      await trayManager.setIcon(
        iconPath,
        isTemplate: true,
      );

      await trayManager.setToolTip(_tooltipMessage);

      final Menu menu = Menu(
        items: [
          MenuItem(
            label: 'Show',
            onClick: (menuItem) async {
              await windowManager.show();
            },
          ),
          MenuItem(
            label: 'Hide',
            onClick: (menuItem) async {
              await windowManager.hide();
            },
          ),
          MenuItem.separator(),
          MenuItem(
            label: 'Exit',
            onClick: (menuItem) async {
              await windowManager.close();
            },
          ),
        ],
      );

      await trayManager.setContextMenu(menu);
    } catch (e) {
      print('Failed to initialize system tray: $e');
    }
  }
}
