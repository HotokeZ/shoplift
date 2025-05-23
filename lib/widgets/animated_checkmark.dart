import 'package:flutter/material.dart';

/// A widget that displays an animated checkmark inside a circle
class AnimatedCheckmark extends StatefulWidget {
  /// Size of the checkmark circle
  final double size;

  /// Color of the checkmark
  final Color checkmarkColor;

  /// Background color of the circle
  final Color backgroundColor;

  const AnimatedCheckmark({
    Key? key,
    required this.size,
    required this.checkmarkColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Create scale animation for the circle
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Create animation for the checkmark
    _checkmarkAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _checkmarkAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size * 0.5, widget.size * 0.25),
                painter: CheckmarkPainter(
                  progress: _checkmarkAnimation.value,
                  color: widget.checkmarkColor,
                  strokeWidth: widget.size * 0.067, // 8px for 120px size
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Custom painter for drawing the checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Calculate points for the checkmark
    // The checkmark is drawn as an "L" shape rotated -45 degrees
    final double startX = 0;
    final double startY = size.height * 0.5;

    // Calculate the endpoint of the horizontal line
    final double midX = size.width * 0.4;
    final double midY = size.height;

    // Calculate the endpoint of the vertical line
    final double endX = size.width;
    final double endY = 0;

    // Draw the first part of the checkmark (bottom-left to middle)
    if (progress <= 0.5) {
      // Scale the progress to 0-1 range for the first half of the animation
      final double firstPartProgress = progress * 2;

      path.moveTo(startX, startY);
      path.lineTo(
        startX + (midX - startX) * firstPartProgress,
        startY + (midY - startY) * firstPartProgress,
      );
    } else {
      // Draw the complete first part
      path.moveTo(startX, startY);
      path.lineTo(midX, midY);

      // Draw the second part of the checkmark (middle to top-right)
      // Scale the progress to 0-1 range for the second half of the animation
      final double secondPartProgress = (progress - 0.5) * 2;

      path.lineTo(
        midX + (endX - midX) * secondPartProgress,
        midY + (endY - midY) * secondPartProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}