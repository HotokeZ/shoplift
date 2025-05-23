import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'seller_order_details.dart'; // Import the SellerOrderDetailsScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'add_product_screen.dart'; // Import the AddProductScreen for editing
import '../widgets/custom_modal.dart'; // Import the CustomModal widget

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Manage Products', 'screen': const ProductListScreen()},
    {
      'title': 'View Orders',
      'screen': const OrderListScreen(),
    }, // Added OrderListScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryRed,
        automaticallyImplyLeading: false,
        title: Text(
          _tabs[_currentIndex]['title'],
          style: const TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
      ),
      body: _tabs[_currentIndex]['screen'], // Display the selected tab's screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders', // Added Orders tab
          ),
        ],
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  // Add method to handle adding new product
  void _addProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomModal(
            title: 'Delete Product',
            content: const Text(
              'Are you sure you want to delete this product?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    }
  }

  void _editProduct(
    BuildContext context,
    String productId,
    Map<String, dynamic> productData,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddProductScreen(
              key: Key(productId),
              productId: productId,
              productData: productData,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? sellerId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('products')
                .where('userId', isEqualTo: sellerId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;

              final imageUrl =
                  (data['images'] as List<dynamic>?)?.isNotEmpty == true
                      ? data['images'][0] as String
                      : '';
              final productName = data['name'] ?? 'Unnamed Product';
              final productPrice = data['price']?.toString() ?? '0.0';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child:
                        imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                            : Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                  ),
                  title: Text(productName),
                  subtitle: Text('₱$productPrice'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduct(context, product.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(context, product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProduct(context),
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final String? sellerId = FirebaseAuth.instance.currentUser?.uid;
  String selectedFilter = 'All'; // Default filter
  String searchQuery = ''; // Search query

  Future<bool> _isOrderForSeller(
    String sellerId,
    List<Map<String, dynamic>> items,
  ) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (final item in items) {
      final productId = item['productId'];
      final productDoc =
          await firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        final productData = productDoc.data();
        if (productData != null && productData['userId'] == sellerId) {
          return true; // The seller is associated with this product
        }
      }
    }
    return false; // No products in this order belong to the seller
  }

  Future<List<QueryDocumentSnapshot>> _filterOrdersForSeller(
    String sellerId,
    List<QueryDocumentSnapshot> orders,
  ) async {
    final List<QueryDocumentSnapshot> filteredOrders = [];

    for (final order in orders) {
      final orderData = order.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(orderData['items']);
      final isForSeller = await _isOrderForSeller(sellerId, items);
      if (isForSeller) {
        filteredOrders.add(order);
      }
    }

    return filteredOrders;
  }

  @override
  Widget build(BuildContext context) {
    if (sellerId == null) {
      return const Center(child: Text('You must be logged in to view orders.'));
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by Order Number',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.trim();
              });
            },
          ),
        ),
        const SizedBox(height: 8),

        // Filter Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in [
                'All',
                'Processing',
                'Shipped',
                'Delivered',
                'Refund Requested',
                'Canceled',
                'Returned',
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedFilter == filter
                              ? Colors.red
                              : Colors.grey[200], // Highlight selected filter
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color:
                            selectedFilter == filter
                                ? Colors.white
                                : Colors.black, // Change text color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Orders List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders available.'));
              }

              final orders = snapshot.data!.docs;

              return FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _filterOrdersForSeller(sellerId!, orders),
                builder: (context, filteredSnapshot) {
                  if (filteredSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!filteredSnapshot.hasData ||
                      filteredSnapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No orders available for your products.'),
                    );
                  }

                  final filteredOrders = filteredSnapshot.data!;
                  final filteredByStatus =
                      filteredOrders.where((order) {
                        final orderData = order.data() as Map<String, dynamic>;
                        final orderStatus = orderData['orderStatus'] ?? '';
                        final refundRequested =
                            orderData['refundRequested'] ?? false;

                        // Filter by selected status
                        if (selectedFilter == 'All') return true;
                        if (selectedFilter == 'Refund Requested') {
                          return refundRequested == true;
                        }
                        return orderStatus == selectedFilter;
                      }).toList();

                  // Filter by search query
                  final searchedOrders =
                      filteredByStatus.where((order) {
                        final orderData = order.data() as Map<String, dynamic>;
                        final orderNumber = orderData['orderNumber'] ?? '';
                        return orderNumber.toString().toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        );
                      }).toList();

                  return ListView.separated(
                    itemCount: searchedOrders.length,
                    separatorBuilder:
                        (context, index) =>
                            const Divider(color: AppTheme.lightGray),
                    itemBuilder: (context, index) {
                      final order =
                          searchedOrders[index].data() as Map<String, dynamic>;
                      final refundRequested = order['refundRequested'] ?? false;

                      return ListTile(
                        title: Text(
                          'Order #${order['orderNumber']}',
                          style: AppTheme.descriptionStyle,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total: ₱${order['totalPrice'].toStringAsFixed(2)}',
                              style: AppTheme.descriptionStyle.copyWith(
                                color: AppTheme.secondaryText,
                              ),
                            ),
                            if (refundRequested)
                              Text(
                                'Refund Requested',
                                style: AppTheme.descriptionStyle.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to SellerOrderDetailsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SellerOrderDetailsScreen(
                                    orderId: searchedOrders[index].id, // Use the Firestore document ID instead of order['orderId']
                                    address: order['shippingAddress'] ?? '',
                                    items: List<Map<String, dynamic>>.from(order['items'] ?? []),
                                    totalPrice: (order['totalPrice'] ?? 0.0).toDouble(),
                                    orderNumber: order['orderNumber'] ?? '',
                                    orderStatus: order['orderStatus'] ?? '',
                                    paymentMethod: order['paymentMethod'] ?? '',
                                    shippingCost: (order['shippingCost'] ?? 0.0).toDouble(),
                                    tax: (order['tax'] ?? 0.0).toDouble(),
                                    subtotal: (order['subtotal'] ?? 0.0).toDouble(),
                                    refundRequested: order['refundRequested'] ?? false,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
