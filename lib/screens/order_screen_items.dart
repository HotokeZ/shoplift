import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/order_details_screen.dart';
import '../screens/sign_in_screen.dart';

class OrdersScreenItems extends StatefulWidget {
  const OrdersScreenItems({super.key});

  @override
  State<OrdersScreenItems> createState() => _OrdersScreenItemsState();
}

class _OrdersScreenItemsState extends State<OrdersScreenItems> {
  String selectedStatus = 'Processing';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Redirect to SignInScreen if the user is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  Future<Map<String, String>> _getProductDetails(String productId) async {
    final productDoc =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();
    if (productDoc.exists) {
      final data = productDoc.data()!;
      final images = List<String>.from(data['images'] ?? []);
      return {
        'image': images.isNotEmpty ? images.first : '', // Get the first image
        'name': data['name'] ?? 'Unknown Product',
      };
    }
    return {'image': '', 'name': 'Unknown Product'};
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Redirect to SignInScreen if the user is not logged in
    if (user == null) {
      return const SizedBox(); // Return an empty widget while redirecting
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 71),
            const Text(
              'Orders',
              style: TextStyle(
                color: Color(0xFF272727),
                fontFamily: 'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 40),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final status in [
                    'Processing',
                    'Shipped',
                    'Delivered',
                    'Returned',
                    'Canceled',
                  ])
                    OrderStatusChip(
                      label: status,
                      isActive: selectedStatus == status,
                      onTap: () {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('orders')
                          .where('userId', isEqualTo: user.uid)
                          .where('orderStatus', isEqualTo: selectedStatus)
                          .orderBy(
                            'orderDate',
                            descending: true,
                          ) // Sort by orderDate descending
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No orders found.'));
                    }

                    final orders = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final orderId = order.id;
                        final orderNumber =
                            order.data().toString().contains('orderNumber')
                                ? order['orderNumber']
                                : 'ORD-UNKNOWN';
                        final shortOrderNumber =
                            orderNumber.length >= 6
                                ? orderNumber.substring(orderNumber.length - 6)
                                : orderNumber;
                        final items = List<Map<String, dynamic>>.from(
                          order['items'] ?? [],
                        );
                        final item = items.isNotEmpty ? items.first : null;
                        final itemCount = items.fold<int>(
                          0,
                          (sum, item) => sum + ((item['quantity'] ?? 0) as int),
                        );
                        final totalPrice = order['totalPrice'] ?? 0.0;
                        final status = order['orderStatus'];
                        final productId = item?['productId'] ?? '';
                        final shippingAddress = order['shippingAddress'] ?? '';

                        return FutureBuilder<Map<String, String>>(
                          future: _getProductDetails(productId),
                          builder: (context, productSnapshot) {
                            if (productSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final productDetails =
                                productSnapshot.data ??
                                {'image': '', 'name': 'Unknown Product'};
                            final productImage = productDetails['image']!;
                            final productName = productDetails['name']!;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => OrderDetailsScreen(
                                          orderId: order['orderId'] ?? '',
                                          address:
                                              order['shippingAddress'] ?? '',
                                          items:
                                              List<Map<String, dynamic>>.from(
                                                order['items'] ?? [],
                                              ),
                                          totalPrice:
                                              (order['totalPrice'] ?? 0.0)
                                                  .toDouble(),
                                          orderNumber:
                                              order['orderNumber'] ??
                                              'ORD-UNKNOWN',
                                          orderStatus:
                                              order['orderStatus'] ?? 'Unknown',
                                          paymentMethod:
                                              order['paymentMethod'] ??
                                              'Unknown',
                                          shippingCost:
                                              (order['shippingCost'] ?? 0.0)
                                                  .toDouble(),
                                          tax: (order['tax'] ?? 0.0).toDouble(),
                                          subtotal:
                                              (order['subtotal'] ?? 0.0)
                                                  .toDouble(),
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    if (productImage.isNotEmpty)
                                      Image.network(
                                        productImage,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order #$shortOrderNumber',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Product: $productName'),
                                          Text('Items: $itemCount'),
                                          Text(
                                            'Total: ₱${totalPrice.toStringAsFixed(2)}',
                                          ),
                                          Text('Status: $status'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
