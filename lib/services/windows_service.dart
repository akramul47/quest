import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import for win32_registry
import 'package:win32_registry/win32_registry.dart'
    if (dart.library.html) '../services/win32_registry_stub.dart';

class WindowsService {
  static const String _registryPath = r'Software\Microsoft\Windows\CurrentVersion\Run';
  static const String _appName = 'WindowsTodo';

  static Future<void> setupAutoStart() async {
    // Only run on Windows platform
    if (kIsWeb || (!kIsWeb && !Platform.isWindows)) {
      return;
    }

    try {
      final key = Registry.localMachine.createKey(_registryPath);
      final exePath = await _getExecutablePath();
      
      if (exePath != null) {
        key.createValue(RegistryValue(
          _appName,
          RegistryValueType.string,
          exePath,
        ));
      }
      
      key.close();
    } catch (e) {
      // Handle or log error appropriately
      print('Failed to set up auto-start: $e');
    }
  }

  static Future<String?> _getExecutablePath() async {
    // This is a placeholder. In a real app, you'd need to implement
    // proper executable path detection based on your deployment method
    return 'C:\\Program Files\\WindowsTodo\\WindowsTodo.exe';
  }

  static Future<void> removeAutoStart() async {
    // Only run on Windows platform
    if (kIsWeb || (!kIsWeb && !Platform.isWindows)) {
      return;
    }

    try {
      final key = Registry.localMachine.createKey(_registryPath);
      key.deleteValue(_appName);
      key.close();
    } catch (e) {
      print('Failed to remove auto-start: $e');
    }
  }
}