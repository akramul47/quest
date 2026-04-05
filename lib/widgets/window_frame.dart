import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:quest/Utils/app_theme.dart';
import 'package:quest/providers/window_state_provider.dart';
import 'package:quest/services/storage_service.dart';

class WindowFrame extends StatefulWidget {
  final Widget child;

  const WindowFrame({super.key, required this.child});

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> with WindowListener {
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

    return Container(
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
              // Show permanent header for mobile view on Windows
              if (isMobileView)
                GestureDetector(
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
                          ? AppTheme.primaryColorDark.withValues(alpha: 0.1)
                          : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.zero,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                        ),
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
                        const Spacer(),
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
                                await windowStateProvider.toggleAlwaysOnTop();
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
              Expanded(child: widget.child),
            ],
          );
        },
      ),
    );
  }
}
