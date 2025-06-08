import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../utils/error_handler.dart';

/// A widget that safely displays a camera preview with proper error handling
class SafeCameraPreview extends StatelessWidget {
  /// The camera controller
  final CameraController? controller;

  /// Error message if camera fails
  final String? errorMessage;

  /// Whether camera is initialized
  final bool isInitialized;

  /// Callback to retry camera initialization on failure
  final VoidCallback onRetry;

  /// Border color for the preview
  final Color borderColor;

  /// Border width
  final double borderWidth;

  /// Border radius
  final double borderRadius;

  /// Creates a safe camera preview widget
  const SafeCameraPreview({
    super.key,
    required this.controller,
    this.errorMessage,
    required this.isInitialized,
    required this.onRetry,
    this.borderColor = Colors.blue,
    this.borderWidth = 3.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorHandler.buildSafeWidget(
      builder: () {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildPreviewContent(),
        );
      },
      fallback: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: borderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text("Camera preview error", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (errorMessage != null) {
      // Show error message if camera failed
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry Camera"),
            ),
          ],
        ),
      );
    } else if (!isInitialized || controller == null) {
      // Show loading indicator while initializing
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Initializing camera..."),
          ],
        ),
      );
    } else {
      // Show camera preview when ready
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: CameraPreview(controller!),
      );
    }
  }
}
