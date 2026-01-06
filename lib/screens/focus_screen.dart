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

import '../widgets/focus/focus_header.dart';
import '../widgets/focus/session_label.dart';
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

    return Container(
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

                            // Determine "short screen" mode for heights less than 650px
                            final bool isShortScreen = availableHeight < 650;

                            // Calculate dynamic timer size: 40% of height, clamped between 160 and 280
                            final double timerSize =
                                (availableHeight *
                                        (isShortScreen ? 0.35 : 0.45))
                                    .clamp(160.0, isMobile ? 250.0 : 300.0);

                            return CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 20 : 40,
                                    ),
                                    child: Column(
                                      children: [
                                        // 1. Header
                                        FocusHeader(
                                          isDark: isDark,
                                          isMobile: isMobile,
                                        ),

                                        // 2. Main Timer Area (Top-Middle)
                                        Expanded(
                                          flex: isShortScreen ? 0 : 3,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: isShortScreen ? 16 : 0,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AnimatedOpacity(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  opacity:
                                                      (isDesktopPlatform &&
                                                          !isMobile)
                                                      ? (_isHovering
                                                            ? 1.0
                                                            : 0.0)
                                                      : 1.0,
                                                  child: SessionLabel(
                                                    provider: focusProvider,
                                                    isDark: isDark,
                                                    isMobile: isMobile,
                                                    isSmall: isShortScreen,
                                                  ),
                                                ),

                                                SizedBox(
                                                  height: isShortScreen
                                                      ? 12
                                                      : 32,
                                                ),

                                                CircularTimerDisplay(
                                                  timeText: focusProvider
                                                      .formattedTime,
                                                  progress:
                                                      focusProvider.progress,
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
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Push controls to bottom if there's space
                                        if (!isShortScreen)
                                          const Spacer(flex: 1),

                                        // 3. Bottom Controls Area (Sticky to bottom if height allows)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
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
                                                isSmall: isShortScreen,
                                              ),
                                            ),

                                            SizedBox(
                                              height: isShortScreen ? 12 : 24,
                                            ),

                                            AnimatedOpacity(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              opacity:
                                                  (isDesktopPlatform &&
                                                      !isMobile)
                                                  ? (_isHovering ? 1.0 : 0.0)
                                                  : 1.0,
                                              child: ControlButtons(
                                                provider: focusProvider,
                                                isDark: isDark,
                                                isMobile: isMobile,
                                                isSmall: isShortScreen,
                                              ),
                                            ),

                                            // Bottom safe-ish padding
                                            SizedBox(
                                              height: isMobile ? 32 : 48,
                                            ),
                                          ],
                                        ),

                                        // 4. Statistics (Always below the fold if screen is small)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 40,
                                          ),
                                          child: FocusStatistics(
                                            provider: focusProvider,
                                            isDark: isDark,
                                            isMobile: isMobile,
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
        ],
      ),
    );
  }
}
