import 'package:flutter/material.dart';

/// App theme containing colors, text styles, and dimensions
class AppTheme {
  // Colors
  static const Color primaryRed = Color(0xFFFA3636);
  static const Color darkText = Color(0xFF272727);
  static const Color lightGray = Color(0xFFF4F4F4);
  static const Color secondaryText = Color(0x80272727); // 50% opacity
  static const Color white = Color(0xFFFFFFFF);
  static const Color colorSwatch = Color(
    0xFFB3B68B,
  ); // Olive green color swatch
  static const Color textPrimary = Color(0xFF272727);
  static const Color borderColor = Color(0xFFD0D7DE);
  static const Color backButtonBg = Color(0xFFF6F8F0);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF4F4F4);
  static const Color textSecondary = Color(0x80272727); // 50% opacity
  static const Color primaryText = darkText;
  static const Color offWhite = Color(0xFFF9F9F9); // Off-white color

  // Text Styles
  static const String fontFamily = 'Circular Std';

  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'Gabarito',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: darkText,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Gabarito',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: darkText,
  );

  static const TextStyle priceStyle = TextStyle(
    fontFamily: 'Gabarito',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: primaryRed,
  );

  static const TextStyle optionLabelStyle = TextStyle(
    fontFamily: 'Circular Std',
    fontSize: 16,
    color: darkText,
  );

  static const TextStyle optionValueStyle = TextStyle(
    fontFamily: 'Circular Std',
    fontSize: 16,
    color: darkText,
  );

  static const TextStyle descriptionStyle = TextStyle(
    fontFamily: 'Circular Std',
    fontSize: 12,
    color: secondaryText,
    height: 1.6,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Circular Std',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: white,
  );

  static const TextStyle buttonPriceStyle = TextStyle(
    fontFamily: 'Gabarito',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: white,
  );

  static TextStyle get headingStyle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get buttonTextStyleNew => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: white,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ButtonStyle(
    backgroundColor: MaterialStateProperty.all(primaryRed),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
  );

  // Dimensions
  static const double defaultPadding = 32.0;
  static const double mediumPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double tinyPadding = 8.0;

  static const double borderRadius = 8.0;
  static const double circularRadius = 100.0;

  static const double iconButtonSize = 40.0;
  static const double iconSize = 16.0;
  static const double colorSwatchSize = 16.0;

  // Responsive breakpoints
  static const double tabletBreakpoint = 991.0;
  static const double mobileBreakpoint = 640.0;
  static const double breakpointMobile = 640.0;
  static const double breakpointTablet = 991.0;

  // Get responsive padding based on screen width
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= mobileBreakpoint) {
      return const EdgeInsets.all(smallPadding);
    } else if (width <= tabletBreakpoint) {
      return const EdgeInsets.all(mediumPadding);
    } else {
      return const EdgeInsets.all(defaultPadding);
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= breakpointMobile) {
      return const EdgeInsets.all(16.0);
    } else if (width <= breakpointTablet) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // ThemeData
  static ThemeData get theme => ThemeData(
    primaryColor: primaryRed,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: optionLabelStyle,
      bodyMedium: optionValueStyle,
    ),
  );
}
