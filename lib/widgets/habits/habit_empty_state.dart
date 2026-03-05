import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../Utils/app_theme_data.dart';

class HabitEmptyState extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final bool showArchived;
  final VoidCallback onAddHabit;

  const HabitEmptyState({
    Key? key,
    required this.isDark,
    required this.isMobile,
    required this.showArchived,
    required this.onAddHabit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showArchived
              ? Icon(
                  Icons.archive_outlined,
                  size: isMobile ? 80 : 100,
                  color:
                      (isDark
                              ? AppTheme.primaryColorDark
                              : AppTheme.primaryColor)
                          .withOpacity(0.3),
                )
              : SvgPicture.asset(
                  context.watch<ThemeProvider>().appTheme ==
                          AppThemeType.classic
                      ? 'assets/illustrations/online-meetings-classic.svg'
                      : 'assets/illustrations/online-meetings.svg',
                  height: isMobile ? 160 : 200,
                ),
          const SizedBox(height: 24),
          Text(
            showArchived ? 'No archived habits' : 'No habits yet',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              showArchived
                  ? 'Archived habits will appear here'
                  : 'Start your journey and build better habits today',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 16 : 18,
                color: isDark ? AppTheme.textMediumDark : AppTheme.textMedium,
              ),
            ),
          ),
          if (!showArchived) ...[
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddHabit,
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? AppTheme.primaryColorDark
                    : AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Create your first habit',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
