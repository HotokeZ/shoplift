import 'package:flutter/material.dart';

class AboutYourselfScreenStyles {
  // Colors
  static const Color primaryRed = Color(0xFFFA3636);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF272727);
  static const Color greyBackground = Color(0xFFF4F4F4);

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    color: textColor,
    fontFamily: 'Gabarito',
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: textColor,
    fontSize: 16,
    fontFamily: 'System',
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: 'System',
  );

  // Dimensions
  static const double maxWidth = 412;
  static const double horizontalPadding = 24;
  static const double buttonHeight = 52;
  static const double borderRadius = 100;
}