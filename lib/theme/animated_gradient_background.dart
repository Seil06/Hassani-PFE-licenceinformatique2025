import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/theme/app_pallete.dart';
import 'custom_gradient_pallete.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> primaryColors;
  final List<Color> secondaryColors;
  final Duration primaryRotationDuration;
  final Duration secondaryRotationDuration;
  final double blurRadius;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    required this.primaryColors, // Made required
    required this.secondaryColors, // Made required
    this.primaryRotationDuration = const Duration(seconds: 8),
    this.secondaryRotationDuration = const Duration(seconds: 10),
    this.blurRadius = 50.0,
  }) : super(key: key);

  @override
  _AnimatedGradientBackgroundState createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> 
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;

  @override
  void initState() {
    super.initState();

    _primaryController = AnimationController(
      vsync: this,
      duration: widget.primaryRotationDuration,
    )..repeat();

    _secondaryController = AnimationController(
      vsync: this,
      duration: widget.secondaryRotationDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LightAppPallete.background, // Theme background color
            LightAppPallete.backgroundAlt, // Theme alternate background color
          ],
        ),
      ),
      child: Stack(
        children: [
          // First rotating gradient layer
          AnimatedBuilder(
            animation: _primaryController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConicGradientPainter(
                  colors: widget.primaryColors,
                  rotation: _primaryController.value * 2 * pi,
                  blurRadius: widget.blurRadius,
                  opacity: 0.8,
                ),
                child: Container(),
              );
            },
          ),

          // Second rotating gradient layer
          AnimatedBuilder(
            animation: _secondaryController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConicGradientPainter(
                  colors: widget.secondaryColors,
                  rotation: _secondaryController.value * 2 * pi * -1,
                  blurRadius: widget.blurRadius * 0.8,
                  opacity: 0.6,
                  scale: 0.9,
                ),
                child: Container(),
              );
            },
          ),

          // Updated radial overlay to use theme colors
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.black.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class ConicGradientPainter extends CustomPainter {
  final List<Color> colors;
  final double rotation;
  final double blurRadius;
  final double opacity;
  final double scale;

  ConicGradientPainter({
    required this.colors,
    required this.rotation,
    required this.blurRadius,
    required this.opacity,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Create the shader for the conic gradient
    final shader = SweepGradient(
      colors: colors,
      transform: GradientRotation(rotation),
    ).createShader(rect);
    
    // Create a larger rect to ensure gradient fills the screen fully
    final largerRect = Rect.fromCenter(
      center: center,
      width: size.width * 2 * scale,
      height: size.height * 2 * scale,
    );
    
    final paint = Paint()
      ..shader = shader
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius)
      ..style = PaintingStyle.fill;
    
    // Apply opacity
    canvas.saveLayer(
      rect,
      Paint()..color = Colors.white.withOpacity(opacity),
    );
    
    // Draw the gradient
    canvas.drawRect(largerRect, paint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(ConicGradientPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

// Usage example:
// AnimatedGradientBackground(
//   child: YourAppContent(),
// )
