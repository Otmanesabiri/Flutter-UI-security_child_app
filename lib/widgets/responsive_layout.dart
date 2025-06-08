import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// A responsive layout widget that renders different layouts based on screen size
class ResponsiveLayout extends StatelessWidget {
  /// Widget to display on mobile screens (narrow width)
  final Widget mobileLayout;

  /// Widget to display on tablet/desktop screens (wider width)
  final Widget desktopLayout;

  /// Breakpoint that determines when to switch layouts (in pixels)
  final double breakpoint;

  /// Creates a responsive layout that renders different UIs based on screen width
  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.desktopLayout,
    this.breakpoint = 600,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorHandler.buildSafeWidget(
      builder: () {
        final screenWidth = MediaQuery.of(context).size.width;
        return screenWidth < breakpoint ? mobileLayout : desktopLayout;
      },
      fallback: const Center(
        child: Text('Error rendering responsive layout'),
      ),
    );
  }
}

/// A container with responsive padding that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  /// Child widget to display
  final Widget child;

  /// Padding for mobile screens
  final EdgeInsetsGeometry mobilePadding;

  /// Padding for desktop screens
  final EdgeInsetsGeometry desktopPadding;

  /// Breakpoint width to switch between mobile/desktop layouts
  final double breakpoint;

  /// Background color
  final Color? backgroundColor;

  /// Border decoration
  final BoxBorder? border;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Creates a container with responsive padding
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobilePadding = const EdgeInsets.all(8.0),
    this.desktopPadding = const EdgeInsets.all(16.0),
    this.breakpoint = 600,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < breakpoint;

    return Container(
      padding: isSmallScreen ? mobilePadding : desktopPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

/// A button that adapts its size based on screen width
class ResponsiveButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Icon to display
  final IconData? icon;

  /// Action to perform when pressed
  final VoidCallback onPressed;

  /// Button color
  final Color? color;

  /// Text color
  final Color? textColor;

  /// Whether to expand full width on mobile
  final bool expandOnMobile;

  /// Breakpoint width
  final double breakpoint;

  /// Creates a responsive button
  const ResponsiveButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.color,
    this.textColor,
    this.expandOnMobile = true,
    this.breakpoint = 600,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < breakpoint;

    return SizedBox(
      width: (isSmallScreen && expandOnMobile) ? double.infinity : null,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: textColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: textColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              child: Text(text),
            ),
    );
  }
}
