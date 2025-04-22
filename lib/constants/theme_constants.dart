import 'package:flutter/material.dart';

class ThemeConstants {
  // Colors
  static const Color primaryText = Color(0xFF272727);
  static const Color backgroundColor = Colors.white;
  static const Color optionBackground = Color(0xFFF4F4F4);

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    color: primaryText,
    fontFamily: 'Gabarito',
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle actionStyle = TextStyle(
    color: primaryText,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle optionStyle = TextStyle(
    color: primaryText,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Spacing
  static const double dialogPadding = 24.0;
  static const double headerSpacing = 32.0;
  static const double optionSpacing = 16.0;
  static const double optionPadding = 18.0;

  // Borders
  static const double dialogBorderRadius = 24.0;
  static const double optionBorderRadius = 100.0;
  static const double recommendedBorderRadius = 16.0;
}