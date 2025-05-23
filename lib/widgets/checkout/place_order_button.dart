import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Widget that displays the fixed bottom bar with total and place order button
class PlaceOrderButton extends StatelessWidget {
  /// Total amount to display
  final String total;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  const PlaceOrderButton({
    Key? key,
    required this.total,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.width <= AppTheme.breakpointMobile ? 16 : 24,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width <= AppTheme.breakpointMobile
              ? 16
              : 24,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1152,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(AppTheme.circularRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total amount
              Text(
                total,
                style: const TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),

              // Place Order text
              GestureDetector(
                onTap: onPressed,
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}