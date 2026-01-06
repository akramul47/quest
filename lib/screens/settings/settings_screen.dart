import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_layout.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/window_controls_bar.dart';
import 'appearance_section.dart';
import 'data_management_section.dart';
import 'about_section.dart';

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
      duration: const Duration(milliseconds: 800),
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
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark =
        themeProvider.themeMode == AppThemeMode.dark ||
        (themeProvider.themeMode == AppThemeMode.system &&
            brightness == Brightness.dark);
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0E27),
                    const Color(0xFF1A1F3A),
                    const Color(0xFF0F1419),
                  ]
                : [
                    const Color(0xFFF5F7FA),
                    const Color(0xFFE8EDF5),
                    const Color(0xFFDCE4F0),
                  ],
          ),
        ),
        child: Column(
          children: [
            // Window controls for desktop
            if (isDesktop) const WindowControlsBar(),

            // Main content
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: ResponsiveLayout.responsivePadding(
                        context,
                      ).copyWith(top: 24, bottom: 0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          AppTheme.primaryColorDark.withValues(
                                            alpha: 0.3,
                                          ),
                                          AppTheme.primaryColorDark.withValues(
                                            alpha: 0.2,
                                          ),
                                        ]
                                      : [
                                          AppTheme.primaryColor.withValues(
                                            alpha: 0.25,
                                          ),
                                          AppTheme.primaryColor.withValues(
                                            alpha: 0.15,
                                          ),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.primaryColorDark.withValues(
                                          alpha: 0.4,
                                        )
                                      : AppTheme.primaryColor.withValues(
                                          alpha: 0.35,
                                        ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? AppTheme.primaryColorDark
                                                : AppTheme.primaryColor)
                                            .withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.settings_rounded,
                                size: 28,
                                color: isDark
                                    ? AppTheme.primaryColorDark
                                    : AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              ' Settings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppTheme.textDarkMode
                                    : AppTheme.textDark,
                                letterSpacing: -0.5,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
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
                              AppearanceSection(isDark: isDark),
                              const SizedBox(height: 40),

                              // Data Management Section
                              DataManagementSection(isDark: isDark),
                              const SizedBox(height: 40),

                              // About Section
                              AboutSection(
                                isDark: isDark,
                                appVersion: _appVersion,
                              ),
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
