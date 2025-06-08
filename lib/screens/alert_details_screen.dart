import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlertDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> alert;
  final Database? database;

  const AlertDetailsScreen({
    Key? key,
    required this.alert,
    this.database,
  }) : super(key: key);

  @override
  State<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends State<AlertDetailsScreen> {
  bool _isProcessing = false;
  String? _processingError;

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.alert['timestamp'] as String?;
    final DateTime? dateTime =
        timestamp != null ? DateTime.tryParse(timestamp) : null;
    final formattedDate = dateTime != null
        ? DateFormat('MMMM d, yyyy - h:mm a').format(dateTime)
        : 'Unknown date';

    final confidence = widget.alert['confidence'] as double? ?? 0.0;
    final riskLevel = confidence > 0.7
        ? 'High'
        : confidence > 0.4
            ? 'Medium'
            : 'Low';
    final riskColor = confidence > 0.7
        ? Colors.red
        : confidence > 0.4
            ? Colors.orange
            : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Export Analysis',
            onPressed: _exportAnalysis,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuItemSelection,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'telegram',
                child: Row(
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text('Send to Telegram'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : _processingError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(_processingError!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _processingError = null;
                          });
                        },
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Alert Header Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundColor:
                                          riskColor.withOpacity(0.2),
                                      child: Icon(
                                        Icons.warning_rounded,
                                        size: 36,
                                        color: riskColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.alert['object'] ??
                                                'Unknown Object',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall,
                                          ),
                                          Text(
                                            formattedDate,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: riskColor.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$riskLevel Risk',
                                              style: TextStyle(
                                                color: riskColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Details Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Details',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Divider(),
                                _buildDetailRow(
                                  'Detected Object',
                                  widget.alert['object'] ?? 'Unknown',
                                  Icons.view_in_ar,
                                ),
                                _buildDetailRow(
                                  'Confidence Level',
                                  '${(confidence * 100).toStringAsFixed(1)}%',
                                  Icons.verified_user,
                                  valueColor: riskColor,
                                ),
                                _buildDetailRow(
                                  'Date & Time',
                                  formattedDate,
                                  Icons.access_time,
                                ),
                                _buildDetailRow(
                                  'Location',
                                  widget.alert['location'] ??
                                      'Unknown location',
                                  Icons.location_on,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Actions',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _markAsHandled,
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Mark as Handled'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _deleteAlert,
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Delete'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Recommendations Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recommendations',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                _buildRecommendation(
                                  widget.alert['object'] ?? 'Object',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () => _shareAlert(),
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
            TextButton.icon(
              onPressed: () => _sendToTelegram(),
              icon: const Icon(Icons.send),
              label: const Text('Send to Telegram'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String object) {
    // Sample recommendations based on object type
    final recommendations = {
      'knife': [
        'Keep sharp objects out of children\'s reach',
        'Store knives in locked drawers or high cabinets',
        'Teach children about kitchen safety',
      ],
      'scissors': [
        'Use safety scissors for children',
        'Store scissors in secured locations',
        'Supervise young children when using cutting tools',
      ],
      'gun': [
        'IMMEDIATELY secure firearms in proper gun safes',
        'Keep ammunition separate from firearms',
        'Ensure gun storage is inaccessible to children',
        'Consider contacting authorities if unauthorized access is suspected',
      ],
      'bottle': [
        'Ensure bottles don\'t contain harmful substances',
        'Keep cleaning supplies and chemicals locked away',
        'Label all containers clearly',
      ],
      'cell phone': [
        'Monitor screen time and device usage',
        'Set parental controls on mobile devices',
        'Keep devices away during meal times and bedtime',
      ],
    };

    // Find recommendations for this object
    final List<String> objectRecommendations = [];
    for (final key in recommendations.keys) {
      if (object.toLowerCase().contains(key)) {
        objectRecommendations.addAll(recommendations[key]!);
        break;
      }
    }

    // Default recommendations if none found
    if (objectRecommendations.isEmpty) {
      objectRecommendations.addAll([
        'Keep potentially dangerous objects away from children',
        'Supervise children when around unfamiliar objects',
        'Educate children about safety practices',
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: objectRecommendations
          .map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Future<void> _shareAlert() async {
    final timestamp = widget.alert['timestamp'] as String?;
    final DateTime? dateTime =
        timestamp != null ? DateTime.tryParse(timestamp) : null;
    final formattedDate = dateTime != null
        ? DateFormat('MMMM d, yyyy - h:mm a').format(dateTime)
        : 'Unknown date';

    final confidenceValue =
        (widget.alert['confidence'] as double? ?? 0.0) * 100;

    final message = '''
🚨 SECURITY ALERT
Object: ${widget.alert['object'] ?? 'Unknown'}
Confidence: ${confidenceValue.toStringAsFixed(1)}%
Time: $formattedDate
Location: ${widget.alert['location'] ?? 'Unknown location'}

This alert was generated by Child Security System.
''';

    try {
      await Share.share(message);
    } catch (e) {
      setState(() {
        _processingError = 'Failed to share: $e';
      });
    }
  }

  Future<void> _sendToTelegram() async {
    final prefs = await SharedPreferences.getInstance();
    final botToken = prefs.getString('telegramBotToken');
    final chatId = prefs.getString('telegramChatId');

    if (botToken == null ||
        botToken.isEmpty ||
        chatId == null ||
        chatId.isEmpty) {
      setState(() {
        _processingError =
            'Telegram settings not configured. Please set up Telegram in Settings.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final timestamp = widget.alert['timestamp'] as String?;
      final DateTime? dateTime =
          timestamp != null ? DateTime.tryParse(timestamp) : null;
      final formattedDate = dateTime != null
          ? DateFormat('MMMM d, yyyy - h:mm a').format(dateTime)
          : 'Unknown date';

      final confidenceValue =
          (widget.alert['confidence'] as double? ?? 0.0) * 100;

      final message = '''
🚨 *SECURITY ALERT* 🚨
*Object*: ${widget.alert['object'] ?? 'Unknown'}
*Confidence*: ${confidenceValue.toStringAsFixed(1)}%
*Time*: $formattedDate
*Location*: ${widget.alert['location'] ?? 'Unknown location'}

This alert was generated by Child Security System.
''';

      final url = 'https://api.telegram.org/bot$botToken/sendMessage';
      final response = await http.post(
        Uri.parse(url),
        body: {
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'Markdown',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert sent to Telegram')),
        );
      } else {
        setState(() {
          _processingError = 'Failed to send to Telegram: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _processingError = 'Error sending to Telegram: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _markAsHandled() async {
    // Here you would update the alert status in your database
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert marked as handled')),
    );
    Navigator.pop(context);
  }

  Future<void> _deleteAlert() async {
    if (widget.database == null) {
      setState(() {
        _processingError = 'Database not available';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final id = widget.alert['id'] as int?;
      if (id == null) {
        throw Exception('Alert ID not found');
      }

      await widget.database!.delete(
        'alerts',
        where: 'id = ?',
        whereArgs: [id],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert deleted')),
      );
      Navigator.pop(context, true); // Return true to indicate deletion
    } catch (e) {
      setState(() {
        _processingError = 'Failed to delete alert: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handleMenuItemSelection(String value) {
    switch (value) {
      case 'share':
        _shareAlert();
        break;
      case 'telegram':
        _sendToTelegram();
        break;
      case 'delete':
        _deleteAlert();
        break;
    }
  }

  Future<void> _exportAnalysis() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final timestamp = widget.alert['timestamp'] as String?;
      final DateTime? dateTime =
          timestamp != null ? DateTime.tryParse(timestamp) : null;
      final formattedDate = dateTime != null
          ? DateFormat('yyyy-MM-dd_HH-mm').format(dateTime)
          : 'unknown_date';

      final object = widget.alert['object'] ?? 'unknown';
      final confidence = widget.alert['confidence'] as double? ?? 0.0;
      final location = widget.alert['location'] ?? 'unknown_location';

      // Generate full analysis report
      final reportText = '''
CHILD SECURITY ALERT ANALYSIS
==============================
Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}

ALERT INFORMATION
Object Detected: ${widget.alert['object'] ?? 'Unknown'}
Date & Time: ${timestamp ?? 'Unknown'}
Confidence Level: ${(confidence * 100).toStringAsFixed(1)}%
Location: $location
Risk Level: ${confidence > 0.7 ? 'HIGH' : confidence > 0.4 ? 'MEDIUM' : 'LOW'}

RECOMMENDATIONS
${_getRecommendationsText(object)}

STATISTICS
- This is alert #${widget.alert['id'] ?? '?'} in the system
- Object type "$object" has been detected ${_getObjectFrequency(object)} times
- Most common detection location: ${_getMostCommonLocation()}

For more information, please consult the Child Security documentation.
''';

      await Share.share(reportText,
          subject: 'Alert Analysis: $object $formattedDate');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis report exported and shared')),
      );
    } catch (e) {
      setState(() {
        _processingError = 'Failed to export analysis: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Helper methods for analysis report
  String _getRecommendationsText(String object) {
    final recommendations = (_buildRecommendation(object) as Column)
        .children
        .whereType<Row>()
        .map((row) => row.children.last)
        .whereType<Expanded>()
        .map((expanded) => expanded.child)
        .whereType<Text>()
        .map((text) => '- ${text.data}')
        .join('\n');

    return recommendations.isNotEmpty
        ? recommendations
        : '- Keep potentially dangerous objects away from children\n- Supervise children around unfamiliar objects';
  }

  String _getObjectFrequency(String object) {
    // This would ideally query the database to count alerts with this object type
    // For now, return a placeholder value
    return '1+';
  }

  String _getMostCommonLocation() {
    // This would ideally analyze location data from all alerts
    // For now, return the current alert location
    return widget.alert['location'] ?? 'Unknown';
  }
}
