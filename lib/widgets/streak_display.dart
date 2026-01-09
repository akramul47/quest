import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../services/streak_service.dart';
import '../screens/streak_details_screen.dart';

class StreakDisplayWidget extends StatefulWidget {
  final bool compact;

  const StreakDisplayWidget({super.key, this.compact = false});

  @override
  State<StreakDisplayWidget> createState() => _StreakDisplayWidgetState();
}

class _StreakDisplayWidgetState extends State<StreakDisplayWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakService>(
      builder: (context, streakService, child) {
        final streak = streakService.currentStreak;
        final isFrozen = streakService.isFrozenToday;
        final freezeDays = streakService.freezeDaysAvailable;
        final restoreTokens = streakService.restoreTokens;

        if (widget.compact) {
          return _buildCompact(context, streak, isFrozen);
        }

        return _buildFullDisplay(
          context,
          streak,
          isFrozen,
          freezeDays,
          restoreTokens,
        );
      },
    );
  }

  Widget _buildFullDisplay(
    BuildContext context,
    int streak,
    bool isFrozen,
    int freezeDays,
    int restoreTokens,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => _navigateToDetails(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withAlpha(128),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withAlpha(26),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStreakCounter(context, streak, isFrozen),
              if (freezeDays > 0 || restoreTokens > 0) ...[
                const SizedBox(width: 16),
                Container(
                  height: 24,
                  width: 1,
                  color: Theme.of(context).colorScheme.outline.withAlpha(51),
                ),
                const SizedBox(width: 16),
                if (freezeDays > 0) _buildFreezeStatus(context, freezeDays),
                if (freezeDays > 0 && restoreTokens > 0)
                  const SizedBox(width: 12),
                if (restoreTokens > 0)
                  _buildTokenStatus(context, restoreTokens),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, int streak, bool isFrozen) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Color scheme based on frozen state
    final Color primaryColor;
    final Color accentColor;

    if (isFrozen) {
      primaryColor = const Color(0xFF58A6FF); // Bright blue for frozen
      accentColor = const Color(0xFF1F6FEB); // Darker blue
    } else {
      primaryColor = const Color(0xFFFF9500); // Vibrant orange for fire
      accentColor = const Color(0xFFFF6B00); // Darker orange
    }

    // Dynamic font size based on number of digits
    final streakString = '$streak';
    final digitCount = streakString.length;
    final double fontSize;
    final double letterSpacing;

    if (digitCount <= 2) {
      fontSize = 16;
      letterSpacing = -0.5;
    } else if (digitCount == 3) {
      fontSize = 14;
      letterSpacing = -0.3;
    } else {
      // 4+ digits
      fontSize = 12;
      letterSpacing = -0.2;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => _navigateToDetails(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(
            minHeight: 36,
            maxHeight: 36,
            minWidth: 60, // Minimum width for small numbers
            maxWidth: 120, // Maximum width to prevent excessive stretching
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: _isHovering
                ? Border.all(
                    color: primaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.06),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon with gradient background
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withValues(alpha: 0.4),
                      accentColor.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                child: Center(child: _buildIcon(isFrozen, 18)),
              ),
              const SizedBox(width: 6),
              // Streak number with gradient text effect
              Flexible(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryColor, accentColor],
                  ).createShader(bounds),
                  child: Text(
                    streakString,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                      height: 1.0,
                      letterSpacing: letterSpacing,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCounter(BuildContext context, int streak, bool isFrozen) {
    const double iconSize = 48;
    const double fontSize = 36;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fire icon positioned at the top
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: _buildIcon(isFrozen, iconSize),
            ),
            const SizedBox(width: 6),
            // Streak number positioned lower with top padding
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                '$streak',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Label positioned below the icon-number row
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            isFrozen ? 'Streak Frozen' : 'Day Streak',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(bool isFrozen, double size) {
    if (isFrozen) {
      return Icon(Icons.ac_unit, color: Colors.blue, size: size);
    }
    return _StreakIcon(size: size, isHovering: _isHovering);
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const StreakDetailsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildFreezeStatus(BuildContext context, int count) {
    return Tooltip(
      message: '$count freeze days available',
      child: Row(
        children: [
          Icon(Icons.ac_unit, size: 16, color: Colors.blue.withAlpha(204)),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenStatus(BuildContext context, int count) {
    return Tooltip(
      message: '$count streak restore tokens',
      child: Row(
        children: [
          Icon(
            Icons.replay_circle_filled, // Or another suitable token icon
            size: 16,
            color: Colors.purple.withAlpha(204),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakIcon extends StatefulWidget {
  final double size;
  final bool isHovering;

  const _StreakIcon({required this.size, required this.isHovering});

  @override
  State<_StreakIcon> createState() => _StreakIconState();
}

class _StreakIconState extends State<_StreakIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _loopCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loopCount++;
        // Continue looping if hovering, otherwise stop after 2 loops
        if (widget.isHovering || _loopCount < 2) {
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void didUpdateWidget(_StreakIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovering && !oldWidget.isHovering) {
      // Started hovering - restart animation
      _loopCount = 0;
      if (_controller.duration != null) {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        'assets/animations/streak_fire.json',
        controller: _controller,
        fit: BoxFit.contain,
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: widget.size,
            );
          }
          return child;
        },
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          _controller.forward();
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: widget.size,
          );
        },
      ),
    );
  }
}
