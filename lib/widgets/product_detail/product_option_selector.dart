import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A widget that displays a product option selector (size, color, quantity)
class ProductOptionSelector extends StatelessWidget {
  /// The label for the option (e.g., "Size", "Color", "Quantity")
  final String label;

  /// The currently selected value
  final String? selectedValue;

  /// Widget to display on the right side (e.g., dropdown icon, color swatch)
  final Widget? rightWidget;

  /// Widget to display in the center (e.g., quantity controls)
  final Widget? centerWidget;

  /// Callback when the selector is tapped
  final VoidCallback? onTap;

  const ProductOptionSelector({
    Key? key,
    required this.label,
    this.selectedValue,
    this.rightWidget,
    this.centerWidget,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.smallPadding,
          vertical: AppTheme.smallPadding,
        ),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(AppTheme.circularRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.optionLabelStyle,
            ),
            if (centerWidget != null) centerWidget!,
            if (selectedValue != null && centerWidget == null)
              Text(
                selectedValue!,
                style: AppTheme.optionValueStyle,
              ),
            if (rightWidget != null) rightWidget!,
          ],
        ),
      ),
    );
  }
}

/// A widget for quantity selector with plus and minus buttons
class QuantitySelector extends StatelessWidget {
  /// Current quantity value
  final int quantity;

  /// Callback when plus button is tapped
  final VoidCallback onIncrease;

  /// Callback when minus button is tapped
  final VoidCallback onDecrease;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate button size based on screen width
    double buttonSize;
    double buttonPadding;

    if (screenWidth <= AppTheme.mobileBreakpoint) {
      buttonSize = 24;
      buttonPadding = 6;
    } else if (screenWidth <= AppTheme.tabletBreakpoint) {
      buttonSize = 32;
      buttonPadding = 8;
    } else {
      buttonSize = 40;
      buttonPadding = 12;
    }

    return Row(
      children: [
        _buildButton(
          size: buttonSize,
          padding: buttonPadding,
          onTap: onIncrease,
          icon: CustomPaint(
            size: const Size(AppTheme.iconSize, AppTheme.iconSize),
            painter: _PlusPainter(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallPadding),
          child: Text(
            quantity.toString(),
            style: AppTheme.optionValueStyle,
          ),
        ),
        _buildButton(
          size: buttonSize,
          padding: buttonPadding,
          onTap: onDecrease,
          icon: CustomPaint(
            size: const Size(AppTheme.iconSize, AppTheme.iconSize),
            painter: _MinusPainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required double size,
    required double padding,
    required VoidCallback onTap,
    required Widget icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        decoration: const BoxDecoration(
          color: AppTheme.primaryRed,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

/// Custom painter for plus icon
class _PlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Horizontal line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for minus icon
class _MinusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Horizontal line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for down arrow icon
class DownArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.darkText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.667, size.height * 0.535)
      ..lineTo(size.width * 0.558, size.height * 0.644)
      ..lineTo(size.width * 0.441, size.height * 0.644)
      ..moveTo(size.width * 0.17, size.height * 0.373)
      ..lineTo(size.width * 0.787, size.height * 0.373);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}