import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../services/streak_service.dart';

class StreakDisplayWidget extends StatelessWidget {
  final bool compact;

  const StreakDisplayWidget({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakService>(
      builder: (context, streakService, child) {
        final streak = streakService.currentStreak;
        final isFrozen = streakService.isFrozenToday;
        final freezeDays = streakService.freezeDaysAvailable;
        final restoreTokens = streakService.restoreTokens;

        if (compact) {
          return _buildCompact(context, streak, isFrozen);
        }

        return Container(
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
        );
      },
    );
  }

  Widget _buildCompact(BuildContext context, int streak, bool isFrozen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(isFrozen, 20),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCounter(BuildContext context, int streak, bool isFrozen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: _buildIcon(isFrozen, 65),
            ),
            const SizedBox(width: 8),
            Container(
              height: 65, // Match icon height
              alignment:
                  Alignment.bottomCenter, // Fine-tune padding from bottom
              child: Text(
                '$streak',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
        Text(
          isFrozen ? 'Streak Frozen' : 'Day Streak',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(bool isFrozen, double size) {
    if (isFrozen) {
      return Icon(Icons.ac_unit, color: Colors.blue, size: size);
    }
    return _StreakIcon(size: size);
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

  const _StreakIcon({required this.size});

  @override
  State<_StreakIcon> createState() => _StreakIconState();
}

class _StreakIconState extends State<_StreakIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _loopCount = 0;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loopCount++;
        // Continue looping if hovering, otherwise stop after 2 loops
        if (_isHovering || _loopCount < 2) {
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
    if (isHovering) {
      // Reset loop count to ensure it plays efficiently on hover
      _loopCount = 0;
      if (!_controller.isAnimating && _controller.duration != null) {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: SizedBox(
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
      ),
    );
  }
}
