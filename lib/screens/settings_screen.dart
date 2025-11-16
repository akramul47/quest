import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../Utils/app_theme.dart';
import '../Utils/responsive_layout.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
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
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveLayout.responsivePadding(context).copyWith(top: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Appearance Section
                _buildSectionHeader(context, 'Appearance', Icons.palette_outlined),
                const SizedBox(height: 20),
                _buildThemeSelector(context, themeProvider, isDark),
                const SizedBox(height: 40),
                
                // About Section
                _buildSectionHeader(context, 'About', Icons.info_outline),
                const SizedBox(height: 20),
                _buildAboutCard(context, isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
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
                  (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
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

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider, bool isDark) {
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
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.04),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withOpacity(0.1)
                : Colors.white.withOpacity(0.6),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
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
                              AppTheme.primaryColorDark.withOpacity(0.25),
                              AppTheme.primaryColorDark.withOpacity(0.12),
                            ]
                          : [
                              AppTheme.primaryColor.withOpacity(0.15),
                              AppTheme.primaryColor.withOpacity(0.08),
                            ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor)
                    : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1)),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
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
                                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                                    (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.85),
                                  ],
                                )
                              : LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withOpacity(0.10),
                                          Colors.white.withOpacity(0.06),
                                        ]
                                      : [
                                          Colors.black.withOpacity(0.08),
                                          Colors.black.withOpacity(0.04),
                                        ],
                                ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.4),
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
                              : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
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
                          color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
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
                                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
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
                                    isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                                    (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.85),
                                  ],
                                )
                              : LinearGradient(
                                  colors: isDark
                                      ? [
                                          Colors.white.withOpacity(0.10),
                                          Colors.white.withOpacity(0.06),
                                        ]
                                      : [
                                          Colors.black.withOpacity(0.08),
                                          Colors.black.withOpacity(0.04),
                                        ],
                                ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.4),
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
                              : (isDark ? AppTheme.textMediumDark : AppTheme.textMedium),
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
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
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
                                (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor),
                                (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
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
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.04),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 35,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: isDark
                ? AppTheme.primaryColorDark.withOpacity(0.1)
                : Colors.white.withOpacity(0.6),
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
                      isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                      (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.3),
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
                        color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                            (isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
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
                TextSpan(
                  text: 'Your life, organized by ',
                ),
                TextSpan(
                  text: 'intent',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: '. Quest transforms mundane checklists into ',
                ),
                TextSpan(
                  text: 'purposeful missions',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: '—turning habits into ',
                ),
                TextSpan(
                  text: 'streaks',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ', tasks into ',
                ),
                TextSpan(
                  text: 'victories',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ', and focus time into ',
                ),
                TextSpan(
                  text: 'flow state',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                  ),
                ),
                TextSpan(
                  text: '.',
                ),
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
              color: isDark ? AppTheme.textMediumDark.withOpacity(0.7) : AppTheme.textMedium.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Logo with Video
          _LogoWithVideo(isDark: isDark),
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
              const FlutterLogo(
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogoWithVideo extends StatefulWidget {
  final bool isDark;

  const _LogoWithVideo({required this.isDark});

  @override
  State<_LogoWithVideo> createState() => _LogoWithVideoState();
}

class _LogoWithVideoState extends State<_LogoWithVideo> with SingleTickerProviderStateMixin {
  Player? _player;
  VideoController? _videoController;
  bool _videoEnded = false;
  bool _videoError = false;
  bool _isVisible = false;
  bool _isPlayingVideo = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.value = 1.0; // Start with logo visible
  }

  Future<void> _initializeVideo() async {
    if (_player != null || _isPlayingVideo) return;

    setState(() {
      _isPlayingVideo = true;
      _videoEnded = false;
      _videoError = false;
    });

    try {
      _player = Player();
      _videoController = VideoController(_player!);
      
      // Listen to player state
      _player!.stream.completed.listen((completed) {
        if (completed && !_videoEnded) {
          if (mounted) {
            setState(() {
              _videoEnded = true;
              _isPlayingVideo = false;
            });
            _fadeController.forward(); // Fade in logo
          }
        }
      });

      await _player!.open(Media('asset:///assets/boom_logo.mp4'));
      
      if (!mounted) return;

      // Wait for video to be buffered and ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Wait until video is actually buffered
      bool isBuffered = false;
      int attempts = 0;
      while (!isBuffered && attempts < 20 && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        // Check if player is ready (has duration)
        final duration = _player!.state.duration;
        if (duration != Duration.zero) {
          isBuffered = true;
        }
        attempts++;
      }
      
      if (!mounted) return;

      setState(() {});
      
      // Fade out logo
      await _fadeController.reverse();
      
      if (mounted && _player != null) {
        await _player!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoError = true;
          _isPlayingVideo = false;
        });
        _fadeController.forward(); // Fade logo back in
      }
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final bool nowVisible = info.visibleFraction > 0.3; // More than 30% visible
    
    if (nowVisible && !_isVisible && !_isPlayingVideo) {
      setState(() {
        _isVisible = true;
      });
      _initializeVideo();
    } else if (!nowVisible && _isVisible) {
      setState(() {
        _isVisible = false;
      });
      // Cleanup player when not visible
      if (_videoEnded && _player != null) {
        _player?.dispose();
        _player = null;
        _videoController = null;
        _fadeController.value = 1.0; // Reset to logo visible
      }
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('logo-video-detector'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? [
                    AppTheme.primaryColorDark.withOpacity(0.35),
                    AppTheme.primaryColorDark.withOpacity(0.25),
                  ]
                : [
                    AppTheme.primaryColor.withOpacity(0.12),
                    AppTheme.primaryColor.withOpacity(0.06),
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: widget.isDark
                ? AppTheme.primaryColorDark.withOpacity(0.5)
                : AppTheme.primaryColor.withOpacity(0.25),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                children: [
                  // Logo image (always present, fades out during video)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      'assets/boom.png',
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
                                (widget.isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            size: 80,
                            color: widget.isDark ? Colors.black : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  // Video player (shown when playing, inverse fade)
                  if (_videoController != null && !_videoEnded && !_videoError)
                    FadeTransition(
                      opacity: ReverseAnimation(_fadeAnimation),
                      child: Video(
                        controller: _videoController!,
                        fit: BoxFit.contain,
                        controls: NoVideoControls,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
