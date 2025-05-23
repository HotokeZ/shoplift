import 'package:flutter/material.dart';

/// App theme constants for consistent styling across the application
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFA3636);
  static const Color textPrimaryColor = Color(0xFF272727);
  static const Color backgroundLightGray = Color(0xFFF4F4F4);
  static const Color borderColor = Color(0xFFE6E6E6);
  static const Color white = Colors.white;

  // Text Styles
  static const TextStyle clearButtonStyle = TextStyle(
    fontFamily: 'Circular Std',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
  );

  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Gabarito',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimaryColor,
  );

  static const TextStyle optionTextStyle = TextStyle(
    fontFamily: 'Circular Std',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle optionTextStyleWhite = TextStyle(
    fontFamily: 'Circular Std',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: white,
  );

  // Decorations
  static BoxDecoration modalDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(13),
    border: Border.all(
      color: borderColor,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 32,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration primaryOptionDecoration = BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(100),
  );

  static BoxDecoration secondaryOptionDecoration = BoxDecoration(
    color: backgroundLightGray,
    borderRadius: BorderRadius.circular(100),
  );

  // Animation Curves
  static const Curve animationCurve = Cubic(0.37, 0.01, 0, 0.98);
}