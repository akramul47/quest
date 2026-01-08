import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/streak_service.dart';
import '../Utils/app_theme.dart';
import '../widgets/streak_details/mandala_pattern_painter.dart';
import '../widgets/streak_details/streak_fire_icon.dart';
import '../widgets/streak_details/streak_count_display.dart';
import '../widgets/streak_details/motivational_text.dart';
import '../widgets/streak_details/week_calendar.dart';
import '../widgets/streak_details/check_in_button.dart';
import '../widgets/streak_details/stats_row.dart';
import '../widgets/streak_details/streak_action_buttons.dart';

/// Streak details screen with fire-themed UI, week calendar, and streak management.
class StreakDetailsScreen extends StatefulWidget {
  const StreakDetailsScreen({super.key});

  @override
  State<StreakDetailsScreen> createState() => _StreakDetailsScreenState();
}

class _StreakDetailsScreenState extends State<StreakDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppTheme.fireOrange : AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: _buildBackgroundGradient(isDark)),
        child: Stack(
          children: [
            // Mandala at gradient glow center
            Builder(
              builder: (context) {
                final mandalaSize = screenSize.width * 0.5;
                final gradientCenterY = screenSize.height * 0.35;
                return Positioned(
                  left: (screenSize.width - mandalaSize) / 2,
                  top: gradientCenterY - (mandalaSize / 2),
                  child: SizedBox(
                    width: mandalaSize,
                    height: mandalaSize,
                    child: CustomPaint(
                      painter: MandalaPatternPainter(
                        isDark: isDark,
                        size: mandalaSize,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Content
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Consumer<StreakService>(
                      builder: (context, streakService, child) {
                        return _buildContent(
                          context,
                          streakService,
                          isDark,
                          screenSize,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  RadialGradient _buildBackgroundGradient(bool isDark) {
    if (isDark) {
      return const RadialGradient(
        center: Alignment(0, -0.3),
        radius: 1.2,
        colors: [AppTheme.warmBrown, Color(0xFF0D0500), Colors.black],
        stops: [0.0, 0.5, 1.0],
      );
    }
    return RadialGradient(
      center: const Alignment(0, -0.3),
      radius: 1.2,
      colors: [
        AppTheme.primaryColor.withAlpha(38),
        AppTheme.backgroundGradientStart,
        AppTheme.backgroundGradientEnd,
      ],
      stops: const [0.0, 0.4, 1.0],
    );
  }

  Widget _buildContent(
    BuildContext context,
    StreakService streakService,
    bool isDark,
    Size screenSize,
  ) {
    final streakCount = streakService.currentStreak;
    final isActiveToday =
        streakService.streak?.lastActiveDate != null &&
        _isToday(streakService.streak!.lastActiveDate!);
    final freezeDays = streakService.freezeDaysAvailable;
    final restoreTokens = streakService.restoreTokens;
    final longestStreak = streakService.longestStreak;
    final isFrozen = streakService.isFrozenToday;
    final canRestore = streakService.streak?.canRestore ?? false;

    // Calculate responsive sizes based on screen height
    final fireSize = (screenSize.height * 0.12).clamp(80.0, 120.0);
    final streakFontSize = (screenSize.height * 0.06).clamp(36.0, 56.0);
    final spacing = (screenSize.height * 0.02).clamp(12.0, 24.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Fire Icon
        StreakFireIcon(size: fireSize, isDark: isDark),
        SizedBox(height: spacing),

        // Streak Count
        StreakCountDisplay(
          streak: streakCount,
          fontSize: streakFontSize,
          isDark: isDark,
        ),
        SizedBox(height: spacing * 0.5),

        // Motivational Text
        MotivationalText(
          streak: streakCount,
          isActiveToday: isActiveToday,
          isFrozen: isFrozen,
          isDark: isDark,
        ),
        SizedBox(height: spacing * 1.5),

        // Week Calendar
        WeekCalendar(streakService: streakService, isDark: isDark),
        SizedBox(height: spacing * 1.5),

        // CTA Button
        CheckInButton(
          isActiveToday: isActiveToday,
          isDark: isDark,
          onPressed: () => _showCheckInInfo(context),
        ),
        SizedBox(height: spacing * 1.5),

        // Stats Row
        StatsRow(
          freezeDays: freezeDays,
          restoreTokens: restoreTokens,
          longestStreak: longestStreak,
          isDark: isDark,
        ),
        SizedBox(height: spacing),

        // Action Buttons
        if (freezeDays > 0 || canRestore)
          StreakActionButtons(
            streakService: streakService,
            freezeDays: freezeDays,
            canRestore: canRestore,
            isDark: isDark,
            onFreeze: () => _freezeToday(streakService),
            onRestore: () => _restoreStreak(streakService),
          ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showCheckInInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final snackBarWidth = screenWidth > 480 ? 400.0 : screenWidth - 32;
    final horizontalMargin = (screenWidth - snackBarWidth) / 2;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Complete a task, log a habit, or finish a focus session to check in!',
          style: GoogleFonts.outfit(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isDark ? AppTheme.warmBrown : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 16,
          left: horizontalMargin,
          right: horizontalMargin,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _freezeToday(StreakService streakService) async {
    final success = await streakService.freezeToday();
    if (mounted) {
      final screenWidth = MediaQuery.of(context).size.width;
      final snackBarWidth = screenWidth > 480 ? 400.0 : screenWidth - 32;
      final horizontalMargin = (screenWidth - snackBarWidth) / 2;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Streak frozen for today! ❄️' : 'Could not freeze today',
            style: GoogleFonts.outfit(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: success ? Colors.blue : Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: 16,
            left: horizontalMargin,
            right: horizontalMargin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _restoreStreak(StreakService streakService) async {
    final success = await streakService.useRestoreToken();
    if (mounted) {
      final screenWidth = MediaQuery.of(context).size.width;
      final snackBarWidth = screenWidth > 480 ? 400.0 : screenWidth - 32;
      final horizontalMargin = (screenWidth - snackBarWidth) / 2;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Streak restored! 🔥' : 'Could not restore streak',
            style: GoogleFonts.outfit(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: success ? Colors.purple : Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: 16,
            left: horizontalMargin,
            right: horizontalMargin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
