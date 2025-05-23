import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/address_card.dart';
import '../screens/add_address_screen.dart';
import '../widgets/custom_modal.dart';
import '../utils/app_icons.dart';

/// Screen that displays a list of user addresses
class AddressScreen extends StatelessWidget {
  /// Callback function when back button is pressed
  final VoidCallback? onBackPressed;
  final String userId; // Accept userId as a parameter

  const AddressScreen({Key? key, this.onBackPressed, required this.userId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding calculation
    double horizontalPadding = 48.0;
    if (screenWidth <= AppTheme.breakpointTablet) {
      horizontalPadding = 24.0;
    }
    if (screenWidth <= AppTheme.breakpointMobile) {
      horizontalPadding = 16.0;
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            _buildHeader(context),

            // Address list section
            Expanded(child: _buildAddressList(context)),
          ],
        ),
      ),
      floatingActionButton: _buildAddAddressButton(context), // Add this line to display the button
    );
  }

  /// Builds the header section with back button and title
  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding calculation
    double verticalPadding = 20.0;
    if (screenWidth <= AppTheme.breakpointTablet) {
      verticalPadding = 16.0;
    }
    if (screenWidth <= AppTheme.breakpointMobile) {
      verticalPadding = 12.0;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _buildBackButton(context),

          // Title
          const Text(
            'Address',
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),

          // Empty container to balance the row
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // Back button widget (same as AddAddressScreen)
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 48.0, // Increased size for a bigger icon
        height: 48.0,
        margin: const EdgeInsets.only(
          left: 8.0,
        ), // Added margin to move it slightly to the right
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Center(
          child: SizedBox(
            width: 20.0, // Increased icon size
            height: 20.0,
            child: AppIcons.backArrowIcon(),
          ),
        ),
      ),
    );
  }

  /// Builds the list of address cards
  Widget _buildAddressList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('accounts')
              .doc(userId)
              .collection('addresses')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No addresses found.'));
        }

        final addresses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final addressData = addresses[index].data() as Map<String, dynamic>;
            final docId = addresses[index].id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AddressCard(
                address:
                    "${addressData['street']}, ${addressData['barangay']}, ${addressData['cityOrMunicipality']}, ${addressData['province']}",
              
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddAddressScreen(
                            userId: userId,
                            addressData:
                                addresses[index].data() as Map<String, dynamic>,
                            docId: addresses[index].id,
                          ),
                    ),
                  );
                },
                onDelete: () async {
                  final shouldDelete = await showDialog<bool>(context: context, builder: (context) => CustomModal(
                    title: 'Delete Address',
                    content: const Text(
                      'Are you sure you want to delete this address?',
                    ),
                    onClose: () => Navigator.pop(context, false),
                  ));

                  if (shouldDelete == true) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('accounts')
                          .doc(userId)
                          .collection('addresses')
                          .doc(docId)
                          .delete();
                      debugPrint('Delete operation successful');
                    } catch (e) {
                      debugPrint('Error during delete operation: $e');
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  // Floating plus icon button to add an address (similar to PaymentScreen)
  Widget _buildAddAddressButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddAddressScreen(userId: userId),
          ),
        );
      },
      backgroundColor: AppTheme.primaryRed,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
