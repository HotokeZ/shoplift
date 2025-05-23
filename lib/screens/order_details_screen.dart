import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final String address;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String orderNumber;
  final String orderStatus;
  final String paymentMethod;
  final double shippingCost;
  final double tax;
  final double subtotal;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
    required this.address,
    required this.items,
    required this.totalPrice,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentMethod,
    required this.shippingCost,
    required this.tax,
    required this.subtotal,
  }) : super(key: key);

  Future<void> _cancelOrder(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'orderStatus': 'Canceled'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order has been canceled.')),
      );
      Navigator.of(context).pop(); // Go back after canceling
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel order: $e')),
      );
    }
  }

  Future<void> _requestRefund(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'refundRequested': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refund request has been sent.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to request refund: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryRed,
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Number and Status
              Text(
                'Order Number: $orderNumber',
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: $orderStatus',
                style: AppTheme.descriptionStyle.copyWith(
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 24),

              // Delivery Information Section
              Text(
                'Delivery Information',
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(address, style: AppTheme.descriptionStyle),
              const SizedBox(height: 24),

              // Payment Method
              Text(
                'Payment Method: $paymentMethod',
                style: AppTheme.descriptionStyle,
              ),
              const SizedBox(height: 24),

              // Items Section
              Text(
                'Items',
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(color: AppTheme.lightGray),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selectedVarieties = item['selectedVarieties'] ?? {};
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name'],
                                style: AppTheme.descriptionStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₱${item['price'].toStringAsFixed(2)} x ${item['quantity']}',
                              style: AppTheme.descriptionStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (selectedVarieties is Map)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                selectedVarieties.entries.map<Widget>((entry) {
                                  return Text(
                                    '${entry.key}: ${entry.value}',
                                    style: AppTheme.descriptionStyle.copyWith(
                                      color: AppTheme.secondaryText,
                                    ),
                                  );
                                }).toList(),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Order Summary Section
              Text(
                'Order Summary',
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: AppTheme.descriptionStyle),
                  Text(
                    '₱${subtotal.toStringAsFixed(2)}',
                    style: AppTheme.descriptionStyle,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shipping Cost', style: AppTheme.descriptionStyle),
                  Text(
                    '₱${shippingCost.toStringAsFixed(2)}',
                    style: AppTheme.descriptionStyle,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax', style: AppTheme.descriptionStyle),
                  Text(
                    '₱${tax.toStringAsFixed(2)}',
                    style: AppTheme.descriptionStyle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTheme.subtitleStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '₱${totalPrice.toStringAsFixed(2)}',
                    style: AppTheme.subtitleStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Conditional Buttons
              if (orderStatus == 'Processing')
                ElevatedButton(
                  onPressed: () => _cancelOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(color: AppTheme.white),
                  ),
                ),
              if (orderStatus == 'Delivered')
                ElevatedButton(
                  onPressed: () => _requestRefund(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Request Refund',
                    style: TextStyle(color: AppTheme.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
