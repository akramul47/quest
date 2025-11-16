import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../widgets/window_controls_bar.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({Key? key}) : super(key: key);

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTabletOrDesktop = deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;
    final bool showWindowControls = !kIsWeb && Platform.isWindows && isTabletOrDesktop;

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
      child: Column(
        children: [
          // Window controls bar for Windows tablet/desktop
          if (showWindowControls)
            WindowControlsBar(
              sidebarWidth: deviceType == DeviceType.desktop ? 220 : 72,
              showDragIndicator: true,
            ),
          // Main content
          Expanded(
            child: SafeArea(
              top: !showWindowControls, // No top safe area on Windows tablet/desktop
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.military_tech_outlined,
                      size: isMobile ? 80 : 100,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quest',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 32 : 40,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Complete challenges and level up your productivity',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 16 : 18,
                          color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
