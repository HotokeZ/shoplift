import 'package:flutter/material.dart';
import 'admin_seller_approval_screen.dart';
import 'admin_product_screen.dart';
import 'admin_user_management_screen.dart';
import '../utils/app_icons.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'User Management', 'screen': AdminUserManagementScreen()},
    {'title': 'Manage Products', 'screen': AdminProductScreen()},
    {
      'title': 'Seller Applications',
      'screen': const AdminSellerApprovalScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // Disable the default back button
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Align icon and text vertically
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Navigate back
              },
              child: AppIcons.backArrowIcon(
                color: Colors.white, // Set the color of the back arrow
                size: 40.0, // Increase the size of the back arrow
              ),
            ),
            const SizedBox(width: 12), // Add spacing between the icon and text
            Text(
              _tabs[_currentIndex]['title'],
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      body: _tabs[_currentIndex]['screen'],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Applications',
          ),
        ],
      ),
    );
  }
}
