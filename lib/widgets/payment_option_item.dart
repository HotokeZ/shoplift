import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';

/// A reusable widget for displaying payment options like cards or digital wallets
class PaymentOptionItem extends StatelessWidget {
  /// Unique identifier for the payment method
  final String id;

  /// Display value (masked card number, phone number, etc.)
  final String displayValue;

  /// Optional icon to display (like card logo)
  final Widget? icon;

  /// Whether this payment option is currently selected
  final bool isSelected;

  /// Callback when the payment option is tapped
  final Function(String, String)? onTap;

  const PaymentOptionItem({
    Key? key,
    required this.id,
    required this.displayValue,
    this.icon,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding calculation
    double verticalPadding = 24.0;
    double horizontalPadding = 12.0;

    if (screenWidth <= AppTheme.breakpointTablet) {
      verticalPadding = 20.0;
      horizontalPadding = 10.0;
    }
    if (screenWidth <= AppTheme.breakpointMobile) {
      verticalPadding = 16.0;
      horizontalPadding = 8.0;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap!(id, displayValue);
          }
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Payment display value (card number, phone, etc.)
              Text(
                displayValue,
                style: AppTheme.optionValueStyle,
                semanticsLabel: 'Payment option $displayValue',
              ),

              // Right side with icon (if provided) and arrow
              Row(
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  SvgPicture.string(
                    '''
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M12.9 7.94004L15.52 10.56C16.29 11.33 16.29 12.59 15.52 13.36L9 19.87M9 4.04004L10.04 5.08004" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path>
                    </svg>
                    ''',
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}