import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  AnimatedBackgroundState createState() => AnimatedBackgroundState();
}

class AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();
  final int _particleCount = 20;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_particleCount, (index) {
      return AnimationController(
        duration: Duration(seconds: _random.nextInt(5) + 3),
        vsync: this,
      )..repeat(reverse: true);
    });
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(_particleCount, (index) {
            final startX = _random.nextDouble() * constraints.maxWidth;
            final startY = _random.nextDouble() * constraints.maxHeight;
            final endX = _random.nextDouble() * constraints.maxWidth;
            final endY = _random.nextDouble() * constraints.maxHeight;
            final size = _random.nextDouble() * 50 + 10;
            final color = isDarkMode
                ? primaryColor.withValues(alpha: 0.1)
                : secondaryColor.withValues(alpha: 0.1);

            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final t = _animations[index].value;
                final x = lerpDouble(startX, endX, t)!;
                final y = lerpDouble(startY, endY, t)!;
                final opacity = sin(t * pi * 2) * 0.5 + 0.5; // Pulsing opacity

                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}
