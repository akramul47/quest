import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiParticle {
  late double x;
  late double y;
  late double velocityX;
  late double velocityY;
  late double rotation;
  late double rotationSpeed;
  late Color color;
  late double size;
  late double opacity;

  ConfettiParticle({
    required double startX,
    required double startY,
    required math.Random random,
  }) {
    x = startX;
    y = startY;
    velocityX = (random.nextDouble() - 0.5) * 6;
    velocityY = -random.nextDouble() * 8 - 4;
    rotation = random.nextDouble() * math.pi * 2;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.3;
    
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 8 + 4;
    opacity = 1.0;
  }

  void update(double gravity) {
    velocityY += gravity;
    x += velocityX;
    y += velocityY;
    rotation += rotationSpeed;
    opacity -= 0.008;
  }
}

class ConfettiOverlay extends StatefulWidget {
  final bool show;
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    Key? key,
    required this.show,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        if (mounted) {
          setState(() {
            for (var particle in _particles) {
              particle.update(0.25);
            }
          });
        }
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _initializeParticles();
      _controller.forward(from: 0);
    }
  }

  void _initializeParticles() {
    _particles.clear();
    final size = MediaQuery.of(context).size;
    
    // Create confetti bursts from multiple points
    for (int i = 0; i < 5; i++) {
      final startX = size.width * (0.2 + i * 0.15);
      final startY = size.height * 0.3;
      
      for (int j = 0; j < 15; j++) {
        _particles.add(ConfettiParticle(
          startX: startX,
          startY: startY,
          random: _random,
        ));
      }
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show || !_initialized) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: ConfettiPainter(particles: _particles),
        size: Size.infinite,
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.opacity > 0) {
        canvas.save();
        canvas.translate(particle.x, particle.y);
        canvas.rotate(particle.rotation);

        final paint = Paint()
          ..color = particle.color.withOpacity(particle.opacity)
          ..style = PaintingStyle.fill;

        // Draw different shapes
        final random = math.Random(particle.hashCode);
        final shape = random.nextInt(3);
        
        switch (shape) {
          case 0: // Rectangle
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size,
                height: particle.size / 2,
              ),
              paint,
            );
            break;
          case 1: // Circle
            canvas.drawCircle(Offset.zero, particle.size / 2, paint);
            break;
          case 2: // Triangle
            final path = Path()
              ..moveTo(0, -particle.size / 2)
              ..lineTo(particle.size / 2, particle.size / 2)
              ..lineTo(-particle.size / 2, particle.size / 2)
              ..close();
            canvas.drawPath(path, paint);
            break;
        }

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
