import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart'
    if (dart.library.html) '../services/window_manager_stub.dart';

/// Provider to manage window state across the application
class WindowStateProvider extends ChangeNotifier {
  bool _isAlwaysOnTop = false;

  bool get isAlwaysOnTop => _isAlwaysOnTop;

  /// Initialize the provider by checking current window state
  Future<void> initialize() async {
    if (!kIsWeb && Platform.isWindows) {
      _isAlwaysOnTop = await windowManager.isAlwaysOnTop();
      notifyListeners();
    }
  }

  /// Toggle the always-on-top state
  Future<void> toggleAlwaysOnTop() async {
    if (!kIsWeb && Platform.isWindows) {
      _isAlwaysOnTop = !_isAlwaysOnTop;
      await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
      notifyListeners();
    }
  }

  /// Set the always-on-top state explicitly
  Future<void> setAlwaysOnTop(bool value) async {
    if (!kIsWeb && Platform.isWindows) {
      _isAlwaysOnTop = value;
      await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
      notifyListeners();
    }
  }
}
