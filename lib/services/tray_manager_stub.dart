// Stub for tray_manager on non-desktop platforms
// This file is used when the app runs on mobile/web platforms

class TrayManager {
  static final TrayManager instance = TrayManager._();
  TrayManager._();
  
  Future<void> setIcon(String path, {bool isTemplate = false}) async {}
  Future<void> setToolTip(String tooltip) async {}
  Future<void> setContextMenu(Menu menu) async {}
}

final trayManager = TrayManager.instance;

class Menu {
  final List<MenuItem> items;
  
  Menu({required this.items});
}

class MenuItem {
  final String? label;
  final void Function(MenuItem)? onClick;
  
  MenuItem({this.label, this.onClick});
  
  static MenuItem separator() => MenuItem();
}
