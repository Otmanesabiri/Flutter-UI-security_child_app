import 'package:flutter/material.dart';

class DetectionBox {
  final String label;
  final double confidence;
  final Rect rect;
  final bool isDangerous;

  DetectionBox({
    required this.label,
    required this.confidence,
    required this.rect,
    this.isDangerous = false,
  });
}

class DetectionBoxOverlay extends StatelessWidget {
  final List<DetectionBox> detections;
  final Size previewSize;

  const DetectionBoxOverlay({
    Key? key,
    required this.detections,
    required this.previewSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: previewSize,
      painter: DetectionBoxPainter(
        detections: detections,
        previewSize: previewSize,
      ),
    );
  }
}

class DetectionBoxPainter extends CustomPainter {
  final List<DetectionBox> detections;
  final Size previewSize;

  DetectionBoxPainter({
    required this.detections,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var detection in detections) {
      final boxPaint = Paint()
        ..color = detection.isDangerous ? Colors.red : Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final labelBackground = Paint()
        ..color = detection.isDangerous ? Colors.red : Colors.green
        ..style = PaintingStyle.fill;

      // Draw the box
      canvas.drawRect(detection.rect, boxPaint);

      // Draw label background
      final labelRect = Rect.fromLTWH(
        detection.rect.left,
        detection.rect.top - 20,
        130,
        20,
      );
      canvas.drawRect(labelRect, labelBackground);

      // Draw the label text
      final textSpan = TextSpan(
        text: "${detection.label} ${(detection.confidence * 100).toInt()}%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(detection.rect.left + 5, detection.rect.top - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
