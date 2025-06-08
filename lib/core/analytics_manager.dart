import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Class to manage analytics data for detected objects and alerts
class AnalyticsManager {
  /// Storage file for analytics data
  final String storageFileName;

  /// Alerts data structure
  Map<String, dynamic> _alerts = {"alerts": []};

  /// UUID generator
  final Uuid _uuid = const Uuid();

  /// Constructor
  AnalyticsManager({this.storageFileName = "analytics_data.json"}) {
    _loadData();
    _logInfo("AnalyticsManager initialized");
  }

  /// Load existing analytics data if available
  Future<void> _loadData() async {
    try {
      final file = await _getStorageFile();
      if (await file.exists()) {
        final String contents = await file.readAsString();
        _alerts = json.decode(contents);
        _logInfo("Loaded ${_alerts["alerts"].length} alerts from storage");
      } else {
        _alerts = {"alerts": []};
        _logInfo("No existing analytics data found, created empty alerts data");
      }
    } catch (e) {
      _logError("Error loading analytics data: $e");
      _alerts = {"alerts": []};
    }
  }

  /// Save analytics data to storage file
  Future<void> _saveData() async {
    try {
      final file = await _getStorageFile();
      await file.writeAsString(json.encode(_alerts));
      _logInfo("Saved analytics data to storage");
    } catch (e) {
      _logError("Error saving analytics data: $e");
    }
  }

  /// Get the storage file for analytics data
  Future<File> _getStorageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$storageFileName');
  }

  /// Add a new alert to analytics database
  ///
  /// Returns the ID of the created alert
  Future<String> addAlert(String objectType, double confidence,
      {String? location}) async {
    final alertId = _uuid.v4();
    final timestamp = DateTime.now().toIso8601String();

    final alertData = {
      "id": alertId,
      "timestamp": timestamp,
      "object_type": objectType,
      "confidence": confidence,
      "location": location
    };

    _alerts["alerts"].add(alertData);
    await _saveData();
    _logInfo("Added alert ID $alertId to analytics");

    return alertId;
  }

  /// Get statistics about detected objects
  Map<String, dynamic> getStatistics() {
    final List<dynamic> alertsList = _alerts["alerts"];

    if (alertsList.isEmpty) {
      return {"total_alerts": 0};
    }

    final Map<String, dynamic> stats = {
      "total_alerts": alertsList.length,
      "by_object_type": <String, int>{}
    };

    for (final alert in alertsList) {
      final String objectType = alert["object_type"];
      final byObjectType = stats["by_object_type"] as Map<String, int>;

      if (!byObjectType.containsKey(objectType)) {
        byObjectType[objectType] = 0;
      }

      byObjectType[objectType] = byObjectType[objectType]! + 1;
    }

    return stats;
  }

  /// Get all alerts
  List<Map<String, dynamic>> getAllAlerts() {
    return List<Map<String, dynamic>>.from(_alerts["alerts"]);
  }

  /// Get alerts by object type
  List<Map<String, dynamic>> getAlertsByType(String objectType) {
    final List<dynamic> allAlerts = _alerts["alerts"];
    return List<Map<String, dynamic>>.from(
        allAlerts.where((alert) => alert["object_type"] == objectType));
  }

  /// Get alerts from the past number of days
  List<Map<String, dynamic>> getRecentAlerts(int days) {
    final DateTime cutoff = DateTime.now().subtract(Duration(days: days));
    final List<dynamic> allAlerts = _alerts["alerts"];

    return List<Map<String, dynamic>>.from(allAlerts.where((alert) {
      final alertTime = DateTime.parse(alert["timestamp"]);
      return alertTime.isAfter(cutoff);
    }));
  }

  /// Log an info message
  void _logInfo(String message) {
    if (kDebugMode) {
      print('AnalyticsManager: $message');
    }
  }

  /// Log an error message
  void _logError(String message) {
    if (kDebugMode) {
      print('AnalyticsManager ERROR: $message');
    }
  }
}
