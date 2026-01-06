import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../widgets/settings/brand_logo.dart';

class AboutSection extends StatelessWidget {
  final bool isDark;
  final String appVersion;

  const AboutSection({Key? key, required this.isDark, required this.appVersion})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 20),
        _buildAboutCard(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppTheme.primaryColorDark.withValues(alpha: 0.25),
                      AppTheme.primaryColorDark.withValues(alpha: 0.15),
                    ]
                  : [
                      AppTheme.primaryColor.withValues(alpha: 0.2),
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppTheme.primaryColorDark.withValues(alpha: 0.3)
                  : AppTheme.primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.info_outline,
            size: 22,
            color: isDark ? AppTheme.primaryColorDark : AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'About',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard(BuildContext context) {
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
          // App Name & Version
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppTheme.primaryColorDark.withValues(alpha: 0.25),
                            AppTheme.primaryColorDark.withValues(alpha: 0.15),
                          ]
                        : [
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.primaryColorDark.withValues(alpha: 0.4)
                        : AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Quest',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppTheme.primaryColorDark
                            : AppTheme.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryColorDark.withValues(alpha: 0.3)
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        appVersion,
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
          BrandLogo(isDark: isDark),
          const SizedBox(height: 32),

          // Flutter Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Built with',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const FlutterLogo(size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
