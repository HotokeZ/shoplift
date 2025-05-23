import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class SellerOrderDetailsScreen extends StatefulWidget {
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
  final bool refundRequested;

  const SellerOrderDetailsScreen({
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
    required this.refundRequested,
  }) : super(key: key);

  @override
  _SellerOrderDetailsScreenState createState() =>
      _SellerOrderDetailsScreenState();
}

class _SellerOrderDetailsScreenState extends State<SellerOrderDetailsScreen> {
  Future<void> _createStatusUpdateNotifications(String nextStatus) async {
    try {
      // Get order details to get buyer ID
      final orderDoc =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.orderId)
              .get();

      if (!orderDoc.exists) return;

      final orderData = orderDoc.data()!;
      final buyerId = orderData['userId'];
      final sellerId = orderData['sellerId'];

      // Create buyer notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': buyerId,
        'message':
            'Your order #${widget.orderNumber} has been updated to: $nextStatus',
        'timestamp': Timestamp.now(),
        'hasRedDot': true,
        'isSeller': false,
        'orderId': widget.orderId,
      });

      // Create seller notification
      if (sellerId != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': sellerId,
          'message':
              'Order #${widget.orderNumber} status updated to: $nextStatus',
          'timestamp': Timestamp.now(),
          'hasRedDot': true,
          'isSeller': true,
          'orderId': widget.orderId,
        });
      }
    } catch (e) {
      debugPrint('Error creating status update notifications: $e');
    }
  }

  Future<void> _updateOrderStatus(BuildContext context) async {
    String nextStatus;
    switch (widget.orderStatus) {
      case 'Processing':
        nextStatus = 'Shipped';
        break;
      case 'Shipped':
        nextStatus = 'Delivered';
        break;
      default:
        return;
    }

    try {
      // First verify if the current user is a seller
      final userDoc =
          await FirebaseFirestore.instance
              .collection('accounts')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get();

      if (!userDoc.exists || userDoc.data()?['role'] != 'seller') {
        throw Exception('Unauthorized: Only sellers can update order status');
      }

      // Update order status
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'orderStatus': nextStatus});

      // Create notifications
      await _createStatusUpdateNotifications(nextStatus);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $nextStatus')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order status: $e')),
        );
      }
    }
  }

  Future<void> _confirmRefund(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
            'orderStatus': 'Returned',
            'refundRequested': false, // Remove the refund request
          });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refund confirmed. Order marked as Returned.'),
        ),
      );
      Navigator.of(context).pop(); // Go back after confirming the refund
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to confirm refund: $e')));
    }
  }

  Future<void> _cancelOrder(BuildContext context) async {
    // Show confirmation dialog before canceling
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Order'),
            content: const Text('Are you sure you want to cancel this order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'orderStatus': 'Canceled'});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order has been canceled.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
    }
  }

  // Replace the dropdown and update button with new status progression buttons
  Widget _buildStatusButtons() {
    if (widget.refundRequested) {
      return ElevatedButton(
        onPressed: () => _confirmRefund(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Confirm Refund',
          style: TextStyle(color: AppTheme.white),
        ),
      );
    }

    // Don't show status buttons if order is already delivered or canceled
    if (widget.orderStatus == 'Delivered' || widget.orderStatus == 'Canceled') {
      return const SizedBox.shrink();
    }

    String buttonText;
    switch (widget.orderStatus) {
      case 'Processing':
        buttonText = 'Mark as Shipped';
        break;
      case 'Shipped':
        buttonText = 'Mark as Delivered';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _updateOrderStatus(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRed,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(color: AppTheme.white),
          ),
        ),
        const SizedBox(height: 8),
        if (widget.orderStatus == 'Processing')
          OutlinedButton(
            onPressed: () => _cancelOrder(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              side: const BorderSide(color: AppTheme.primaryRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel Order',
              style: TextStyle(color: AppTheme.primaryRed),
            ),
          ),
      ],
    );
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
                'Order Number: ${widget.orderNumber}',
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${widget.orderStatus}',
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
              Text(widget.address, style: AppTheme.descriptionStyle),
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
                  itemCount: widget.items.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(color: AppTheme.lightGray),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return Row(
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
                    '₱${widget.subtotal.toStringAsFixed(2)}',
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
                    '₱${widget.shippingCost.toStringAsFixed(2)}',
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
                    '₱${widget.tax.toStringAsFixed(2)}',
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
                    '₱${widget.totalPrice.toStringAsFixed(2)}',
                    style: AppTheme.subtitleStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Progression Buttons
              _buildStatusButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
