import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Widget that displays the order summary with subtotal, shipping, tax, and total
class OrderSummary extends StatelessWidget {
  /// Subtotal amount
  final String subtotal;

  /// Shipping cost
  final String shippingCost;

  /// Tax amount
  final String tax;

  /// Total amount
  final String total;

  const OrderSummary({
    Key? key,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width <= AppTheme.breakpointMobile
              ? 16
              : 24,
        ),
        color: AppTheme.white,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              // Subtotal
              _buildSummaryRow(
                label: 'Subtotal',
                value: subtotal,
                isTotal: false,
              ),

              const SizedBox(height: 12),

              // Shipping Cost
              _buildSummaryRow(
                label: 'Shipping Cost',
                value: shippingCost,
                isTotal: false,
              ),

              const SizedBox(height: 12),

              // Tax
              _buildSummaryRow(
                label: 'Tax',
                value: tax,
                isTotal: false,
              ),

              const SizedBox(height: 12),

              // Total
              _buildSummaryRow(
                label: 'Total',
                value: total,
                isTotal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required bool isTotal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.darkText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: isTotal ? 'Gabarito' : AppTheme.fontFamily,
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }
}