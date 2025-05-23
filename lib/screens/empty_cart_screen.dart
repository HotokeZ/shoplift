import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';

/// A screen that displays when the user's cart is empty
class EmptyCartScreen extends StatelessWidget {
  /// Callback function when the explore button is pressed
  final VoidCallback? onExplorePressed;

  /// Callback function when the back button is pressed
  final VoidCallback? onBackPressed;

  const EmptyCartScreen({
    Key? key,
    this.onExplorePressed,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width <= AppTheme.tabletBreakpoint;
    final isMobile = screenSize.width <= AppTheme.mobileBreakpoint;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppTheme.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cart image
                  Image.asset(
                    'assets/images/cart_icon.png', // Replace with actual asset path
                    width: 100,
                    height: 100,
                    semanticLabel: 'Cart Icon',
                  ),

                  // Spacing
                  SizedBox(height: isMobile ? 20 : 27),

                  // Empty cart text
                  Text(
                    'Your Cart is Empty',
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: isMobile ? 20 : (isTablet ? 22 : 24),
                    ),
                    semanticsLabel: 'Your Cart is Empty',
                  ),

                  // Spacing
                  SizedBox(height: isMobile ? 20 : 27),

                  // Explore button
                  ElevatedButton(
                    onPressed: onExplorePressed,
                    style: AppTheme.primaryButtonStyle.copyWith(
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : (isTablet ? 22 : 24),
                          vertical: isMobile ? 12 : (isTablet ? 14 : 16),
                        ),
                      ),
                    ),
                    child: Text(
                      'Explore Categories',
                      style: AppTheme.buttonTextStyle.copyWith(
                        fontSize: isMobile ? 14 : (isTablet ? 15 : 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back button (only visible on mobile and tablet)
          if (isTablet)
            Positioned(
              top: isMobile ? 8 : 12,
              left: isMobile ? 8 : 12,
              child: GestureDetector(
                onTap: onBackPressed,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.backButtonBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.borderColor,
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CustomPaint(
                        painter: BackArrowPainter(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}