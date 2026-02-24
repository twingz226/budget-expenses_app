import 'package:flutter/material.dart';
import 'dart:ui';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // Theme-aware colors for glassmorphism effect
    final backgroundColor = isDarkMode
        ? Colors.grey.shade900.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.2);

    final borderColor = isDarkMode
        ? Colors.grey.shade600.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.3);

    return Container(
      height: height,
      width: width,
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
