import 'package:flutter/material.dart';

class PasswordResetConfirmationScreen extends StatelessWidget {
  const PasswordResetConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    final textSize = _getTextSize(screenWidth);
    final buttonPadding = _getButtonPadding(screenWidth);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 342,
                  ),
                  child: Column(
                    children: [
                      Image.network(
                        'https://cdn.builder.io/api/v1/image/assets/TEMP/e5ff6ee1afe5d649de035ab282074853ba7391c8',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: screenWidth <= 640 ? 20 : 24),
                      Text(
                        'We Sent you an Email to reset your password.',
                        style: TextStyle(
                          color: const Color(0xFF272727),
                          fontFamily: 'Inter',
                          fontSize: textSize,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenWidth <= 640 ? 20 : 24),
                      _buildReturnButton(context, buttonPadding),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context, EdgeInsets padding) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFFFA3636),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          'Return to Login',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: MediaQuery.of(context).size.width <= 640 ? 15 : 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth <= 640) {
      return 16;
    } else if (screenWidth <= 991) {
      return 20;
    }
    return 35;
  }

  double _getTextSize(double screenWidth) {
    if (screenWidth <= 640) {
      return 20;
    } else if (screenWidth <= 991) {
      return 22;
    }
    return 24;
  }

  EdgeInsets _getButtonPadding(double screenWidth) {
    if (screenWidth <= 640) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  }
}