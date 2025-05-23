import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';

class ApplySellerScreen extends StatefulWidget {
  const ApplySellerScreen({Key? key}) : super(key: key);

  @override
  State<ApplySellerScreen> createState() => _ApplySellerScreenState();
}

class _ApplySellerScreenState extends State<ApplySellerScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? ''; // Pre-fill email
      });
    }
  }

  Future<void> _submitApplication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final shopName = _shopNameController.text.trim();
    final street = _streetController.text.trim();
    final barangay = _barangayController.text.trim();
    final city = _cityController.text.trim();
    final province = _provinceController.text.trim();
    final zip = _zipController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final email = _emailController.text.trim();

    if (shopName.isEmpty ||
        street.isEmpty ||
        barangay.isEmpty ||
        city.isEmpty ||
        province.isEmpty ||
        zip.isEmpty ||
        phoneNumber.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Create the seller application
      await FirebaseFirestore.instance.collection('sellerApplications').doc(user.uid).set({
        'userId': user.uid,
        'shopName': shopName,
        'pickupAddress': {
          'street': street,
          'barangay': barangay,
          'city': city,
          'province': province,
          'zip': zip,
        },
        'email': email,
        'phoneNumber': phoneNumber,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for admins
      // First, query for all admin users
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .where('role', isEqualTo: 'admin')
          .get();

      // Create notifications for each admin
      for (var adminDoc in adminSnapshot.docs) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': adminDoc.id,
          'message': 'New seller application from ${shopName}',
          'timestamp': Timestamp.now(),
          'hasRedDot': true,
          'isSeller': false,
          'isAdmin': true,
          'applicantId': user.uid,
          'type': 'sellerApplication'
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryRed, // Use primaryRed for the header
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context), // Back navigation
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppIcons.backArrowIcon(color: Colors.white), // Use back arrow from AppIcons
          ),
        ),
        title: const Text(
          'Apply to Become a Seller',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shop Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pickup Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _streetController,
                placeholder: 'Street Address',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _barangayController,
                placeholder: 'Barangay',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cityController,
                placeholder: 'City or Municipality',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _provinceController,
                placeholder: 'Province',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _zipController,
                placeholder: 'Zip Code',
              ),
              const SizedBox(height: 24),
              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Gray for cancel
                      foregroundColor: Colors.white, // White text for readability
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed, // Primary red for submit
                      foregroundColor: Colors.white, // White text for readability
                    ),
                    child: const Text('Submit Application'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: placeholder,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
