import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A fixed bottom button for adding product to bag with price
class AddToBagButton extends StatelessWidget {
  /// The price to display
  final String price;

  /// Callback when button is tapped
  final VoidCallback? onTap;

  const AddToBagButton({
    Key? key,
    required this.price,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate padding based on screen size
    EdgeInsets padding;

    if (screenWidth <= AppTheme.mobileBreakpoint) {
      padding = const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      );
    } else if (screenWidth <= AppTheme.tabletBreakpoint) {
      padding = const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      );
    } else {
      padding = const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      );
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.mediumPadding),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(AppTheme.circularRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: AppTheme.buttonPriceStyle,
                ),
                const Text(
                  'Add to Bag',
                  style: AppTheme.buttonTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}