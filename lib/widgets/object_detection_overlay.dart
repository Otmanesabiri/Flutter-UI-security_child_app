import 'package:flutter/material.dart';

class DetectedObject {
  final String label;
  final double confidence;
  final Rect boundingBox;
  final bool isDangerous;

  DetectedObject({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.isDangerous = false,
  });
}

class ObjectDetectionOverlay extends StatelessWidget {
  final List<DetectedObject> detectedObjects;
  final Size previewSize;

  const ObjectDetectionOverlay({
    Key? key,
    required this.detectedObjects,
    required this.previewSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // This transparent container ensures the overlay covers the entire camera preview
        Container(color: Colors.transparent),

        // Custom painter for drawing bounding boxes and labels
        CustomPaint(
          size: previewSize,
          painter: DetectionBoxPainter(
            detectedObjects: detectedObjects,
            previewSize: previewSize,
          ),
        ),

        // Status overlay at the bottom
        if (detectedObjects.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected: ${detectedObjects.length} object(s)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (detectedObjects.any((obj) => obj.isDangerous))
                    const Text(
                      '⚠️ Dangerous objects detected!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DetectionBoxPainter extends CustomPainter {
  final List<DetectedObject> detectedObjects;
  final Size previewSize;

  DetectionBoxPainter({
    required this.detectedObjects,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final object in detectedObjects) {
      // Scale bounding box to match the preview size
      final scaleX = size.width / previewSize.width;
      final scaleY = size.height / previewSize.height;

      final scaledRect = Rect.fromLTRB(
        object.boundingBox.left * scaleX,
        object.boundingBox.top * scaleY,
        object.boundingBox.right * scaleX,
        object.boundingBox.bottom * scaleY,
      );

      // Draw bounding box
      final boxPaint = Paint()
        ..color = object.isDangerous ? Colors.red : Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRect(scaledRect, boxPaint);

      // Draw background for label
      final labelBgPaint = Paint()
        ..color = object.isDangerous
            ? Colors.red.withOpacity(0.7)
            : Colors.green.withOpacity(0.7);

      final labelBgRect = Rect.fromLTWH(
        scaledRect.left,
        scaledRect.top - 24,
        scaledRect.width,
        24,
      );

      canvas.drawRect(labelBgRect, labelBgPaint);

      // Draw text for object label and confidence
      final confidencePercentage = (object.confidence * 100).toInt();
      final textSpan = TextSpan(
        text: '${object.label} - $confidencePercentage%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(scaledRect.left + 4, scaledRect.top - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint on new frame
  }
}
