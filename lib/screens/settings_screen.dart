import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_boom_logo.dart';
import '../widgets/window_controls_bar.dart';
import '../services/cache/cache_repository.dart';
import '../models/todo_list.dart';
import '../providers/habit_provider.dart';
import 'package:file_picker/file_picker.dart';

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
    final themeProvider = context.watch<ThemeProvider>();
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
                        // color: isDark ? Colors.black : Colors.white,
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
                              _buildSectionHeader(
                                context,
                                'Appearance',
                                Icons.palette_outlined,
                              ),
                              const SizedBox(height: 20),
                              _buildThemeSelector(
                                context,
                                themeProvider,
                                isDark,
                              ),
                              const SizedBox(height: 40),

                              // Data Management Section
                              _buildSectionHeader(
                                context,
                                'Data Management',
                                Icons.storage_outlined,
                              ),
                              const SizedBox(height: 20),
                              _buildDataManagementCard(context, isDark),
                              const SizedBox(height: 40),

                              // About Section
                              _buildSectionHeader(
                                context,
                                'About',
                                Icons.info_outline,
                              ),
                              const SizedBox(height: 20),
                              _buildAboutCard(context, isDark),
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                  (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                      .withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDark
                              ? AppTheme.primaryColorDark
                              : AppTheme.primaryColor)
                          .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    final isTabletOrDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Theme Mode',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDark
                          ? AppTheme.primaryColorDark
                          : AppTheme.primaryColor),
                      (isDark
                              ? AppTheme.primaryColorDark
                              : AppTheme.primaryColor)
                          .withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppTheme.primaryColorDark
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  themeProvider.themeModeDisplayName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.black : Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Responsive layout: side-by-side for tablet/desktop, stacked for mobile
          if (isTabletOrDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    context,
                    'System',
                    'Follow device settings',
                    Icons.brightness_auto_rounded,
                    AppThemeMode.system,
                    themeProvider,
                    isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    'Light',
                    'Bright & colorful',
                    Icons.light_mode_rounded,
                    AppThemeMode.light,
                    themeProvider,
                    isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    'Dark',
                    'Pure AMOLED black',
                    Icons.dark_mode_rounded,
                    AppThemeMode.dark,
                    themeProvider,
                    isDark,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildThemeOption(
                  context,
                  'System',
                  'Follow device settings',
                  Icons.brightness_auto_rounded,
                  AppThemeMode.system,
                  themeProvider,
                  isDark,
                ),
                const SizedBox(height: 14),
                _buildThemeOption(
                  context,
                  'Light',
                  'Bright & colorful',
                  Icons.light_mode_rounded,
                  AppThemeMode.light,
                  themeProvider,
                  isDark,
                ),
                const SizedBox(height: 14),
                _buildThemeOption(
                  context,
                  'Dark',
                  'Pure AMOLED black',
                  Icons.dark_mode_rounded,
                  AppThemeMode.dark,
                  themeProvider,
                  isDark,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AppThemeMode mode,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    final isTabletOrDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            themeProvider.setThemeMode(mode);
          },
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isTabletOrDesktop ? 16 : 20),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: isDark
                          ? [
                              AppTheme.primaryColorDark.withValues(alpha: 0.25),
                              AppTheme.primaryColorDark.withValues(alpha: 0.12),
                            ]
                          : [
                              AppTheme.primaryColor.withValues(alpha: 0.15),
                              AppTheme.primaryColor.withValues(alpha: 0.08),
                            ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? (isDark
                          ? AppTheme.primaryColorDark
                          : AppTheme.primaryColor)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.1)),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            (isDark
                                    ? AppTheme.primaryColorDark
                                    : AppTheme.primaryColor)
                                .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color:
                            (isDark
                                    ? AppTheme.primaryColorDark
                                    : AppTheme.primaryColor)
                                .withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.03,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: isTabletOrDesktop
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isDark
                                        ? AppTheme.primaryColorDark
                                        : AppTheme.primaryColor,
                                    (isDark
                                            ? AppTheme.primaryColorDark
                                            : AppTheme.primaryColor)
                                        .withValues(alpha: 0.85),
                                  ],
                                )
                              : LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withValues(alpha: 0.10),
                                          Colors.white.withValues(alpha: 0.06),
                                        ]
                                      : [
                                          Colors.black.withValues(alpha: 0.08),
                                          Colors.black.withValues(alpha: 0.04),
                                        ],
                                ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? AppTheme.primaryColorDark
                                                : AppTheme.primaryColor)
                                            .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark
                                    ? AppTheme.textMediumDark
                                    : AppTheme.textMedium),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textDarkMode
                              : AppTheme.textDark,
                          letterSpacing: -0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppTheme.textMediumDark
                              : AppTheme.textMedium,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSelected ? 8 : 0),
                      SizedBox(
                        height: 24,
                        child: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (isDark
                                          ? AppTheme.primaryColorDark
                                          : AppTheme.primaryColor),
                                      (isDark
                                              ? AppTheme.primaryColorDark
                                              : AppTheme.primaryColor)
                                          .withValues(alpha: 0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isDark
                                                  ? AppTheme.primaryColorDark
                                                  : AppTheme.primaryColor)
                                              .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: isDark ? Colors.black : Colors.white,
                                  size: 18,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isDark
                                        ? AppTheme.primaryColorDark
                                        : AppTheme.primaryColor,
                                    (isDark
                                            ? AppTheme.primaryColorDark
                                            : AppTheme.primaryColor)
                                        .withValues(alpha: 0.85),
                                  ],
                                )
                              : LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withValues(alpha: 0.10),
                                          Colors.white.withValues(alpha: 0.06),
                                        ]
                                      : [
                                          Colors.black.withValues(alpha: 0.08),
                                          Colors.black.withValues(alpha: 0.04),
                                        ],
                                ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? AppTheme.primaryColorDark
                                                : AppTheme.primaryColor)
                                            .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          size: 26,
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark
                                    ? AppTheme.textMediumDark
                                    : AppTheme.textMedium),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isDark
                                    ? AppTheme.textDarkMode
                                    : AppTheme.textDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? AppTheme.textMediumDark
                                    : AppTheme.textMedium,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedScale(
                        scale: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (isDark
                                    ? AppTheme.primaryColorDark
                                    : AppTheme.primaryColor),
                                (isDark
                                        ? AppTheme.primaryColorDark
                                        : AppTheme.primaryColor)
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? AppTheme.primaryColorDark
                                            : AppTheme.primaryColor)
                                        .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: isDark ? Colors.black : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // App Header with Icon, Name and Version
          Row(
            children: [
              // App Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark
                          ? AppTheme.primaryColorDark
                          : AppTheme.primaryColor,
                      (isDark
                              ? AppTheme.primaryColorDark
                              : AppTheme.primaryColor)
                          .withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppTheme.primaryColorDark
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),

              // App Name and Version
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quest',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark
                                ? AppTheme.primaryColorDark
                                : AppTheme.primaryColor,
                            (isDark
                                    ? AppTheme.primaryColorDark
                                    : AppTheme.primaryColor)
                                .withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _appVersion,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // App Description
          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                height: 1.8,
                letterSpacing: 0.3,
              ),
              children: [
                const TextSpan(text: 'Your life, organized by '),
                TextSpan(
                  text: 'intent',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.primaryColorDark
                        : AppTheme.primaryColor,
                  ),
                ),
                const TextSpan(
                  text: '. Quest transforms mundane checklists into ',
                ),
                TextSpan(
                  text: 'purposeful missions',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.primaryColorDark
                        : AppTheme.primaryColor,
                  ),
                ),
                const TextSpan(text: '—turning habits into '),
                const TextSpan(
                  text: 'streaks',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const TextSpan(text: ', tasks into '),
                const TextSpan(
                  text: 'victories',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const TextSpan(text: ', and focus time into '),
                TextSpan(
                  text: 'flow state',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.primaryColorDark
                        : AppTheme.primaryColor,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Designed and Developed by
          Text(
            'Designed and Developed by',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textMediumDark.withValues(alpha: 0.7)
                  : AppTheme.textMedium.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // BOOM Logo
          _BoomLogo(isDark: isDark),
          const SizedBox(height: 32),

          // Built using Flutter with love
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Built with ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                  letterSpacing: 0.2,
                ),
              ),
              const Text(
                '♥',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFE53935),
                  height: 1.0,
                ),
              ),
              Text(
                ' using ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                  letterSpacing: 0.2,
                ),
              ),
              const FlutterLogo(size: 16),
            ],
          ),
        ],
      ),
    );
  }

  // Data Management Helper Methods

  Widget _buildDataManagementCard(BuildContext context, bool isDark) {
    final cacheRepo = context.read<CacheRepository>();
    final todoList = context.read<TodoList>();
    final habitList = context.read<HabitList>();
    final isTabletOrDesktop = ResponsiveLayout.isTabletOrDesktop(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.04)]
              : [Colors.white.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup & Restore',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your data for backup or import from a previous backup',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              letterSpacing: 0.1,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          if (isTabletOrDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Export Data',
                    'Create backup file',
                    Icons.upload_file_rounded,
                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                    () => _handleExport(context, cacheRepo, isDark),
                    isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Import Data',
                    'Restore from backup',
                    Icons.download_rounded,
                    Colors.blue,
                    () => _handleImport(
                      context,
                      cacheRepo,
                      todoList,
                      habitList,
                      isDark,
                    ),
                    isDark,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildActionButton(
                  context,
                  'Export Data',
                  'Create backup file',
                  Icons.upload_file_rounded,
                  isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  () => _handleExport(context, cacheRepo, isDark),
                  isDark,
                ),
                const SizedBox(height: 14),
                _buildActionButton(
                  context,
                  'Import Data',
                  'Restore from backup',
                  Icons.download_rounded,
                  Colors.blue,
                  () => _handleImport(
                    context,
                    cacheRepo,
                    todoList,
                    habitList,
                    isDark,
                  ),
                  isDark,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.03),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.02),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.textDarkMode
                            : AppTheme.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppTheme.textMediumDark
                            : AppTheme.textMedium,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    CacheRepository cacheRepo,
    bool isDark,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Exporting data...',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      final file = await cacheRepo.exportToFile(appVersion: appVersion);

      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        await _showExportSuccessDialog(context, file.path, isDark);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        await _showErrorDialog(
          context,
          'Export Failed',
          'Failed to export data: $e',
          isDark,
        );
      }
    }
  }

  Future<void> _handleImport(
    BuildContext context,
    CacheRepository cacheRepo,
    TodoList todoList,
    HabitList habitList,
    bool isDark,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Quest Backup File',
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) {
        if (context.mounted) {
          await _showErrorDialog(
            context,
            'Import Failed',
            'Could not access the selected file',
            isDark,
          );
        }
        return;
      }

      if (!context.mounted) return;
      final importMode = await _showImportModeDialog(context, isDark);
      if (importMode == null) return;

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Importing data...',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final result2 = await cacheRepo.importFromFile(
        filePath,
        replace: importMode == 'replace',
      );

      if (context.mounted) Navigator.pop(context);

      if (result2.success) {
        await todoList.refresh();
        await habitList.refresh();

        if (context.mounted) {
          await _showImportSuccessDialog(context, result2, isDark);
        }
      } else {
        if (context.mounted) {
          await _showErrorDialog(
            context,
            'Import Failed',
            result2.error ?? 'Unknown error',
            isDark,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        await _showErrorDialog(
          context,
          'Import Failed',
          'Failed to import data: $e',
          isDark,
        );
      }
    }
  }

  Future<void> _showExportSuccessDialog(
    BuildContext context,
    String filePath,
    bool isDark,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Export Successful',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Your data has been exported successfully to:\n\n$filePath',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showImportModeDialog(
    BuildContext context,
    bool isDark,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.merge_rounded,
                color: Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Import Mode',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how to import your data:',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildImportModeOption(
              'Merge',
              'Add imported data to existing data',
              Icons.merge_type_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildImportModeOption(
              'Replace All',
              'Delete all existing data and replace with imported data',
              Icons.warning_amber_rounded,
              isDark,
              isWarning: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            child: Text(
              'Merge',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
            ),
            child: Text(
              'Replace All',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportModeOption(
    String title,
    String description,
    IconData icon,
    bool isDark, {
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.withValues(alpha: 0.1)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? Colors.red.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isWarning
                ? Colors.red
                : (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isWarning
                        ? Colors.red
                        : (isDark ? AppTheme.textDarkMode : AppTheme.textDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textMediumDark
                        : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportSuccessDialog(
    BuildContext context,
    ImportResult result,
    bool isDark,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                        .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Import Successful',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Successfully imported:\n\n'
          '• ${result.todosImported} todos\n'
          '• ${result.habitsImported} habits\n'
          '• ${result.sessionsImported} focus sessions',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(
    BuildContext context,
    String title,
    String message,
    bool isDark,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_rounded,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoomLogo extends StatefulWidget {
  final bool isDark;

  const _BoomLogo({required this.isDark});

  @override
  State<_BoomLogo> createState() => _BoomLogoState();
}

class _BoomLogoState extends State<_BoomLogo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? [
                  AppTheme.primaryColorDark.withValues(alpha: 0.35),
                  AppTheme.primaryColorDark.withValues(alpha: 0.25),
                ]
              : [
                  AppTheme.primaryColor.withValues(alpha: 0.12),
                  AppTheme.primaryColor.withValues(alpha: 0.06),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.isDark
              ? AppTheme.primaryColorDark.withValues(alpha: 0.5)
              : AppTheme.primaryColor.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (widget.isDark
                        ? AppTheme.primaryColorDark
                        : AppTheme.primaryColor)
                    .withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 200,
            width: 200,
            child: AnimatedBoomLogo(
              isDark: widget.isDark,
              size: 200,
              primaryColor: widget.isDark
                  ? AppTheme.primaryColorDark
                  : AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

// Data Management Helper Methods
