import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import '../../widgets/animated_boom_logo.dart';

class AboutCard extends StatelessWidget {
  final String appVersion;

  const AboutCard({Key? key, required this.appVersion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          _SettingsBoomLogo(isDark: isDark),
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
}

class _SettingsBoomLogo extends StatefulWidget {
  final bool isDark;

  const _SettingsBoomLogo({required this.isDark});

  @override
  State<_SettingsBoomLogo> createState() => _SettingsBoomLogoState();
}

class _SettingsBoomLogoState extends State<_SettingsBoomLogo> {
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
