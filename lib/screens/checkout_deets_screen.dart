import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout/checkout_section.dart';
import '../screens/address_screen.dart';
import '../screens/payment_screen.dart';
import '../widgets/checkout/order_summary.dart';
import '../widgets/checkout/place_order_button.dart';
import '../widgets/animated_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/add_address_screen.dart';
import '../screens/add_card_screen.dart';
import '../screens/order_placed_screen.dart'; // Import the OrderPlacedScreen
import '../widgets/custom_back_button.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;

  const CheckoutScreen({Key? key, required this.selectedItems})
    : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = 'Select a shipping address';
  String _selectedPaymentMethod = 'Cash on Delivery'; // Default placeholder
  bool _isLoading = false; // Add a loading state

  @override
  void initState() {
    super.initState();
    _loadLastUsedDetails();
  }

  Future<void> _loadLastUsedDetails() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      debugPrint("User not logged in.");
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(userId)
            .get();

    if (userDoc.exists) {
      setState(() {
        _selectedAddress =
            userDoc.data()?['lastUsedAddress'] ?? 'Select a shipping address';
        _selectedPaymentMethod =
            userDoc.data()?['lastUsedPaymentMethod'] ?? 'Cash on Delivery';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          // Header
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width <=
                                          AppTheme.breakpointMobile
                                      ? 16
                                      : 24,
                            ),
                            child: _buildHeader(context),
                          ),
                          const SizedBox(height: 32),

                          // Shipping Address
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width <=
                                          AppTheme.breakpointMobile
                                      ? 16
                                      : 24,
                            ),
                            child: _buildShippingAddressSection(context),
                          ),
                          const SizedBox(height: 16),

                          // Payment Method
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width <=
                                          AppTheme.breakpointMobile
                                      ? 16
                                      : 24,
                            ),
                            child: _buildPaymentMethodSection(context),
                          ),
                          const SizedBox(height: 16),

                          // Items Title
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width <=
                                          AppTheme.breakpointMobile
                                      ? 16
                                      : 24,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Items in Your Order',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Selected Items
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width <=
                                          AppTheme.breakpointMobile
                                      ? 16
                                      : 24,
                            ),
                            child: _buildSelectedItems(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // Order Summary
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: OrderSummary(
                    subtotal: '₱${_calculateSubtotal().toStringAsFixed(2)}',
                    shippingCost: '₱50.00',
                    tax: '₱${_calculateTax().toStringAsFixed(2)}',
                    total: '₱${_calculateTotal().toStringAsFixed(2)}',
                  ),
                ),
                
                // Place Order Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _placeOrder, // Disable button while loading
                    style: AppTheme.primaryButtonStyle,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Place Order',
                              style: AppTheme.buttonTextStyle,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0, // Align the header to the very top of the screen
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              MediaQuery.of(context).size.width <= AppTheme.breakpointMobile
                  ? 16
                  : 24,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomBackButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
            Text(
              'Checkout',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
              ),
            ),
            SizedBox(
              width: 40,
            ), // Adds some space for symmetry (like your Cart header)
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.selectedItems.map((item) {
            final selectedVarieties = item['varieties'];

            debugPrint(
              'Selected Varieties for ${item['name']}: $selectedVarieties',
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(item['image'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          item['name'],
                          style: AppTheme.descriptionStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Product Price and Quantity
                        Text(
                          '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                          style: AppTheme.descriptionStyle,
                        ),
                        const SizedBox(height: 4),

                        // Quantity
                        Text(
                          'Quantity: ${item['quantity']}',
                          style: AppTheme.descriptionStyle.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Selected Varieties
                        if (selectedVarieties != null &&
                            selectedVarieties is Map)
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
                          )
                        else
                          Text(
                            'No varieties selected',
                            style: AppTheme.descriptionStyle.copyWith(
                              color: AppTheme.secondaryText,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildShippingAddressSection(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return CheckoutSection(
      title: 'Shipping Address',
      content: GestureDetector(
        onTap: () {
          if (userId == null) {
            debugPrint("User not logged in.");
            return;
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('accounts')
                        .doc(userId)
                        .collection('addresses')
                        .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Prepare the address list, always including "Add New Address"
                  final List<String> addressList =
                      snapshot.hasData && snapshot.data!.docs.isNotEmpty
                          ? snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final fullName = data['fullName'] ?? '';
                            final contact = data['contactNumber'] ?? '';
                            final street = data['street'] ?? '';
                            final barangay = data['barangay'] ?? '';
                            final city = data['city'] ?? '';
                            final province = data['province'] ?? '';
                            final zip = data['zip'] ?? '';

                            return '$fullName, $contact\n$street, $barangay, $city, $province $zip';
                          }).toList()
                          : [];

                  addressList.add("Add New Address");

                  // Pass the list explicitly as List<String>
                  return AnimatedModal(
                    title: "Shipping Address",
                    options:
                        addressList
                            .cast<String>(), // Ensuring it's a List<String>
                    onSelect: (option) {
                      if (option == "Add New Address") {
                        Navigator.pop(context); // close modal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AddAddressScreen(userId: userId),
                          ),
                        );
                      } else {
                        setState(() {
                          _selectedAddress = option;
                        });
                      }
                    },
                  );
                },
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedAddress,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.darkText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
      onEdit: () {},
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return CheckoutSection(
      title: 'Payment Method',
      content: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return AnimatedModal(
                title: 'Select Payment Method',
                options: ['Cash on Delivery', 'GCash', 'Card'],
                onSelect: (selectedOption) {
                  if (selectedOption == 'Card') {
                    Navigator.pop(context); // Close the first modal

                    if (userId == null) {
                      debugPrint("User not logged in.");
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return FutureBuilder<QuerySnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('accounts')
                                  .doc(userId)
                                  .collection('cards')
                                  .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return AnimatedModal(
                                title: "Select a Card",
                                options: ['Add New Card'],
                                onSelect: (option) {
                                  if (option == "Add New Card") {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                AddCardScreen(userId: userId),
                                      ),
                                    );
                                  }
                                },
                              );
                            }

                            final cardList =
                                snapshot.data!.docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final last4 = data['cardNumber']
                                      .toString()
                                      .substring(data['cardNumber'].length - 4);
                                  final cardLabel = '•••• •••• •••• $last4';
                                  return cardLabel;
                                }).toList();

                            return AnimatedModal(
                              title: "Select a Card",
                              options: [...cardList, "Add New Card"],
                              onSelect: (option) {
                                if (option == "Add New Card") {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AddCardScreen(userId: userId),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    _selectedPaymentMethod = option;
                                  });
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  } else {
                    setState(() {
                      _selectedPaymentMethod = selectedOption;
                    });
                    Navigator.pop(context); // Close the modal
                  }
                },
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedPaymentMethod,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.darkText,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
      onEdit: () {},
    );
  }

  void _placeOrder() async {
    if (_isLoading) return; // Prevent multiple clicks

    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      debugPrint("User not logged in.");
      return;
    }

    if (_selectedAddress == 'Select a shipping address') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shipping address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading animation
    });

    try {
      // --- BANNED SELLER CHECK ---
      final productIds = <String>[];
      for (var item in widget.selectedItems) {
        final productId = item['productId'];
        if (productId != null) productIds.add(productId);
      }

      // Fetch all product docs in one go
      final productsSnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where(FieldPath.documentId, whereIn: productIds)
              .get();

      // Map productId -> sellerId
      final productSellerMap = <String, String>{};
      for (var doc in productsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        productSellerMap[doc.id] = data['userId'] as String? ?? '';
      }

      // Gather all unique sellerIds
      final sellerIds = productSellerMap.values.toSet().toList();

      // Fetch all seller accounts
      final sellersSnapshot =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where(FieldPath.documentId, whereIn: sellerIds)
              .get();

      // Map sellerId -> isBanned
      final bannedMap = <String, bool>{};
      for (var doc in sellersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bannedMap[doc.id] = data['isBanned'] == true;
      }

      // Check if any product is from a banned seller
      bool foundBanned = false;
      for (var item in widget.selectedItems) {
        final productId = item['productId'];
        final sellerId = productSellerMap[productId];
        if (sellerId != null &&
            bannedMap.containsKey(sellerId) &&
            bannedMap[sellerId] == true) {
          foundBanned = true;
          break;
        }
      }

      if (foundBanned) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'One or more products in your cart are from a banned seller and cannot be ordered.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // --- END BANNED SELLER CHECK ---

      // --- CONTINUE WITH ORDER PLACEMENT ---
      for (var item in widget.selectedItems) {
        final String orderId =
            FirebaseFirestore.instance.collection('orders').doc().id;
        final String orderNumber = _generateOrderNumber();

        final orderData = {
          'userId': userId,
          'orderId': orderId,
          'orderNumber': orderNumber,
          'shippingAddress': _selectedAddress,
          'paymentMethod': _selectedPaymentMethod,
          'orderDate': Timestamp.now(),
          'orderStatus': 'Processing',
          'items': [
            {
              'productId': item['productId'],
              'name': item['name'],
              'quantity': item['quantity'],
              'price': item['price'],
              'selectedVarieties': item['varieties'] ?? {},
            },
          ],
          'subtotal': item['price'] * item['quantity'],
          'shippingCost': 50.0,
          'tax': (item['price'] * item['quantity']) * 0.08,
          'totalPrice': (item['price'] * item['quantity']) * 1.08 + 50.0,
        };

        // Save individual order
        try {
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .set(orderData);
          debugPrint(
            "Order for item '${item['name']}' saved with ID: $orderId",
          );
        } catch (e) {
          debugPrint("Error saving order for item '${item['name']}': $e");
          throw e;
        }

        // Update product quantity
        final productRef = FirebaseFirestore.instance
            .collection('products')
            .doc(item['productId']);
        try {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final productSnapshot = await transaction.get(productRef);
            if (productSnapshot.exists) {
              final productData =
                  productSnapshot.data() as Map<String, dynamic>;
              final varietyTypes = productData['varietyTypes'];

              if (varietyTypes != null && varietyTypes is List) {
                // Handle products with varieties
                (item['varieties'] as Map<String, dynamic>).forEach((
                  varietyName,
                  varietyValue,
                ) {
                  for (var type in varietyTypes) {
                    if (type['name'] == varietyName) {
                      for (var value in type['values']) {
                        if (value['value'] == varietyValue) {
                          final currentQty =
                              int.tryParse(value['quantity']) ?? 0;
                          final newQty = currentQty - item['quantity'];
                          value['quantity'] = newQty.toString();
                          debugPrint(
                            "Updated quantity for variety '$varietyValue' of product '${item['name']}': $newQty",
                          );
                        }
                      }
                    }
                  }
                });

                transaction.update(productRef, {'varietyTypes': varietyTypes});
              } else {
                // Handle products without varieties
                final currentQty = productData['quantity'] ?? 0;
                if (currentQty is int) {
                  final newQty = currentQty - item['quantity'];
                  transaction.update(productRef, {'quantity': newQty});
                  debugPrint(
                    "Updated quantity for product '${item['name']}': $newQty",
                  );
                } else {
                  debugPrint(
                    "Error: 'quantity' field is not an integer or does not exist for product '${item['name']}'.",
                  );
                }
              }
            } else {
              debugPrint(
                "Error: Product '${item['name']}' does not exist in Firestore.",
              );
            }
          });
        } catch (e) {
          debugPrint("Error updating product '${item['name']}': $e");
          throw e;
        }

        // Remove item from user's cart
        final cartRef = FirebaseFirestore.instance
            .collection('accounts')
            .doc(userId)
            .collection('cart')
            .doc(item['id']);
        try {
          await cartRef.delete();
          debugPrint("Removed item '${item['name']}' from cart.");
        } catch (e) {
          debugPrint("Error removing item '${item['name']}': $e");
          throw e;
        }
      }

      // Save the last used address and payment method
      try {
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(userId)
            .update({
              'lastUsedAddress': _selectedAddress,
              'lastUsedPaymentMethod': _selectedPaymentMethod,
            });
        debugPrint("Updated last used address and payment method.");
      } catch (e) {
        debugPrint("Error updating last used address and payment method: $e");
        throw e;
      }

      // Navigate to OrderPlacedScreen after all orders processed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderPlacedScreen(onSeeOrderDetails: () {}),
        ),
      );
    } catch (e) {
      debugPrint('Error placing individual orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading animation
      });
    }
  }

  double _calculateSubtotal() {
    return widget.selectedItems.fold(0.0, (total, item) {
      return total + (item['price'] * item['quantity']);
    });
  }

  double _calculateTax() {
    const double taxRate = 0.08;
    return _calculateSubtotal() * taxRate;
  }

  double _calculateTotal() {
    const double shippingFee = 50.0;
    return _calculateSubtotal() + _calculateTax() + shippingFee;
  }
}

String _generateOrderNumber() {
  final now = DateTime.now();
  final uniquePart = (now.millisecondsSinceEpoch % 1000000).toString().padLeft(
    6,
    '0',
  );
  return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$uniquePart';
}
