import 'package:flutter/material.dart';

class AppTheme {
  static const Color textColor = Color(0xFF272727);
  static const Color primaryRed = Color(0xFFFA3636);

  static const TextStyle gabaritoBold = TextStyle(
    fontFamily: 'Gabarito',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle circularStd = TextStyle(fontFamily: 'CircularStd');

  static ThemeData get theme => ThemeData(
    primaryColor: primaryRed,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(bodyLarge: circularStd, bodyMedium: circularStd),
  );
}
