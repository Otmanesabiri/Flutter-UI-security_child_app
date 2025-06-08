import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// A widget to display a list of alerts with error handling
class AlertList extends StatelessWidget {
  /// List of alerts to display
  final List<Map<String, dynamic>> alerts;

  /// Maximum number of alerts to show
  final int maxAlerts;

  /// Message to show when no alerts are available
  final String emptyMessage;

  /// Text style for alert entries
  final TextStyle? alertStyle;

  /// Creates an alert list widget
  const AlertList({
    super.key,
    required this.alerts,
    this.maxAlerts = 5,
    this.emptyMessage = 'No alerts to display',
    this.alertStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorHandler.buildSafeWidget(
      builder: () {
        if (alerts.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        final displayCount =
            alerts.length > maxAlerts ? maxAlerts : alerts.length;

        return ListView.builder(
          itemCount: displayCount,
          itemBuilder: (context, index) {
            try {
              final alert = alerts[index];
              final objectName = alert['object'] ?? 'Unknown';
              final confidence = alert['confidence'] ?? 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '⚠️ $objectName (${confidence.toStringAsFixed(2)})',
                  style: alertStyle ?? const TextStyle(color: Colors.red),
                ),
              );
            } catch (e) {
              return const Text(
                '⚠️ Error displaying alert',
                style: TextStyle(color: Colors.orange),
              );
            }
          },
        );
      },
      fallback: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(height: 8),
            Text("Could not load alerts"),
          ],
        ),
      ),
    );
  }
}
