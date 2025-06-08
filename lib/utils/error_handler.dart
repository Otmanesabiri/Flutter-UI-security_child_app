import 'package:flutter/material.dart';

/// Global error handler to prevent app crashes
class ErrorHandler {
  /// Log an error and optionally display a snackbar message
  static void handleError(dynamic error, StackTrace? stackTrace,
      {BuildContext? context, String? friendlyMessage}) {
    // Always log the error
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }

    // Show a snackbar if context is provided
    if (context != null && context.mounted) {
      final message = friendlyMessage ?? 'An error occurred: $error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// Create a widget that renders safely even if there's an error
  static Widget buildSafeWidget({
    required Widget Function() builder,
    Widget? fallback,
  }) {
    try {
      return builder();
    } catch (e, stack) {
      handleError(e, stack);
      return fallback ??
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Widget error: $e',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }
  }
}
