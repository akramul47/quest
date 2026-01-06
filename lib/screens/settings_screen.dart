import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';

import '../widgets/window_controls_bar.dart';

import '../widgets/settings/settings_section_header.dart';
import '../widgets/settings/theme_selector.dart';
import '../widgets/settings/data_management_card.dart';
import '../widgets/settings/about_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final bool isTabletOrDesktop =
        deviceType == DeviceType.tablet || deviceType == DeviceType.desktop;
    final bool showWindowControls =
        !kIsWeb && Platform.isWindows && isTabletOrDesktop;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Window controls bar for Windows tablet/desktop
            if (showWindowControls)
              const WindowControlsBar(
                showBackButton: true,
                showDragIndicator: false,
              ),
            // Main content
            Expanded(
              child: SafeArea(
                top:
                    !showWindowControls, // No top safe area on Windows tablet/desktop (controls handle it)
                bottom: true,
                left: false,
                right: false,
                child: Column(
                  children: [
                    // Header with back button and title - only show on mobile
                    if (!showWindowControls)
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                          left: deviceType == DeviceType.mobile
                              ? 16
                              : deviceType == DeviceType.tablet
                              ? 24
                              : 32,
                          right: deviceType == DeviceType.mobile
                              ? 16
                              : deviceType == DeviceType.tablet
                              ? 24
                              : 32,
                          top: 8,
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : Colors.black.withValues(alpha: 0.08),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: isDark
                                      ? AppTheme.textDarkMode
                                      : AppTheme.textDark,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            Text(
                              ' Settings',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppTheme.textDarkMode
                                    : AppTheme.textDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Scrollable content
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: ResponsiveLayout.responsivePadding(
                            context,
                          ).copyWith(top: 24, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Appearance Section
                              const SettingsSectionHeader(
                                title: 'Appearance',
                                icon: Icons.palette_outlined,
                              ),
                              const SizedBox(height: 20),
                              const ThemeSelector(),
                              const SizedBox(height: 40),

                              // Data Management Section
                              const SettingsSectionHeader(
                                title: 'Data Management',
                                icon: Icons.storage_outlined,
                              ),
                              const SizedBox(height: 20),
                              const DataManagementCard(),
                              const SizedBox(height: 40),

                              // About Section
                              const SettingsSectionHeader(
                                title: 'About',
                                icon: Icons.info_outline,
                              ),
                              const SizedBox(height: 20),
                              AboutCard(appVersion: _appVersion),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
