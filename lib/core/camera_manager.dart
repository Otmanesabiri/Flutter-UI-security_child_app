import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart' as camera_lib;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraManager {
  camera_lib.CameraController? _cameraController;
  List<camera_lib.CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialized = false;
  
  // Remote camera properties
  bool _isRemoteCamera = false;
  String? _remoteCameraUrl;
  String? _remoteUsername;
  String? _remotePassword;
  Timer? _remoteTimer;
  int _refreshRateMs = 500;
  
  // Streams
  final StreamController<Uint8List> _remoteFrameController = StreamController<Uint8List>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRemoteCamera => _isRemoteCamera;
  String? get remoteCameraUrl => _remoteCameraUrl;
  camera_lib.CameraController? get cameraController => _cameraController;
  List<camera_lib.CameraDescription> get availableCameras => _availableCameras;
  int get currentCameraIndex => _currentCameraIndex;
  
  Stream<Uint8List> get remoteFrameStream => _remoteFrameController.stream;
  Stream<String> get errorStream => _errorController.stream;
  
  // Initialize local cameras
  Future<bool> initializeCamera({List<camera_lib.CameraDescription>? cameras}) async {
    try {
      if (cameras != null) {
        _availableCameras = cameras;
      } else {
        _availableCameras = await camera_lib.availableCameras();
      }
      
      if (_availableCameras.isEmpty) {
        _errorController.add('No cameras available');
        return false;
      }
      
      return await _initializeCameraController();
    } catch (e) {
      _errorController.add('Failed to initialize camera: $e');
      return false;
    }
  }
  
  Future<bool> _initializeCameraController() async {
    try {
      if (_currentCameraIndex >= _availableCameras.length) {
        _currentCameraIndex = 0;
      }
      
      _cameraController = camera_lib.CameraController(
        _availableCameras[_currentCameraIndex],
        camera_lib.ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      _isInitialized = true;
      _isRemoteCamera = false;
      
      return true;
    } catch (e) {
      _errorController.add('Failed to initialize camera controller: $e');
      return false;
    }
  }
  
  // Switch between available cameras
  Future<bool> switchCamera() async {
    if (_availableCameras.length <= 1) {
      _errorController.add('No other cameras available');
      return false;
    }
    
    try {
      await _cameraController?.dispose();
      _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
      return await _initializeCameraController();
    } catch (e) {
      _errorController.add('Failed to switch camera: $e');
      return false;
    }
  }
  
  // Set camera resolution
  Future<bool> setCameraResolution(camera_lib.ResolutionPreset resolution) async {
    if (_isRemoteCamera) {
      _errorController.add('Cannot change resolution for remote camera');
      return false;
    }
    
    try {
      await _cameraController?.dispose();
      
      _cameraController = camera_lib.CameraController(
        _availableCameras[_currentCameraIndex],
        resolution,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      return true;
    } catch (e) {
      _errorController.add('Failed to set camera resolution: $e');
      return false;
    }
  }
  
  // Get current camera resolution as string
  String? getCameraResolution() {
    if (_isRemoteCamera) {
      return 'Remote Camera';
    }
    
    if (_cameraController?.value.isInitialized == true) {
      final size = _cameraController!.value.previewSize;
      return '${size?.width.toInt()} x ${size?.height.toInt()}';
    }
    
    return null;
  }
  
  // Connect to remote camera
  Future<bool> connectToRemoteCamera({
    required String url,
    String? username,
    String? password,
    int refreshRateMs = 500,
  }) async {
    try {
      // Stop local camera first
      await stopCamera();
      
      _remoteCameraUrl = url;
      _remoteUsername = username;
      _remotePassword = password;
      _refreshRateMs = refreshRateMs;
      
      // Test connection
      final success = await _testRemoteConnection();
      if (!success) {
        return false;
      }
      
      _isRemoteCamera = true;
      _isInitialized = true;
      
      // Start periodic frame fetching
      _startRemoteFrameFetching();
      
      return true;
    } catch (e) {
      _errorController.add('Failed to connect to remote camera: $e');
      return false;
    }
  }
  
  Future<bool> _testRemoteConnection() async {
    try {
      final response = await _makeHttpRequest();
      return response.statusCode == 200 && response.bodyBytes.isNotEmpty;
    } catch (e) {
      _errorController.add('Remote camera connection test failed: $e');
      return false;
    }
  }
  
  Future<http.Response> _makeHttpRequest() async {
    final uri = Uri.parse(_remoteCameraUrl!);
    
    if (_remoteUsername != null && _remotePassword != null) {
      final credentials = base64Encode(utf8Encode('$_remoteUsername:$_remotePassword'));
      return await http.get(
        uri,
        headers: {'Authorization': 'Basic $credentials'},
      ).timeout(const Duration(seconds: 10));
    } else {
      return await http.get(uri).timeout(const Duration(seconds: 10));
    }
  }
  
  void _startRemoteFrameFetching() {
    _remoteTimer?.cancel();
    _remoteTimer = Timer.periodic(Duration(milliseconds: _refreshRateMs), (timer) {
      fetchRemoteFrame();
    });
  }
  
  Future<void> fetchRemoteFrame() async {
    if (!_isRemoteCamera) return;
    
    try {
      final response = await _makeHttpRequest();
      
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        _remoteFrameController.add(response.bodyBytes);
      } else {
        _errorController.add('Failed to fetch frame: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _errorController.add('Error fetching remote frame: $e');
    }
  }
  
  // Take screenshot
  Future<String?> takeScreenshot({String outputDir = 'screenshots'}) async {
    try {
      if (_isRemoteCamera) {
        return await _takeRemoteScreenshot(outputDir);
      } else {
        return await _takeLocalScreenshot(outputDir);
      }
    } catch (e) {
      _errorController.add('Failed to take screenshot: $e');
      return null;
    }
  }
  
  Future<String?> _takeLocalScreenshot(String outputDir) async {
    if (_cameraController?.value.isInitialized != true) {
      return null;
    }
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final screenshotDir = Directory(path.join(directory.path, outputDir));
      
      if (!await screenshotDir.exists()) {
        await screenshotDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = path.join(screenshotDir.path, 'screenshot_$timestamp.jpg');
      
      final image = await _cameraController!.takePicture();
      final file = File(filePath);
      await file.writeAsBytes(await image.readAsBytes());
      
      return filePath;
    } catch (e) {
      _errorController.add('Failed to take local screenshot: $e');
      return null;
    }
  }
  
  Future<String?> _takeRemoteScreenshot(String outputDir) async {
    try {
      final response = await _makeHttpRequest();
      
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final directory = await getApplicationDocumentsDirectory();
        final screenshotDir = Directory(path.join(directory.path, outputDir));
        
        if (!await screenshotDir.exists()) {
          await screenshotDir.create(recursive: true);
        }
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = path.join(screenshotDir.path, 'remote_screenshot_$timestamp.jpg');
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath;
      }
    } catch (e) {
      _errorController.add('Failed to take remote screenshot: $e');
    }
    
    return null;
  }
  
  // Stop camera
  Future<void> stopCamera() async {
    try {
      _remoteTimer?.cancel();
      _remoteTimer = null;
      
      await _cameraController?.dispose();
      _cameraController = null;
      
      _isInitialized = false;
      _isRemoteCamera = false;
      _remoteCameraUrl = null;
      _remoteUsername = null;
      _remotePassword = null;
    } catch (e) {
      _errorController.add('Error stopping camera: $e');
    }
  }
  
  // Dispose resources
  void dispose() {
    stopCamera();
    _remoteFrameController.close();
    _errorController.close();
  }
}

// Helper function to encode base64
String base64Encode(List<int> bytes) {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  String result = '';
  
  for (int i = 0; i < bytes.length; i += 3) {
    int byte1 = bytes[i];
    int byte2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
    int byte3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
    
    int combined = (byte1 << 16) | (byte2 << 8) | byte3;
    
    result += chars[(combined >> 18) & 63];
    result += chars[(combined >> 12) & 63];
    result += i + 1 < bytes.length ? chars[(combined >> 6) & 63] : '=';
    result += i + 2 < bytes.length ? chars[combined & 63] : '=';
  }
  
  return result;
}

// Helper function to encode UTF8
List<int> utf8Encode(String str) {
  List<int> bytes = [];
  for (int i = 0; i < str.length; i++) {
    bytes.add(str.codeUnitAt(i));
  }
  return bytes;
}
