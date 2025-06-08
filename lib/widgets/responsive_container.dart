import 'package:flutter/material.dart';

/// A container that adapts its layout based on screen size
class ResponsiveContainer extends StatelessWidget {
  /// Child widget to display
  final Widget child;

  /// Height percentage relative to screen height
  final double heightPercentage;

  /// Maximum allowed height
  final double? maxHeight;

  /// Minimum allowed height
  final double? minHeight;

  /// Whether to wrap child in SingleChildScrollView
  final bool scrollable;

  /// Decoration for the container
  final BoxDecoration? decoration;

  /// Padding inside the container
  final EdgeInsetsGeometry? padding;

  /// Margin around the container
  final EdgeInsetsGeometry? margin;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.heightPercentage = 0.3,
    this.maxHeight,
    this.minHeight,
    this.scrollable = false,
    this.decoration,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double calculatedHeight = screenSize.height * heightPercentage;

    // Apply min/max constraints
    if (minHeight != null && calculatedHeight < minHeight!) {
      calculatedHeight = minHeight!;
    }
    if (maxHeight != null && calculatedHeight > maxHeight!) {
      calculatedHeight = maxHeight!;
    }

    return Container(
      height: calculatedHeight,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: scrollable ? SingleChildScrollView(child: child) : child,
    );
  }
}

/// A card with responsive height that adapts to different screen sizes
class ResponsiveCard extends StatelessWidget {
  /// Title of the card
  final String title;

  /// Content widget
  final Widget content;

  /// Action buttons
  final List<Widget>? actions;

  /// Height percentage relative to screen height
  final double heightPercentage;

  /// Maximum height
  final double? maxHeight;

  /// Whether content should be scrollable
  final bool scrollableContent;

  /// Background color for the card
  final Color? color;

  const ResponsiveCard({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.heightPercentage = 0.25,
    this.maxHeight,
    this.scrollableContent = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      heightPercentage: heightPercentage,
      maxHeight: maxHeight,
      margin: const EdgeInsets.all(8),
      child: Card(
        color: color,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),
              Expanded(
                child: scrollableContent
                    ? SingleChildScrollView(child: content)
                    : content,
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
