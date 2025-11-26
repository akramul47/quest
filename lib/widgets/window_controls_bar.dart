import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../Utils/app_theme.dart';
import '../providers/window_state_provider.dart';

class WindowControlsBar extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double sidebarWidth; // Width of the sidebar (if any)
  final bool showDragIndicator; // Whether to show the drag indicator

  const WindowControlsBar({
    Key? key,
    this.showBackButton = false,
    this.onBackPressed,
    this.sidebarWidth = 0, // Default: no sidebar
    this.showDragIndicator = true, // Default: show indicator
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final windowStateProvider = context.watch<WindowStateProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Calculate the offset to center the indicator in the full window
    // If there's a sidebar, we need to shift left by half its width
    final centerOffset = sidebarWidth > 0 ? -(sidebarWidth / 2) : 0.0;

    return GestureDetector(
      onPanStart: (_) {
        if (!kIsWeb && Platform.isWindows) {
          windowManager.startDragging();
        }
      },
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.glassBackgroundDark.withOpacity(0.3)
              : AppTheme.glassBackground.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
        ),
        child: Stack(
          children: [
            // Centered drag indicator (adjusted for sidebar)
            if (showDragIndicator)
              Positioned.fill(
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: Transform.translate(
                    offset: Offset(centerOffset, 0),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Control buttons row
            Row(
              children: [
                // Back button (optional, for detail screens)
                if (showBackButton)
                  _buildWindowButton(
                    icon: Icons.arrow_back,
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                    isDark: isDark,
                    isAlwaysOnTop: windowStateProvider.isAlwaysOnTop,
                  ),
                const Spacer(),
                // Pin/Always on top button
                _buildWindowButton(
                  icon: windowStateProvider.isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                  onPressed: () => windowStateProvider.toggleAlwaysOnTop(),
                  isDark: isDark,
                  isPin: true,
                  isAlwaysOnTop: windowStateProvider.isAlwaysOnTop,
                ),
                // Minimize button
                _buildWindowButton(
                  icon: Icons.minimize_rounded,
                  onPressed: () {
                    if (!kIsWeb && Platform.isWindows) {
                      windowManager.minimize();
                    }
                  },
                  isDark: isDark,
                  isAlwaysOnTop: windowStateProvider.isAlwaysOnTop,
                ),
                // Maximize/Restore button
                _buildWindowButton(
                  icon: Icons.crop_square_rounded,
                  onPressed: () async {
                    if (!kIsWeb && Platform.isWindows) {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    }
                  },
                  isDark: isDark,
                  isAlwaysOnTop: windowStateProvider.isAlwaysOnTop,
                ),
                // Close button
                _buildWindowButton(
                  icon: Icons.close_rounded,
                  onPressed: () {
                    if (!kIsWeb && Platform.isWindows) {
                      windowManager.close();
                    }
                  },
                  isDark: isDark,
                  isClose: true,
                  isAlwaysOnTop: windowStateProvider.isAlwaysOnTop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    required bool isAlwaysOnTop,
    bool isClose = false,
    bool isPin = false,
  }) {
    return SizedBox(
      width: 46,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: isPin && isAlwaysOnTop
              ? (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
              : (isDark ? AppTheme.textDarkMode : AppTheme.textDark),
        ),
        hoverColor: isClose
            ? Colors.red.withOpacity(0.8)
            : (isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05)),
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(),
        ),
      ),
    );
  }
}
