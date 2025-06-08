import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as camera_lib;
import '../core/camera_manager.dart';

class CameraSettingsDialog extends StatefulWidget {
  final CameraManager cameraManager;

  const CameraSettingsDialog({
    Key? key,
    required this.cameraManager,
  }) : super(key: key);

  @override
  State<CameraSettingsDialog> createState() => _CameraSettingsDialogState();
}

class _CameraSettingsDialogState extends State<CameraSettingsDialog> {
  camera_lib.ResolutionPreset _currentResolution = camera_lib.ResolutionPreset.medium;
  String? _currentResolutionString;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _updateCurrentResolution();
  }

  Future<void> _updateCurrentResolution() async {
    setState(() {
      _currentResolutionString =
          widget.cameraManager.getCameraResolution() ?? 'Unknown';
    });
  }

  Future<void> _changeResolution(camera_lib.ResolutionPreset newResolution) async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    final result =
        await widget.cameraManager.setCameraResolution(newResolution);
    if (result) {
      _currentResolution = newResolution;
      await _updateCurrentResolution();
    }

    setState(() {
      _isBusy = false;
    });
  }

  Future<void> _switchCamera() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    await widget.cameraManager.switchCamera();
    await _updateCurrentResolution();

    setState(() {
      _isBusy = false;
    });
  }

  Future<void> _takeScreenshot() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    final path =
        await widget.cameraManager.takeScreenshot(outputDir: 'screenshots');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(path != null
                ? 'Screenshot saved to: $path'
                : 'Failed to take screenshot')),
      );
    }

    setState(() {
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Camera Settings'),
      content: _isBusy
          ? const Center(
              heightFactor: 1,
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current resolution: $_currentResolutionString'),
                  const SizedBox(height: 16),
                  const Text('Change resolution:'),
                  ListTile(
                    title: const Text('Low'),
                    leading: Radio<camera_lib.ResolutionPreset>(
                      value: camera_lib.ResolutionPreset.low,
                      groupValue: _currentResolution,
                      onChanged: (value) => _changeResolution(value!),
                    ),
                  ),
                  ListTile(
                    title: const Text('Medium'),
                    leading: Radio<camera_lib.ResolutionPreset>(
                      value: camera_lib.ResolutionPreset.medium,
                      groupValue: _currentResolution,
                      onChanged: (value) => _changeResolution(value!),
                    ),
                  ),
                  ListTile(
                    title: const Text('High'),
                    leading: Radio<camera_lib.ResolutionPreset>(
                      value: camera_lib.ResolutionPreset.high,
                      groupValue: _currentResolution,
                      onChanged: (value) => _changeResolution(value!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _switchCamera,
                      icon: const Icon(Icons.switch_camera),
                      label: const Text('Switch Camera'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _takeScreenshot,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Take Screenshot'),
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
