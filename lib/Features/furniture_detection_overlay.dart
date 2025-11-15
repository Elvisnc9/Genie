import 'dart:ui';
import 'package:flutter/material.dart';

class FurnitureDetectionOverlay extends StatefulWidget {
  const FurnitureDetectionOverlay({super.key});

  @override
  State<FurnitureDetectionOverlay> createState() =>
      _FurnitureDetectionOverlayState();
}

class _FurnitureDetectionOverlayState
    extends State<FurnitureDetectionOverlay> with SingleTickerProviderStateMixin {

  // Fake detection data for now — until we plug real TFLite
  final List<Map<String, dynamic>> detections = [
    {
      "box": Rect.fromLTWH(80, 200, 220, 260),
      "label": "Chair",
      "score": 0.87,
    },
    {
      "box": Rect.fromLTWH(150, 450, 240, 180),
      "label": "Sofa",
      "score": 0.93,
    }
  ];

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        return Stack(
          children: detections.map((det) {
            final rect = det["box"] as Rect;

            double glow = 4 + 6 * glowController.value;

            return Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: CustomPaint(
                painter: NeonBoxPainter(
                  glow: glow,
                  label: det["label"],
                  score: det["score"],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// 🔥 Custom painter for the neon glowing rounded boxes
class NeonBoxPainter extends CustomPainter {
  final double glow;
  final String label;
  final double score;

  NeonBoxPainter({
    required this.glow,
    required this.label,
    required this.score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Glow Layer
    final glowPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = glow
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);

    // Main border
    final borderPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw layers
    canvas.drawRRect(rRect, glowPaint);
    canvas.drawRRect(rRect, borderPaint);

    // Label background
    final labelRect = Rect.fromLTWH(0, -28, size.width * 0.6, 24);
    final labelBg = RRect.fromRectAndRadius(labelRect, const Radius.circular(8));

    final bgPaint = Paint()..color = Colors.black.withOpacity(0.6);
    canvas.drawRRect(labelBg, bgPaint);

    // Label text
    final textPainter = TextPainter(
      text: TextSpan(
        text: "$label ${(score * 100).toStringAsFixed(0)}%",
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(6, -26));
  }

  @override
  bool shouldRepaint(NeonBoxPainter oldDelegate) => true;
}
