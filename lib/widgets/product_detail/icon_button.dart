import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A custom circular icon button
class CircularIconButton extends StatelessWidget {
  /// The icon painter to use
  final CustomPainter iconPainter;

  /// Callback when button is tapped
  final VoidCallback? onTap;

  /// Semantic label for accessibility
  final String? semanticLabel;

  const CircularIconButton({
    Key? key,
    required this.iconPainter,
    this.onTap,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Container(
          width: AppTheme.iconButtonSize,
          height: AppTheme.iconButtonSize,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.lightGray,
            shape: BoxShape.circle,
          ),
          child: CustomPaint(
            painter: iconPainter,
            size: const Size(AppTheme.iconSize, AppTheme.iconSize),
          ),
        ),
      ),
    );
  }
}