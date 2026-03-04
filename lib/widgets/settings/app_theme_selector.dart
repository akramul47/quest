import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../Utils/app_theme.dart';
import '../../Utils/app_theme_data.dart';
import '../../Utils/responsive_layout.dart';
import '../../providers/theme_provider.dart';

class AppThemeSelector extends StatelessWidget {
  const AppThemeSelector({Key? key}) : super(key: key);

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
                'App Theme',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
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
                  themeProvider.appTheme.displayName,
                  style: AppTheme.current.bodyTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.black : Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isTabletOrDesktop)
            Row(
              children: [
                for (int i = 0; i < AppThemeType.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 14),
                  Expanded(
                    child: _AppThemeCard(
                      type: AppThemeType.values[i],
                      themeProvider: themeProvider,
                      isDark: isDark,
                      isTablet: true,
                    ),
                  ),
                ],
              ],
            )
          else
            Column(
              children: [
                for (int i = 0; i < AppThemeType.values.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _AppThemeCard(
                    type: AppThemeType.values[i],
                    themeProvider: themeProvider,
                    isDark: isDark,
                    isTablet: false,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _AppThemeCard extends StatelessWidget {
  final AppThemeType type;
  final ThemeProvider themeProvider;
  final bool isDark;
  final bool isTablet;

  const _AppThemeCard({
    Key? key,
    required this.type,
    required this.themeProvider,
    required this.isDark,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = themeProvider.appTheme == type;
    final accentColor = isDark
        ? AppTheme.primaryColorDark
        : AppTheme.primaryColor;

    // Get swatch colors from the theme type for preview
    final previewData = ThemeProvider.resolveThemeData(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => themeProvider.setAppTheme(type),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isTablet ? 16 : 20),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: isDark
                          ? [
                              accentColor.withValues(alpha: 0.25),
                              accentColor.withValues(alpha: 0.12),
                            ]
                          : [
                              accentColor.withValues(alpha: 0.15),
                              accentColor.withValues(alpha: 0.08),
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
                    ? accentColor
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.1)),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.1),
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
            child: isTablet
                ? _buildVertical(previewData, isSelected, accentColor)
                : _buildHorizontal(previewData, isSelected, accentColor),
          ),
        ),
      ),
    );
  }

  Widget _buildVertical(
    AppThemeData previewData,
    bool isSelected,
    Color accentColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ColorSwatchPreview(previewData: previewData, size: 48),
        const SizedBox(height: 12),
        Text(
          type.displayName,
          style: AppTheme.current.headerTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          type.description,
          style: AppTheme.current.bodyTextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isSelected ? 8 : 0),
        SizedBox(
          height: 24,
          child: isSelected
              ? _SelectedCheckmark(isDark: isDark, accentColor: accentColor)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildHorizontal(
    AppThemeData previewData,
    bool isSelected,
    Color accentColor,
  ) {
    return Row(
      children: [
        _ColorSwatchPreview(previewData: previewData, size: 52),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.displayName,
                style: AppTheme.current.headerTextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: -0.2,
                  color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type.description,
                style: AppTheme.current.bodyTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
        AnimatedScale(
          scale: isSelected ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: _SelectedCheckmark(isDark: isDark, accentColor: accentColor),
        ),
      ],
    );
  }
}

/// Mini color swatch showing the theme's primary, secondary, and background.
class _ColorSwatchPreview extends StatelessWidget {
  final AppThemeData previewData;
  final double size;

  const _ColorSwatchPreview({required this.previewData, required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(color: previewData.primaryColor),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: Container(color: previewData.secondaryColor)),
                  Expanded(
                    child: Container(
                      color: isDark
                          ? previewData.backgroundGradientStartDark
                          : previewData.backgroundGradientStart,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkmark indicator for selected state.
class _SelectedCheckmark extends StatelessWidget {
  final bool isDark;
  final Color accentColor;

  const _SelectedCheckmark({required this.isDark, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withValues(alpha: 0.8)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
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
    );
  }
}
