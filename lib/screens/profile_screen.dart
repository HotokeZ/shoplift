import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/bottom_nav_bar.dart';
import 'address_screen.dart';
import 'favorites_screen.dart';
import 'payment_screen.dart';
import 'apply_seller_screen.dart';
import 'home_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../widgets/custom_modal.dart';
import 'seller_dashboard_screen.dart'; // Updated redirect path
import '../screens/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _email;
  String? _phone;
  String? _role;
  bool _isSigningOut = false; // Add this state variable at the top of the class

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('accounts')
              .doc(user.uid)
              .get();

      // Add this check before using setState or context
      if (!mounted) return;

      if (userDoc.exists) {
        setState(() {
          _name = userDoc.data()?['fullName'] ?? 'Unknown';
          _email = userDoc.data()?['email'] ?? 'Unknown';
          _phone = userDoc.data()?['phone'] ?? '+63';
          _role = userDoc.data()?['role'] ?? 'buyer'; // Default to 'buyer'
        });
      } else {
        // Handle the case where the user document does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found. Please contact support.'),
          ),
        );
      }
    }
  }

  // Update the _signOut method
  void _signOut() async {
    // Set signing out state to true
    setState(() {
      _isSigningOut = true;
    });

    // Show a snackbar to indicate sign-out is in progress
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Signing out...'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryRed,
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update the 'isLoggedIn' field in Firestore
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(user.uid)
            .update({'isLoggedIn': false});

        // Sign out the user
        await FirebaseAuth.instance.signOut();

        // Use a separate method for navigation to avoid async issues
        _navigateToHomeScreen();
      }
    } catch (e) {
      // Reset signing out state if there's an error
      setState(() {
        _isSigningOut = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  // Separate method for navigation
  void _navigateToHomeScreen() {
    // Make sure we're mounted and then navigate
    if (!mounted) return;

    // Use pushReplacement for more reliable navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: _getResponsivePadding(context),
            child: Column(
              children: [
                ProfileInfoSection(
                  avatarUrl: 'https://via.placeholder.com/80',
                  name: _name ?? '',
                  email: _email ?? '',
                  phone: _phone ?? '',
                ),
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileMenuItem(
                        label: 'Address',
                        onTap: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddressScreen(
                                      userId: user.uid,
                                    ), // Pass userId
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please sign in to access your addresses.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        label: 'Wishlist',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        label: 'Payment',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        label: 'Seller',
                        onTap: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            if (_role == 'admin') {
                              // If the user is an admin, redirect to SellerDashboardScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const SellerDashboardScreen(),
                                ),
                              );
                              return;
                            }

                            final applicationDoc =
                                await FirebaseFirestore.instance
                                    .collection('sellerApplications')
                                    .doc(user.uid)
                                    .get();

                            if (applicationDoc.exists) {
                              final status = applicationDoc.data()?['status'];
                              if (status == 'approved') {
                                // Redirect to SellerDashboardScreen for approved sellers
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const SellerDashboardScreen(),
                                  ),
                                );
                                return;
                              } else if (status == 'pending') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your seller application is still pending.',
                                    ),
                                  ),
                                );
                                return;
                              } else if (status == 'rejected') {
                                final shouldApplyAgain = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => CustomModal(
                                        title: 'Application Rejected',
                                        content: const Text(
                                          'Your seller application was rejected. Would you like to apply again?',
                                        ),
                                        onClose:
                                            () => Navigator.pop(context, false),
                                        actions: [
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.primaryRed,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Apply Again',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );

                                if (shouldApplyAgain == true) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const ApplySellerScreen(),
                                    ),
                                  );
                                }
                                return;
                              }
                            }
                          }

                          // Redirect to ApplySellerScreen if no application exists
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApplySellerScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_role == 'admin') // Hide admin button if not admin
                        ProfileMenuItem(
                          label: 'Admin',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const AdminDashboardScreen(),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        label: 'Help',
                        onTap: () {
                          // Navigate to help screen
                        },
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        label: 'Support',
                        onTap: () {
                          // Navigate to support screen
                        },
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // First show confirmation dialog
                    showDialog(
                      context: context,
                      builder:
                          (context) => CustomModal(
                            title: 'Sign Out',
                            content: const Text(
                              'Are you sure you want to sign out?',
                              style: TextStyle(
                                fontFamily: 'Helvetica Now Text',
                                fontSize: 16,
                              ),
                            ),
                            onClose: () => Navigator.pop(context),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                // Disable when signing out
                                onPressed:
                                    _isSigningOut
                                        ? null
                                        : () {
                                          // IMMEDIATELY disable the button before any async operations
                                          setState(() {
                                            _isSigningOut = true;
                                          });

                                          // Close the dialog immediately to prevent further clicks
                                          Navigator.pop(context);

                                          // Now handle sign out process outside the dialog
                                          _performSignOut();
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isSigningOut
                                          ? AppTheme.primaryRed.withOpacity(0.7)
                                          : AppTheme.primaryRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    _isSigningOut
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Sign Out',
                                          style: TextStyle(color: Colors.white),
                                        ),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 32),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: 'Gabarito',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 3, // Index for ProfileScreen
      ),
    );
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= AppTheme.breakpointMobile) {
      return const EdgeInsets.fromLTRB(12, 20, 12, 0);
    } else if (width <= AppTheme.breakpointTablet) {
      return const EdgeInsets.fromLTRB(16, 30, 16, 0);
    } else {
      return const EdgeInsets.fromLTRB(20, 40, 20, 0);
    }
  }

  Future<void> _performSignOut() async {
    // Show a snackbar to indicate sign-out is in progress
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Signing out...'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryRed,
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update the 'isLoggedIn' field in Firestore
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(user.uid)
            .update({'isLoggedIn': false});

        // Sign out the user
        await FirebaseAuth.instance.signOut();

        // Navigate to home screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Reset signing out state if there's an error
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }
}
