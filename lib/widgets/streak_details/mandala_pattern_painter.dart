import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom painter for mandala-style background pattern
class MandalaPatternPainter extends CustomPainter {
  final bool isDark;
  final double size;

  MandalaPatternPainter({required this.isDark, this.size = 400});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);

    // Define technicolor palette - vibrant and colorful
    final colors = isDark
        ? [
            const Color(0xFFE57373).withAlpha(120), // Muted coral
            const Color(0xFF4DB6AC).withAlpha(115), // Muted teal
            const Color(0xFFFFB74D).withAlpha(110), // Muted orange
            const Color(0xFF64B5F6).withAlpha(105), // Muted blue
            const Color(0xFFBA68C8).withAlpha(100), // Muted orchid
            const Color(0xFFFFD54F).withAlpha(95), // Muted gold
            const Color(0xFF9575CD).withAlpha(90), // Muted purple
            const Color(0xFF4DD0E1).withAlpha(85), // Muted cyan
            const Color(0xFFF06292).withAlpha(80), // Muted pink
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
      final tipX = center.dx + petalLength * math.cos(angle);
      final tipY = center.dy + petalLength * math.sin(angle);

      // Create symmetric leaf sides with proper curvature
      final leafWidth = petalLength * 0.4;

      // Perpendicular angles for leaf width
      final perpAngle1 = angle - math.pi / 2;
      final perpAngle2 = angle + math.pi / 2;

      // Control points for left side of leaf (cubic bezier for smooth curves)
      final ctrl1Distance = petalLength * 0.35;
      final ctrl1X =
          center.dx +
          ctrl1Distance * math.cos(angle) +
          leafWidth * 0.6 * math.cos(perpAngle1);
      final ctrl1Y =
          center.dy +
          ctrl1Distance * math.sin(angle) +
          leafWidth * 0.6 * math.sin(perpAngle1);

      final ctrl2Distance = petalLength * 0.75;
      final ctrl2X =
          center.dx +
          ctrl2Distance * math.cos(angle) +
          leafWidth * 0.25 * math.cos(perpAngle1);
      final ctrl2Y =
          center.dy +
          ctrl2Distance * math.sin(angle) +
          leafWidth * 0.25 * math.sin(perpAngle1);

      // Control points for right side of leaf
      final ctrl3X =
          center.dx +
          ctrl2Distance * math.cos(angle) +
          leafWidth * 0.25 * math.cos(perpAngle2);
      final ctrl3Y =
          center.dy +
          ctrl2Distance * math.sin(angle) +
          leafWidth * 0.25 * math.sin(perpAngle2);

      final ctrl4X =
          center.dx +
          ctrl1Distance * math.cos(angle) +
          leafWidth * 0.6 * math.cos(perpAngle2);
      final ctrl4Y =
          center.dy +
          ctrl1Distance * math.sin(angle) +
          leafWidth * 0.6 * math.sin(perpAngle2);

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
      final dotX = center.dx + dotRadius * math.cos(angle);
      final dotY = center.dy + dotRadius * math.sin(angle);

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
