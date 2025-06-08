import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// A class to manage multiple cameras
class CameraManager {
  /// List of available cameras
  final List<CameraDescription> cameras;

  /// The currently active camera controller
  CameraController? _controller;

  /// Selected camera index
  int _selectedIndex = 0;

  /// Flag to indicate if the camera is initialized
  bool _isInitialized = false;

  /// Error message if initialization fails
  String? _error;

  CameraManager(this.cameras);

  /// Get the initialization status
  bool get isInitialized => _isInitialized;

  /// Get any error that occurred
  String? get error => _error;

  /// Get the current camera controller
  CameraController? get controller => _controller;

  /// Get the index of the selected camera
  int get selectedIndex => _selectedIndex;

  /// Initialize the selected camera
  Future<void> initialize(int cameraIndex) async {
    _isInitialized = false;
    _error = null;

    if (cameras.isEmpty) {
      _error = "No cameras available";
      return;
    }

    // Validate index
    final index =
        cameraIndex >= 0 && cameraIndex < cameras.length ? cameraIndex : 0;
    _selectedIndex = index;

    try {
      // Dispose of existing controller if needed
      await _controller?.dispose();

      // Create new controller with optimized mobile settings
      _controller = CameraController(
        cameras[index],
        // Use high resolution for back cameras and medium for front/others
        cameras[index].lensDirection == CameraLensDirection.back
            ? ResolutionPreset.high
            : ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg, // More efficient for mobile
      );

      // Initialize with improved error handling
      try {
        if (kIsWeb) {
          // For web, use a simpler initialization process
          await _controller!.initialize();
        } else {
          // For mobile, use timeout for better error handling
          await _controller!.initialize().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              // Instead of throwing, handle timeout gracefully
              _error = 'Camera initialization timed out';
              return;
            },
          );

          // Only set these if successfully initialized
          if (_controller != null && _controller!.value.isInitialized) {
            // Set flash mode to auto for better mobile experience
            if (cameras[index].lensDirection == CameraLensDirection.back) {
              try {
                await _controller!.setFlashMode(FlashMode.auto);
              } catch (_) {
                // Ignore if flash mode setting fails
              }
            }

            // Set focus mode for better mobile photos
            try {
              await _controller!.setFocusMode(FocusMode.auto);
            } catch (_) {
              // Ignore if focus mode setting fails
            }
          }
        }

        _isInitialized = true;
      } catch (e) {
        _error = "Camera initialization error: $e";
        if (kDebugMode) {
          print('Error during camera initialization: $e');
        }
      }
    } catch (e) {
      _error = "Camera error: $e";
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
    }
  }

  /// Get a descriptive name for the camera
  String getCameraName(int index) {
    if (index >= cameras.length) return "Unknown Camera";

    final camera = cameras[index];
    String name = 'Camera ${index + 1}';

    if (camera.lensDirection == CameraLensDirection.front) {
      name += ' (Front)';
    } else if (camera.lensDirection == CameraLensDirection.back) {
      name += ' (Back)';
    } else if (camera.lensDirection == CameraLensDirection.external) {
      name += ' (External)';
    }

    return name;
  }

  /// Check if cameras are available
  bool get hasCameras => cameras.isNotEmpty;

  /// Get the number of available cameras
  int get cameraCount => cameras.length;

  /// Dispose of the camera controller
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
