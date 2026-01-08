import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../services/streak_service.dart';
import '../Utils/app_theme.dart';

/// Streak details screen with fire-themed UI, week calendar, and streak management.
class StreakDetailsScreen extends StatefulWidget {
  const StreakDetailsScreen({super.key});

  @override
  State<StreakDetailsScreen> createState() => _StreakDetailsScreenState();
}

class _StreakDetailsScreenState extends State<StreakDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fireController;

  // Streak colors for dark mode (fire theme)
  static const _fireOrange = Color(0xFFFF8C42);
  static const _fireOrangeDark = Color(0xFFFF6B00);
  static const _warmBrown = Color(0xFF1A0A00);
  static const _mutedOrange = Color(0xFFB86B3F);
  static const _inactiveGray = Color(0xFF3D3D3D);

  @override
  void initState() {
    super.initState();
    _fireController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

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
            color: isDark ? _fireOrange : AppTheme.textDark,
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
            Align(
              alignment: const Alignment(0, -1.5),
              child: SizedBox(
                width: screenSize.width * 0.5,
                height: screenSize.width * 0.5,
                child: CustomPaint(
                  painter: _MandalaPatternPainter(
                    isDark: isDark,
                    size: screenSize.width * 0.5,
                  ),
                ),
              ),
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
        colors: [_warmBrown, Color(0xFF0D0500), Colors.black],
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
    final streak = streakService.currentStreak;
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
        _buildFireIcon(fireSize, isDark),
        SizedBox(height: spacing),

        // Streak Count
        _buildStreakCount(streak, streakFontSize, isDark),
        SizedBox(height: spacing * 0.5),

        // Motivational Text
        _buildMotivationalText(streak, isActiveToday, isFrozen, isDark),
        SizedBox(height: spacing * 1.5),

        // Week Calendar
        _buildWeekCalendar(streakService, isDark),
        SizedBox(height: spacing * 1.5),

        // CTA Button
        _buildCTAButton(isActiveToday, isDark),
        SizedBox(height: spacing * 1.5),

        // Stats Row
        _buildStatsRow(freezeDays, restoreTokens, longestStreak, isDark),
        SizedBox(height: spacing),

        // Action Buttons
        if (freezeDays > 0 || canRestore)
          _buildActionButtons(streakService, freezeDays, canRestore, isDark),
      ],
    );
  }

  Widget _buildFireIcon(double size, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/streak_fire.json',
        controller: _fireController,
        fit: BoxFit.contain,
        onLoaded: (composition) {
          _fireController.duration = composition.duration;
          _fireController.repeat();
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.local_fire_department,
            color: isDark ? _fireOrange : AppTheme.primaryColor,
            size: size,
          );
        },
      ),
    );
  }

  Widget _buildStreakCount(int streak, double fontSize, bool isDark) {
    return Column(
      children: [
        Text(
          '$streak',
          style: GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: isDark ? _fireOrange : AppTheme.primaryColor,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Day Streak',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? _fireOrange : AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalText(
    int streak,
    bool isActiveToday,
    bool isFrozen,
    bool isDark,
  ) {
    String message;
    if (isFrozen) {
      message = 'Your streak is frozen for today';
    } else if (isActiveToday) {
      message = 'You\'re on fire! Keep it up!';
    } else if (streak == 0) {
      message = 'Start your streak today!';
    } else {
      message = 'Keep the fire alive\ncheck in today!';
    }

    return Text(
      message,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? _fireOrange : AppTheme.textDark,
        height: 1.4,
      ),
    );
  }

  Widget _buildWeekCalendar(StreakService streakService, bool isDark) {
    final now = DateTime.now();
    // Start from Sunday (weekday 7 becomes 0, so subtract weekday % 7)
    final weekStart = now.subtract(Duration(days: now.weekday % 7));
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(13)
            : Colors.white.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(26)
              : AppTheme.primaryColor.withAlpha(26),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final isToday = _isToday(date);
          final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
          final isActive = _wasActiveOnDate(streakService, date);

          return _buildDayIndicator(
            days[index],
            date.day,
            isToday: isToday,
            isPast: isPast,
            isActive: isActive,
            isDark: isDark,
          );
        }),
      ),
    );
  }

  Widget _buildDayIndicator(
    String dayLetter,
    int dayNumber, {
    required bool isToday,
    required bool isPast,
    required bool isActive,
    required bool isDark,
  }) {
    Color bgColor;
    Color textColor;
    Widget? checkMark;

    if (isToday) {
      bgColor = isDark ? _fireOrangeDark : AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isPast && isActive) {
      bgColor = Colors.transparent;
      textColor = isDark ? _mutedOrange : AppTheme.textMedium;
      checkMark = Icon(
        Icons.check,
        size: 18,
        color: isDark ? _fireOrange : AppTheme.primaryColor,
      );
    } else {
      bgColor = isDark ? _inactiveGray : Colors.grey.shade200;
      textColor = isDark ? Colors.white54 : AppTheme.textLight;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayLetter,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : AppTheme.textMedium,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(
            child:
                checkMark ??
                Text(
                  '$dayNumber',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(bool isActiveToday, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActiveToday ? null : () => _showCheckInInfo(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? _fireOrange : AppTheme.primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          disabledBackgroundColor: isDark
              ? _fireOrange.withOpacity(0.3)
              : AppTheme.primaryColor.withOpacity(0.3),
          disabledForegroundColor: isDark ? Colors.black54 : Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          isActiveToday ? 'You\'re on fire! 🔥' : 'Check in today!',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    int freezeDays,
    int restoreTokens,
    int longestStreak,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.ac_unit,
            value: '$freezeDays',
            label: 'Freeze Days',
            iconColor: Colors.blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.replay_circle_filled,
            value: '$restoreTokens',
            label: 'Restore',
            iconColor: Colors.purple,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            value: '$longestStreak',
            label: 'Best',
            iconColor: isDark ? _fireOrange : AppTheme.primaryColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required bool isDark,
  }) {
    return _HoverStatCard(
      icon: icon,
      value: value,
      label: label,
      iconColor: iconColor,
      isDark: isDark,
    );
  }

  Widget _buildActionButtons(
    StreakService streakService,
    int freezeDays,
    bool canRestore,
    bool isDark,
  ) {
    return Row(
      children: [
        if (freezeDays > 0 && !streakService.isFrozenToday)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _freezeToday(streakService),
              icon: const Icon(Icons.ac_unit, size: 18),
              label: const Text('Freeze Today'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (freezeDays > 0 && canRestore) const SizedBox(width: 12),
        if (canRestore)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _restoreStreak(streakService),
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('Restore'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: BorderSide(color: Colors.purple.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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

  bool _wasActiveOnDate(StreakService streakService, DateTime date) {
    // For now, we approximate based on streak count
    // TODO: Implement actual activity lookup from StreakDao
    final lastActive = streakService.streak?.lastActiveDate;
    if (lastActive == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    final streak = streakService.currentStreak;

    // If date is in the future, not active
    if (checkDate.isAfter(today)) return false;

    // Calculate days ago from today
    final daysAgo = today.difference(checkDate).inDays;

    // If within streak range and before or on last active date, consider active
    return daysAgo < streak;
  }

  void _showCheckInInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Complete a task, log a habit, or finish a focus session to check in!',
          style: GoogleFonts.outfit(),
        ),
        backgroundColor: isDark ? _warmBrown : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _freezeToday(StreakService streakService) async {
    final success = await streakService.freezeToday();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Streak frozen for today! ❄️' : 'Could not freeze today',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: success ? Colors.blue : Colors.red,
          behavior: SnackBarBehavior.floating,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Streak restored! 🔥' : 'Could not restore streak',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: success ? Colors.purple : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

/// Custom painter for mandala-style background pattern
class _MandalaPatternPainter extends CustomPainter {
  final bool isDark;
  final double size;

  _MandalaPatternPainter({required this.isDark, this.size = 400});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Define technicolor palette - vibrant and colorful
    final colors = isDark
        ? [
            const Color(0xFFFF3366).withAlpha(180), // Neon coral
            const Color(0xFF00FF88).withAlpha(170), // Electric mint
            const Color(0xFFFF6B00).withAlpha(160), // Vivid orange
            const Color(0xFF00BFFF).withAlpha(150), // Electric blue
            const Color(0xFFFF00FF).withAlpha(145), // Magenta
            const Color(0xFFFFD700).withAlpha(140), // Bright gold
            const Color(0xFF7B68EE).withAlpha(135), // Aurora purple
            const Color(0xFF00FFCC).withAlpha(130), // Tropical teal
            const Color(0xFFFF1493).withAlpha(125), // Deep pink
          ]
        : [
            const Color(0xFF00D084).withAlpha(180), // Emerald green
            const Color(0xFF6366F1).withAlpha(170), // Vivid indigo
            const Color(0xFFFF6B6B).withAlpha(160), // Coral red
            const Color(0xFF00CED1).withAlpha(150), // Turquoise
            const Color(0xFFDA70D6).withAlpha(145), // Orchid
            const Color(0xFFFFA500).withAlpha(140), // Tangerine
            const Color(0xFF9370DB).withAlpha(135), // Medium purple
            const Color(0xFF20B2AA).withAlpha(130), // Light sea green
            const Color(0xFFFF69B4).withAlpha(125), // Hot pink
          ];

    // Scale mandala to fit the container
    final maxRadius = (canvasSize.width.clamp(0.0, size) * 0.45).toDouble();
    final numRings = 4;

    // Draw concentric circles
    for (int ring = 0; ring < numRings; ring++) {
      final radius = maxRadius * (1 - ring / (numRings + 1));
      final paint = Paint()
        ..color = colors[ring % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw realistic leaf/petal shapes radiating from center
    final numPetals = 8;
    for (int i = 0; i < numPetals; i++) {
      final angle = (i / numPetals) * 2 * math.pi;
      final petalLength = maxRadius * 0.75;

      // Create more realistic leaf path with symmetric curves
      final path = Path();

      // Start at center
      final startX = center.dx;
      final startY = center.dy;

      // Leaf tip
      final tipX = center.dx + petalLength * cos(angle);
      final tipY = center.dy + petalLength * sin(angle);

      // Create symmetric leaf sides with proper curvature
      final leafWidth = petalLength * 0.4;

      // Perpendicular angles for leaf width
      final perpAngle1 = angle - math.pi / 2;
      final perpAngle2 = angle + math.pi / 2;

      // Control points for left side of leaf (cubic bezier for smooth curves)
      final ctrl1Distance = petalLength * 0.35;
      final ctrl1X =
          center.dx +
          ctrl1Distance * cos(angle) +
          leafWidth * 0.6 * cos(perpAngle1);
      final ctrl1Y =
          center.dy +
          ctrl1Distance * sin(angle) +
          leafWidth * 0.6 * sin(perpAngle1);

      final ctrl2Distance = petalLength * 0.75;
      final ctrl2X =
          center.dx +
          ctrl2Distance * cos(angle) +
          leafWidth * 0.25 * cos(perpAngle1);
      final ctrl2Y =
          center.dy +
          ctrl2Distance * sin(angle) +
          leafWidth * 0.25 * sin(perpAngle1);

      // Control points for right side of leaf
      final ctrl3X =
          center.dx +
          ctrl2Distance * cos(angle) +
          leafWidth * 0.25 * cos(perpAngle2);
      final ctrl3Y =
          center.dy +
          ctrl2Distance * sin(angle) +
          leafWidth * 0.25 * sin(perpAngle2);

      final ctrl4X =
          center.dx +
          ctrl1Distance * cos(angle) +
          leafWidth * 0.6 * cos(perpAngle2);
      final ctrl4Y =
          center.dy +
          ctrl1Distance * sin(angle) +
          leafWidth * 0.6 * sin(perpAngle2);

      // Draw left side of leaf (from base to tip)
      path.moveTo(startX, startY);
      path.cubicTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, tipX, tipY);

      // Draw right side of leaf (from tip back to base)
      path.cubicTo(ctrl3X, ctrl3Y, ctrl4X, ctrl4Y, startX, startY);
      path.close();

      // Fill the leaf with gradient-like effect
      final petalPaint = Paint()
        ..color = colors[(i * 2) % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, petalPaint);

      // Draw leaf outline for definition
      final outlinePaint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(path, outlinePaint);

      // Draw center vein line for realism
      final veinPaint = Paint()
        ..color = colors[(i + 1) % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawLine(Offset(startX, startY), Offset(tipX, tipY), veinPaint);
    }

    // Draw small decorative dots at petal tips
    for (int i = 0; i < numPetals; i++) {
      final angle = (i / numPetals) * 2 * math.pi;
      final dotRadius = maxRadius * 0.7;
      final dotX = center.dx + dotRadius * cos(angle);
      final dotY = center.dy + dotRadius * sin(angle);

      final dotPaint = Paint()
        ..color = colors[(i + 3) % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 3.0, dotPaint);
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = colors[0]
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.15, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians);

/// Interactive stat card with hover animation
class _HoverStatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final bool isDark;

  const _HoverStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.isDark,
  });

  @override
  State<_HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<_HoverStatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: _isHovering
                    ? (widget.isDark
                          ? Colors.white.withAlpha(25)
                          : Colors.white.withAlpha(230))
                    : (widget.isDark
                          ? Colors.white.withAlpha(13)
                          : Colors.white.withAlpha(179)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovering
                      ? widget.iconColor.withAlpha(100)
                      : (widget.isDark
                            ? Colors.white.withAlpha(26)
                            : AppTheme.primaryColor.withAlpha(26)),
                  width: _isHovering ? 1.5 : 1.0,
                ),
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: widget.iconColor.withAlpha(60),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: _isHovering ? 28 : 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.value,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? Colors.white60
                          : AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
