// Stub for window_manager on web platform
// This file is used when the app runs on web to avoid importing window_manager

class WindowManager {
  static final WindowManager instance = WindowManager._();
  WindowManager._();
  
  Future<void> ensureInitialized() async {}
  Future<void> waitUntilReadyToShow() async {}
  Future<void> setMinimumSize(dynamic size) async {}
  Future<void> setSize(dynamic size) async {}
  Future<void> setAlwaysOnTop(bool alwaysOnTop) async {}
  Future<void> setTitleBarStyle(dynamic style) async {}
  Future<void> setBackgroundColor(dynamic color) async {}
  Future<void> setResizable(bool resizable) async {}
  Future<void> show() async {}
  Future<void> hide() async {}
  Future<void> minimize() async {}
  void startDragging() {}
  void addListener(dynamic listener) {}
  void removeListener(dynamic listener) {}
}

final windowManager = WindowManager.instance;

class WindowListener {}

enum TitleBarStyle { hidden, normal }
