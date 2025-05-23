import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';

/// Checkout screen displaying order summary and payment options
class CheckoutScreen extends StatelessWidget {
  /// Callback for when the back button is pressed
  final VoidCallback? onBackPressed;

  /// Callback for when the place order button is pressed
  final VoidCallback? onPlaceOrderPressed;

  /// Callback for when the shipping address option is selected
  final VoidCallback? onShippingAddressPressed;

  /// Callback for when the payment method option is selected
  final VoidCallback? onPaymentMethodPressed;

  /// Order subtotal amount
  final String subtotal;

  /// Shipping cost amount
  final String shippingCost;

  /// Tax amount
  final String tax;

  /// Total order amount
  final String total;

  const CheckoutScreen({
    Key? key,
    this.onBackPressed,
    this.onPlaceOrderPressed,
    this.onShippingAddressPressed,
    this.onPaymentMethodPressed,
    this.subtotal = "\$200",
    this.shippingCost = "\$8.00",
    this.tax = "\$0.00",
    this.total = "\$208",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine responsive padding based on screen width
            EdgeInsets screenPadding;
            if (constraints.maxWidth <= AppTheme.mobileBreakpoint) {
              screenPadding = const EdgeInsets.fromLTRB(16, 24, 16, 24);
            } else if (constraints.maxWidth <= AppTheme.tabletBreakpoint) {
              screenPadding = const EdgeInsets.fromLTRB(24, 40, 24, 40);
            } else {
              screenPadding = const EdgeInsets.fromLTRB(24, 63, 24, 63);
            }

            return Container(
              width: double.infinity,
              height: double.infinity,
              padding: screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: _buildBackButton(context),
                  ),

                  // Checkout title
                  Text(
                    'Checkout',
                    style: const TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  // Shipping address option
                  _buildOptionItem(
                    label: 'Shipping Address',
                    value: 'Add Shipping Address',
                    onTap: onShippingAddressPressed,
                  ),

                  const SizedBox(height: 16),

                  // Payment method option
                  _buildOptionItem(
                    label: 'Payment Method',
                    value: 'Add Payment Method',
                    onTap: onPaymentMethodPressed,
                  ),

                  // Spacer to push summary to bottom
                  const Spacer(),

                  // Order summary
                  _buildOrderSummary(),

                  const SizedBox(height: 24),

                  // Place order button
                  _buildPlaceOrderButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the back button widget
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBackPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: SvgPicture.string(
            '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M7.46001 5.29336L5.71334 7.04003C5.20001 7.55336 5.20001 8.39336 5.71334 8.90669L10.06 13.2534M10.06 2.69336L9.36667 3.38669" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path>
            </svg>''',
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }

  /// Builds an option item with label, value and arrow
  Widget _buildOptionItem({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 72,
        padding: const EdgeInsets.fromLTRB(36, 12, 36, 12),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Circular Std',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.secondaryText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Circular Std',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.darkText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 12,
              child: SvgPicture.string(
                '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12.9 7.94004L15.52 10.56C16.29 11.33 16.29 12.59 15.52 13.36L9 19.87M9 4.04004L10.04 5.08004" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>''',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the order summary section
  Widget _buildOrderSummary() {
    return Column(
      children: [
        _buildSummaryRow(label: 'Subtotal', value: subtotal),
        const SizedBox(height: 12),
        _buildSummaryRow(label: 'Shipping Cost', value: shippingCost),
        const SizedBox(height: 12),
        _buildSummaryRow(label: 'Tax', value: tax),
        const SizedBox(height: 12),
        _buildSummaryRow(
          label: 'Total',
          value: total,
          isTotal: true,
        ),
      ],
    );
  }

  /// Builds a single row in the order summary
  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Container(
      width: double.infinity,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Circular Std',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: isTotal ? 'Gabarito' : 'Circular Std',
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the place order button
  Widget _buildPlaceOrderButton() {
    return GestureDetector(
      onTap: onPlaceOrderPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryRed,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              total,
              style: const TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
            const Text(
              'Place Order',
              style: TextStyle(
                fontFamily: 'Circular Std',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}