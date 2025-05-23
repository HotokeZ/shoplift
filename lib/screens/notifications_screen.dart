import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/notification_item.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/order_details_screen.dart';
import '../screens/seller_order_details.dart';
import '../screens/admin_seller_approval_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedTab = 'Buyer'; // Default tab
  bool isSellerOrAdmin = false;
  bool isAdmin = false; // Add this variable

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Get the ID token with fresh claims
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;

      // Check admin status from claims
      final isAdminClaim = claims?['admin'] ?? false;
      
      // Check seller status from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final role = data['role'] ?? '';

        setState(() {
          isSellerOrAdmin = isAdminClaim || role == 'seller';
          isAdmin = isAdminClaim;
        });
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  // Add this method to handle seller application taps
  void _handleSellerApplicationTap(String applicantId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminSellerApprovalScreen(
          initialApplicantId: applicantId,
        ),
      ),
    );
  }

  // Update the existing _handleNotificationTap method
  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    final String notificationId = notification['id'] as String;
    final String type = notification['type'] ?? '';

    // Mark notification as read
    if (notification['hasRedDot'] == true) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'hasRedDot': false});
    }

    // Handle seller application notifications
    if (type == 'sellerApplication') {
      final String applicantId = notification['applicantId'] ?? '';
      if (applicantId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminSellerApprovalScreen(
              initialApplicantId: applicantId,
            ),
          ),
        );
      }
      return;
    }

    // Handle order notifications
    final String orderId = notification['orderId'] ?? '';
    final bool isSeller = notification['isSeller'] ?? false;

    // Fetch order details
    final orderDoc =
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get();

    if (!orderDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order not found')));
      return;
    }

    final orderData = orderDoc.data()!;

    if (isSeller) {
      // Navigate to seller order details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SellerOrderDetailsScreen(
                orderId: orderId,
                address: orderData['shippingAddress'] ?? '',
                items: List<Map<String, dynamic>>.from(
                  orderData['items'] ?? [],
                ),
                totalPrice: (orderData['totalPrice'] ?? 0.0).toDouble(),
                orderNumber: orderData['orderNumber'] ?? '',
                orderStatus: orderData['orderStatus'] ?? '',
                paymentMethod: orderData['paymentMethod'] ?? '',
                shippingCost: (orderData['shippingCost'] ?? 0.0).toDouble(),
                tax: (orderData['tax'] ?? 0.0).toDouble(),
                subtotal: (orderData['subtotal'] ?? 0.0).toDouble(),
                refundRequested: orderData['refundRequested'] ?? false,
              ),
        ),
      );
    } else {
      // Navigate to buyer order details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OrderDetailsScreen(
                orderId: orderId,
                address: orderData['shippingAddress'] ?? '',
                items: List<Map<String, dynamic>>.from(
                  orderData['items'] ?? [],
                ),
                totalPrice: (orderData['totalPrice'] ?? 0.0).toDouble(),
                orderNumber: orderData['orderNumber'] ?? '',
                orderStatus: orderData['orderStatus'] ?? '',
                paymentMethod: orderData['paymentMethod'] ?? '',
                shippingCost: (orderData['shippingCost'] ?? 0.0).toDouble(),
                tax: (orderData['tax'] ?? 0.0).toDouble(),
                subtotal: (orderData['subtotal'] ?? 0.0).toDouble(),
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          '/sign_in',
        ); // Redirect to SignInScreen
      });
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(), // Show a loading indicator while redirecting
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF272727),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Updated Tab Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Buyer Tab
                  _buildTab('Buyer'),
                  // Seller Tab
                  if (isSellerOrAdmin) _buildTab('Seller'),
                  // Admin Tab
                  if (isAdmin) _buildTab('Admin'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Updated Notifications List
            Expanded(
              child: _buildNotificationsList(
                context,
                FirebaseAuth.instance.currentUser!.uid,
                isSeller: selectedTab == 'Seller',
                isAdmin: selectedTab == 'Admin',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1, // Index for NotificationsScreen
      ),
    );
  }

  Widget _buildTab(String tabName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTab = tabName;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedTab == tabName ? Colors.red : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            color: selectedTab == tabName ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Update the notifications list builder
  Widget _buildNotificationsList(
    BuildContext context,
    String userId, {
    required bool isSeller,
    bool isAdmin = false,
  }) {
    Query query = FirebaseFirestore.instance.collection('notifications');

    if (isAdmin) {
      // Admin notifications include seller applications
      query = query.where('type', isEqualTo: 'sellerApplication');
    } else {
      // Regular user notifications
      query = query
          .where('userId', isEqualTo: userId)
          .where('isSeller', isEqualTo: isSeller);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query
          .orderBy('hasRedDot', descending: true)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error is FirebaseException ? 'Please wait while we set up the notifications' : snapshot.error}',
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading notifications...'),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No notifications available.'));
        }

        final notifications = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final notificationData =
                notification.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap:
                  () => _handleNotificationTap({
                    ...notificationData,
                    'id': notification.id, // Pass the document ID correctly
                  }),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    NotificationItem(
                      message: notificationData['message'] ?? '',
                      hasRedDot: notificationData['hasRedDot'] ?? false,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
