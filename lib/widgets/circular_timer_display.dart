import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'animated_timer_text.dart';

class CircularTimerDisplay extends StatefulWidget {
  final String timeText;
  final double progress;
  final bool isRunning;
  final Color primaryColor;
  final Color backgroundColor;
  final double size;

  const CircularTimerDisplay({
    Key? key,
    required this.timeText,
    required this.progress,
    required this.isRunning,
    required this.primaryColor,
    required this.backgroundColor,
    this.size = 280,
  }) : super(key: key);

  @override
  State<CircularTimerDisplay> createState() => _CircularTimerDisplayState();
}

class _CircularTimerDisplayState extends State<CircularTimerDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _expandController;
  late AnimationController _initialDecreaseController;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for glow effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Wave animation - continuous flowing motion
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    // Initial decrease animation - fast shrink from full to start
    _initialDecreaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      value: 1.0, // Start complete
    );
    
    // Expand animation - smooth fill from start to current progress
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
      value: 1.0, // Start fully visible when idle
    );
    
    if (widget.isRunning) {
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
      // Only animate from 0 when starting fresh
      if (widget.progress > 0.95) {
        // First: fast decrease from full circle to start point
        _initialDecreaseController.reverse(from: 1.0).then((_) {
          // Second: smooth expand to current progress
          _expandController.forward(from: 0.0);
        });
      }
    }
  }
  
  @override
  void didUpdateWidget(CircularTimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Control animations based on running state
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _waveController.repeat();
        _pulseController.repeat(reverse: true);
        // Animate expansion only when starting from near-full progress
        if (!oldWidget.isRunning && widget.progress > 0.95) {
          // First: fast decrease, then expand
          _initialDecreaseController.reverse(from: 1.0).then((_) {
            _expandController.forward(from: 0.0);
          });
        }
      } else {
        _waveController.stop();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _expandController.dispose();
    _initialDecreaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wavy progress ring with smooth animation
          AnimatedBuilder(
            animation: Listenable.merge([_waveController, _expandController, _initialDecreaseController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: WavyCircularProgressPainter(
                  progress: widget.progress,
                  expandProgress: _expandController.value,
                  initialDecreaseProgress: _initialDecreaseController.value,
                  color: widget.primaryColor,
                  backgroundColor: widget.backgroundColor,
                  strokeWidth: 12,
                  isRunning: widget.isRunning,
                  isDark: isDark,
                  wavePhase: _waveController.value * 2 * math.pi,
                ),
              );
            },
          ),
          
          // Time text - always centered with animated digits
          AnimatedTimerText(
            timeText: widget.timeText,
            color: widget.primaryColor,
            fontSize: widget.size * 0.2,
            isRunning: widget.isRunning,
          ),
          
          // Pulsing indicator dot below timer - positioned absolutely
          if (widget.isRunning)
            Positioned(
              bottom: widget.size * 0.32, // Position below center with more distance
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.4 + (0.6 * _pulseController.value),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.6),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class WavyCircularProgressPainter extends CustomPainter {
  final double progress;
  final double expandProgress;
  final double initialDecreaseProgress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final bool isRunning;
  final bool isDark;
  final double wavePhase;

  WavyCircularProgressPainter({
    required this.progress,
    required this.expandProgress,
    required this.initialDecreaseProgress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 12,
    this.isRunning = false,
    this.isDark = false,
    this.wavePhase = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth - 10;
    
    // When not running or at full progress, show complete circle
    if (!isRunning && progress >= 0.99) {
      // Draw complete full wavy ring
      _drawWavyRing(
        canvas,
        center,
        radius,
        -math.pi / 2,
        2 * math.pi, // Full circle
        color,
        strokeWidth,
        true,
        useGradient: false,
      );
      
      return;
    }
    
    // During initial decrease animation (fast shrink from full to start)
    if (initialDecreaseProgress > 0 && initialDecreaseProgress < 1.0) {
      final decreaseDisplayProgress = initialDecreaseProgress;
      
      // Draw background wavy ring (low opacity) to show the complete path
      _drawWavyRing(
        canvas,
        center,
        radius,
        -math.pi / 2,
        2 * math.pi,
        color.withOpacity(isDark ? 0.08 : 0.12),
        strokeWidth,
        true,
        useGradient: false,
      );
      
      _drawWavyRing(
        canvas,
        center,
        radius,
        -math.pi / 2,
        2 * math.pi * decreaseDisplayProgress * 0.95,
        color,
        strokeWidth,
        true,
        useGradient: true,
      );
      
      // Draw endpoint dot during decrease
      _drawEndpointDot(canvas, center, radius, decreaseDisplayProgress * 0.95);
      return;
    }
    
    // Calculate display progress with smooth expansion animation
    // When expanding from start (expandProgress < 1), grow from 0 to current progress
    // This creates a fill-up effect from the start point
    final displayProgress = expandProgress < 1.0
        ? progress * expandProgress
        : progress;
    
    if (displayProgress > 0) {
      // Draw background wavy ring (low opacity) to show the complete path
      _drawWavyRing(
        canvas,
        center,
        radius,
        -math.pi / 2,
        2 * math.pi,
        color.withOpacity(isDark ? 0.08 : 0.12),
        strokeWidth,
        true,
        useGradient: false,
      );
      
      // Outer glow layer for running state - cut to match main ring
      if (isRunning) {
        _drawWavyRing(
          canvas,
          center,
          radius,
          -math.pi / 2,
          2 * math.pi * displayProgress * 0.95, // Cut to match main ring
          color.withOpacity(0.25),
          strokeWidth + 10,
          true,
          blur: 12,
        );
      }
      
      // Main wavy progress ring with gradient
      _drawWavyRing(
        canvas,
        center,
        radius,
        -math.pi / 2,
        2 * math.pi * displayProgress,
        color,
        strokeWidth,
        true,
        useGradient: true,
      );
      
      // Draw endpoint dot
      _drawEndpointDot(canvas, center, radius, displayProgress);
    }
  }

  void _drawEndpointDot(Canvas canvas, Offset center, double radius, double displayProgress) {
    // Calculate endpoint position - match the actual end of the wavy path
    final actualEndAngle = -math.pi / 2 + (2 * math.pi * displayProgress * 0.95);
    
    // Calculate wave offset at endpoint to align dot perfectly with wavy edge
    final waveFreq = 12;
    final waveAmplitude = strokeWidth * 0.3;
    final waveOffset = math.sin(actualEndAngle * waveFreq + wavePhase) * waveAmplitude;
    final adjustedRadius = radius + waveOffset;
    
    final endX = center.dx + adjustedRadius * math.cos(actualEndAngle);
    final endY = center.dy + adjustedRadius * math.sin(actualEndAngle);
    
    // Endpoint dot color - slightly darker/lighter than main color for contrast
    final dotColor = isDark 
        ? Color.lerp(color, Colors.white, 0.2)! 
        : Color.lerp(color, Colors.black, 0.15)!;
    
    // Outer glow for endpoint
    final glowPaint = Paint()
      ..color = dotColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(endX, endY), strokeWidth * 0.7, glowPaint);
    
    // Solid endpoint dot - bigger and more visible
    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(Offset(endX, endY), strokeWidth * 0.55, dotPaint);
  }

  void _drawWavyRing(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color baseColor,
    double width,
    bool isProgress, {
    bool useGradient = false,
    double blur = 0,
  }) {
    final path = Path();
    final waveCount = 12; // Number of waves around the circle
    final waveAmplitude = width * 0.3; // Height of waves
    // Cut the path earlier for main progress ring to avoid stuttering endpoint
    final adjustedSweep = useGradient ? sweepAngle * 0.95 : sweepAngle;
    final angleStep = adjustedSweep / (waveCount * 10);
    
    bool isFirst = true;
    
    for (double angle = 0; angle <= adjustedSweep; angle += angleStep) {
      final currentAngle = startAngle + angle;
      
      // Calculate wave offset - wave animation phase is based on absolute angle
      // so waves stay in place while animating in/out
      final waveFreq = waveCount;
      final waveOffset = isProgress 
          ? math.sin(currentAngle * waveFreq + wavePhase) * waveAmplitude
          : math.sin(currentAngle * waveFreq) * waveAmplitude * 0.5;
      
      final adjustedRadius = radius + waveOffset;
      final x = center.dx + adjustedRadius * math.cos(currentAngle);
      final y = center.dy + adjustedRadius * math.sin(currentAngle);
      
      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Create paint with optional gradient
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    if (blur > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    }
    
    if (useGradient && isProgress) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      paint.shader = SweepGradient(
        colors: [
          baseColor,
          baseColor.withOpacity(0.85),
          baseColor.withOpacity(0.95),
          baseColor,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(rect);
    } else {
      paint.color = baseColor;
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavyCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.expandProgress != expandProgress ||
        oldDelegate.initialDecreaseProgress != initialDecreaseProgress ||
        oldDelegate.color != color ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.wavePhase != wavePhase;
  }
}
