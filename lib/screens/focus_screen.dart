import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../providers/focus_provider.dart';
import '../models/timer_state.dart';
import '../widgets/circular_timer_display.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/completion_celebration.dart';
import '../widgets/window_controls_bar.dart';
import '../widgets/focus_settings_sheet.dart';

import '../widgets/focus/focus_header.dart';
import '../widgets/focus/control_buttons.dart';
import '../widgets/focus/duration_selector.dart';
import '../widgets/focus/focus_statistics.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({Key? key}) : super(key: key);

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _isHovering = false;
  bool _isSettingsVisible = false;

  void _toggleSettings() {
    setState(() {
      _isSettingsVisible = !_isSettingsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTabletOrDesktop =
        deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;
    final bool showWindowControls =
        !kIsWeb && Platform.isWindows && isTabletOrDesktop;
    final bool isDesktopPlatform =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    return PopScope(
      canPop: !_isSettingsVisible,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSettingsVisible) {
          _toggleSettings();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.backgroundGradientStartDark,
                    AppTheme.backgroundGradientEndDark,
                  ]
                : [
                    AppTheme.backgroundGradientStart,
                    AppTheme.backgroundGradientEnd,
                  ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                if (showWindowControls)
                  WindowControlsBar(
                    sidebarWidth: deviceType == DeviceType.desktop ? 220 : 72,
                    showDragIndicator: true,
                  ),
                Expanded(
                  child: SafeArea(
                    top: !showWindowControls,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHovering = true),
                      onExit: (_) => setState(() => _isHovering = false),
                      child: Consumer<FocusProvider>(
                        builder: (context, focusProvider, child) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final availableHeight = constraints.maxHeight;

                              // Define screen height categories
                              final isVeryShort = availableHeight < 500;
                              final isShort = availableHeight < 650;

                              // Calculate component heights with guaranteed minimums
                              final headerHeight = 70.0;
                              final statisticsHeight = 140.0;
                              final bottomControlsMinHeight = isVeryShort
                                  ? 120.0
                                  : (isShort ? 160.0 : 200.0);
                              final minSpacing = isVeryShort
                                  ? 8.0
                                  : (isShort ? 12.0 : 16.0);

                              // Calculate available space for timer
                              final timerAreaHeight =
                                  availableHeight -
                                  headerHeight -
                                  bottomControlsMinHeight -
                                  statisticsHeight -
                                  (minSpacing * 3);

                              // Timer size: responsive based on available space
                              // Bigger on smaller screens for better visual impact
                              final timerSize = (timerAreaHeight * 0.85).clamp(
                                isMobile
                                    ? 240.0
                                    : 220.0, // Minimum - larger on mobile
                                isMobile ? 300.0 : 320.0, // Maximum
                              );

                              // Determine if we need compact mode
                              final useCompactMode =
                                  isVeryShort || timerAreaHeight < 200;

                              return Stack(
                                children: [
                                  // Main scrollable content
                                  SingleChildScrollView(
                                    padding: EdgeInsets.only(
                                      left: isMobile ? 20 : 40,
                                      right: isMobile ? 20 : 40,
                                      bottom:
                                          bottomControlsMinHeight +
                                          20, // Space for fixed bottom controls
                                    ),
                                    child: Column(
                                      children: [
                                        // Header
                                        FocusHeader(
                                          isDark: isDark,
                                          isMobile: isMobile,
                                          onSettingsTap: _toggleSettings,
                                        ),

                                        SizedBox(height: minSpacing),

                                        // Spacer to position timer lower on screen
                                        SizedBox(
                                          height:
                                              (((availableHeight -
                                                              headerHeight -
                                                              bottomControlsMinHeight) /
                                                          2.5) - // Changed from /2 to /2.5 for lower positioning
                                                      (timerSize / 2))
                                                  .clamp(8.0, double.infinity),
                                        ),

                                        // Timer Display - centered in available space
                                        CircularTimerDisplay(
                                          timeText: focusProvider.formattedTime,
                                          progress: focusProvider.progress,
                                          isRunning:
                                              focusProvider.status ==
                                              TimerStatus.running,
                                          primaryColor:
                                              focusProvider
                                                      .currentSessionType !=
                                                  SessionType.focus
                                              ? Colors.green
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          backgroundColor: isDark
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.white,
                                          size: timerSize,
                                        ),

                                        // Push statistics below the fold with large spacing
                                        SizedBox(height: availableHeight * 0.3),

                                        // Statistics (scrollable area - below the fold)
                                        FocusStatistics(
                                          provider: focusProvider,
                                          isDark: isDark,
                                          isMobile: isMobile,
                                        ),

                                        const SizedBox(height: 60),
                                      ],
                                    ),
                                  ),

                                  // Fixed bottom controls
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: isDark
                                              ? [
                                                  AppTheme
                                                      .backgroundGradientStartDark
                                                      .withValues(alpha: 0.0),
                                                  AppTheme
                                                      .backgroundGradientStartDark
                                                      .withValues(alpha: 0.95),
                                                  AppTheme
                                                      .backgroundGradientStartDark,
                                                ]
                                              : [
                                                  AppTheme
                                                      .backgroundGradientStart
                                                      .withValues(alpha: 0.0),
                                                  AppTheme
                                                      .backgroundGradientStart
                                                      .withValues(alpha: 0.95),
                                                  AppTheme
                                                      .backgroundGradientStart,
                                                ],
                                        ),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: isMobile ? 20 : 40,
                                        right: isMobile ? 20 : 40,
                                        top: 24,
                                        bottom: isMobile ? 20 : 24,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Quick duration selector
                                          AnimatedOpacity(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            opacity:
                                                (focusProvider.status ==
                                                        TimerStatus.idle &&
                                                    focusProvider
                                                            .currentSessionType ==
                                                        SessionType.focus &&
                                                    ((isDesktopPlatform &&
                                                            !isMobile)
                                                        ? _isHovering
                                                        : true))
                                                ? 1.0
                                                : 0.0,
                                            child: DurationSelector(
                                              provider: focusProvider,
                                              isDark: isDark,
                                              isMobile: isMobile,
                                              isSmall: useCompactMode,
                                            ),
                                          ),

                                          SizedBox(
                                            height: useCompactMode ? 12 : 16,
                                          ),

                                          // Control buttons
                                          AnimatedOpacity(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            opacity:
                                                (isDesktopPlatform && !isMobile)
                                                ? (_isHovering ? 1.0 : 0.0)
                                                : 1.0,
                                            child: ControlButtons(
                                              provider: focusProvider,
                                              isDark: isDark,
                                              isMobile: isMobile,
                                              isSmall: useCompactMode,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Celebration overlay
            Consumer<FocusProvider>(
              builder: (context, focusProvider, child) {
                return Stack(
                  children: [
                    ConfettiOverlay(show: focusProvider.showCelebration),
                    CompletionCelebration(
                      show: focusProvider.showCelebration,
                      sessionsCompleted: focusProvider.completedFocusSessions,
                    ),
                  ],
                );
              },
            ),

            // Settings bottom modal
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: 4,
              right: 4,
              // Stop at the header area (window controls + SafeArea + header height + padding)
              top: _isSettingsVisible
                  ? (showWindowControls
                            ? 32.0
                            : MediaQuery.of(
                                context,
                              ).padding.top) + // Window controls or safe area
                        70.0 + // Header height (FocusHeader padding included)
                        16.0 // Gap before modal
                  : MediaQuery.of(context).size.height,
              bottom: _isSettingsVisible
                  ? 0
                  : -MediaQuery.of(context).size.height,
              child: Consumer<FocusProvider>(
                builder: (context, focusProvider, _) {
                  return FocusSettingsSheet(
                    provider: focusProvider,
                    onClose: _toggleSettings,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
