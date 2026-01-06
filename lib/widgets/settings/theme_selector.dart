import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/responsive_layout.dart';
import '../../providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  child: _ThemeOption(
                    title: 'System',
                    subtitle: 'Follow device settings',
                    icon: Icons.brightness_auto_rounded,
                    mode: AppThemeMode.system,
                    themeProvider: themeProvider,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ThemeOption(
                    title: 'Light',
                    subtitle: 'Bright & colorful',
                    icon: Icons.light_mode_rounded,
                    mode: AppThemeMode.light,
                    themeProvider: themeProvider,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ThemeOption(
                    title: 'Dark',
                    subtitle: 'Pure AMOLED black',
                    icon: Icons.dark_mode_rounded,
                    mode: AppThemeMode.dark,
                    themeProvider: themeProvider,
                    isDark: isDark,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _ThemeOption(
                  title: 'System',
                  subtitle: 'Follow device settings',
                  icon: Icons.brightness_auto_rounded,
                  mode: AppThemeMode.system,
                  themeProvider: themeProvider,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _ThemeOption(
                  title: 'Light',
                  subtitle: 'Bright & colorful',
                  icon: Icons.light_mode_rounded,
                  mode: AppThemeMode.light,
                  themeProvider: themeProvider,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _ThemeOption(
                  title: 'Dark',
                  subtitle: 'Pure AMOLED black',
                  icon: Icons.dark_mode_rounded,
                  mode: AppThemeMode.dark,
                  themeProvider: themeProvider,
                  isDark: isDark,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AppThemeMode mode;
  final ThemeProvider themeProvider;
  final bool isDark;

  const _ThemeOption({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.mode,
    required this.themeProvider,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
