import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import '../widgets/cart_item.dart';
import '../widgets/custom_modal.dart';
import '../screens/checkout_deets_screen.dart'; // Import the CustomModal
import '../screens/sign_in_screen.dart'; // Import SignInScreen

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late TextEditingController _couponController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track selected items
  final Set<String> _selectedItems = {};

  // Add these state variables to the class
  final Map<String, int> _localQuantities = {};
  Timer? _debounceTimer;

  // Local cart items to prevent flickering
  List<DocumentSnapshot> _cartItems = [];
  bool _isLoading = true;
  StreamSubscription? _cartSubscription;

  // Add this at the top of your _CartScreenState class:
  bool _isShowingRemoveModal = false;

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
    _loadCartItems(); // Load cart items once
  }

  @override
  void dispose() {
    _cartSubscription?.cancel(); // Cancel subscription
    _debounceTimer?.cancel();
    _couponController.dispose();
    super.dispose();
  }

  // New method to load cart items once
  void _loadCartItems() {
    final user = _auth.currentUser;
    if (user == null) return;

    _cartSubscription = _firestore
        .collection('accounts')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .listen(
          (snapshot) {
            // Process cart updates in one go
            setState(() {
              _cartItems = snapshot.docs;
              _isLoading = false;
            });
          },
          onError: (e) {
            debugPrint('Error loading cart: $e');
            setState(() {
              _isLoading = false;
            });
          },
        );
  }

  // Function to show the custom modal confirmation dialog for removing an item
  Future<void> _showRemoveConfirmation(
    String docId,
    int currentQty,
    String productId,
  ) {
    return showDialog(
      context: context,
      // Allow dismissing by tapping outside (restore original behavior)
      barrierDismissible: true,
      builder:
          (context) => CustomModal(
            title: 'Remove Item',
            content: const Text(
              'Are you sure you want to remove this item from your cart?',
              style: TextStyle(fontFamily: 'Helvetica Now Text', fontSize: 16),
            ),
            onClose: () => Navigator.pop(context, false),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
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
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    ).then((confirmed) {
      if (confirmed == true) {
        _removeItem(docId, productId);
      }
      return null;
    });
  }

  // Simplified update quantity method
  Future<void> _updateQuantity(String docId, int currentQty, int change) async {
    final newQty = currentQty + change;

    // If trying to set quantity to 0 or less, show remove confirmation
    if (newQty <= 0) {
      // Prevent multiple confirmation dialogs
      if (_isShowingRemoveModal) return;

      // Find the product ID in the cart items
      final index = _cartItems.indexWhere((doc) => doc.id == docId);
      if (index >= 0) {
        final item = _cartItems[index].data() as Map<String, dynamic>;
        final productId = item['productId'] as String;

        // Set flag to prevent multiple dialogs
        _isShowingRemoveModal = true;

        // Show the confirmation dialog
        _showRemoveConfirmation(docId, currentQty, productId).then((_) {
          // Reset flag when dialog is closed
          _isShowingRemoveModal = false;
        });
      }
      return;
    }

    // Update UI immediately
    setState(() {
      _localQuantities[docId] = newQty;
    });

    // Debounce Firestore update
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        // Find the cart item
        final index = _cartItems.indexWhere((doc) => doc.id == docId);
        if (index < 0) return;

        final item = _cartItems[index].data() as Map<String, dynamic>;
        final productId = item['productId'] as String;
        final varieties = Map<String, String>.from(item['varieties'] ?? {});

        // Fetch product to check available stock
        final productDoc =
            await _firestore.collection('products').doc(productId).get();

        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final productData = productDoc.data() as Map<String, dynamic>;
        int availableQuantity = 0;

        // Check if product has variety types
        if (productData['varietyTypes'] != null) {
          final varietyTypes = List<Map<String, dynamic>>.from(
            productData['varietyTypes'],
          );

          for (var varietyType in varietyTypes) {
            final typeName = varietyType['name'] as String;
            if (!varieties.containsKey(typeName)) continue;

            final selectedValue = varieties[typeName];
            final values = List<Map<String, dynamic>>.from(
              varietyType['values'],
            );

            final matchingValue = values.firstWhere(
              (v) => v['value'] == selectedValue,
              orElse: () => <String, dynamic>{},
            );

            if (matchingValue.isNotEmpty) {
              final qty = matchingValue['quantity'];
              final varQty =
                  qty is String
                      ? int.tryParse(qty) ?? 0
                      : (qty as num?)?.toInt() ?? 0;

              if (availableQuantity == 0 || varQty < availableQuantity) {
                availableQuantity = varQty;
              }
            }
          }
        } else {
          // Simple product without varieties
          final qty = productData['quantity'];
          availableQuantity =
              qty is String
                  ? int.tryParse(qty) ?? 0
                  : (qty as num?)?.toInt() ?? 0;
        }

        // Check if requested quantity exceeds available stock
        if (newQty > availableQuantity) {
          // Instead of reverting, set to maximum available quantity
          setState(() {
            _localQuantities[docId] = availableQuantity;
          });

          // Update Firestore with maximum available quantity
          await _firestore
              .collection('accounts')
              .doc(_auth.currentUser!.uid)
              .collection('cart')
              .doc(docId)
              .update({'quantity': availableQuantity});

          // Notify user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Quantity set to maximum available: $availableQuantity',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        // If we're within stock limits, update Firestore with the requested quantity
        await _firestore
            .collection('accounts')
            .doc(_auth.currentUser!.uid)
            .collection('cart')
            .doc(docId)
            .update({'quantity': newQty});
      } catch (e) {
        // Revert on error
        if (mounted) {
          setState(() {
            _localQuantities.remove(docId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update quantity: $e')),
          );
        }
      }
    });
  }

  // Function to remove item from the cart
  Future<void> _removeItem(String docId, String productId) async {
    await _firestore
        .collection('accounts')
        .doc(_auth.currentUser!.uid)
        .collection('cart')
        .doc(docId)
        .delete();
  }

  Future<void> _removeAll() async {
    final cartRef = _firestore
        .collection('accounts') // Changed from 'users' to 'accounts'
        .doc(_auth.currentUser!.uid)
        .collection('cart');

    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  void _applyCoupon() {
    debugPrint('Applying coupon: ${_couponController.text}');
  }

  void _checkout() {
    debugPrint('Proceeding to checkout');
  }

  double _calculateSubtotal(List<DocumentSnapshot> docs) {
    return docs.fold(0, (total, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return total + (data['price'] * data['quantity']);
    });
  }

  // Calculate the total price of selected items
  double _calculateSelectedTotal(List<DocumentSnapshot> docs) {
    return docs.fold(0, (total, doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (_selectedItems.contains(doc.id)) {
        return total + (data['price'] * data['quantity']);
      }
      return total;
    });
  }

  double _calculateSelectedSubtotal(List<DocumentSnapshot> docs) {
    return docs.fold(0, (total, doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (_selectedItems.contains(doc.id)) {
        return total + (data['price'] * data['quantity']);
      }
      return total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = AppTheme.getResponsivePadding(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= AppTheme.breakpointMobile;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1200),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          padding: responsivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(100),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Center(child: AppIcons.backArrowIcon()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Cart',
                        style: AppTheme.titleStyle.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                  ), // Placeholder to balance the layout
                ],
              ),

              const SizedBox(height: AppTheme.mediumPadding),
              GestureDetector(
                onTap: _removeAll,
                child: Text('Remove All', style: AppTheme.optionLabelStyle),
              ),
              const SizedBox(height: AppTheme.mediumPadding),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _cartItems.isEmpty
                        ? _buildEmptyCart()
                        : ListView.separated(
                          itemCount: _cartItems.length,
                          separatorBuilder:
                              (context, index) =>
                                  const SizedBox(height: AppTheme.smallPadding),
                          itemBuilder: (context, index) {
                            final doc = _cartItems[index];
                            final item = doc.data() as Map<String, dynamic>;
                            final isSelected = _selectedItems.contains(doc.id);

                            // Use local quantity if available
                            final displayQuantity =
                                _localQuantities[doc.id] ?? item['quantity'];

                            return Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedItems.add(doc.id);
                                      } else {
                                        _selectedItems.remove(doc.id);
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: CartItemWidget(
                                    item: CartItem.fromFirestore(doc.id, {
                                      ...item,
                                      'quantity': displayQuantity,
                                    }),
                                    onUpdateQuantity:
                                        (_, change) => _updateQuantity(
                                          doc.id,
                                          displayQuantity,
                                          change,
                                        ),
                                    onDelete: () {
                                      // Show confirmation modal when delete is tapped
                                      if (!_isShowingRemoveModal) {
                                        _isShowingRemoveModal = true;
                                        _showRemoveConfirmation(
                                          doc.id,
                                          displayQuantity,
                                          item['productId'],
                                        ).then((_) {
                                          _isShowingRemoveModal = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
              ),
              const SizedBox(height: AppTheme.mediumPadding),
              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('accounts')
                        .doc(_auth.currentUser!.uid)
                        .collection('cart')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        _buildSummaryRow('Subtotal', '₱0.00'),
                        const SizedBox(height: AppTheme.smallPadding),
                        _buildSummaryRow('Shipping Cost', '₱0.00'),
                        const SizedBox(height: AppTheme.smallPadding),
                        _buildSummaryRow('Tax', '₱0.00'),
                        const SizedBox(height: AppTheme.smallPadding),
                        _buildSummaryRow('Total', '₱0.00', isTotal: true),
                      ],
                    );
                  }
                  final cartDocs = snapshot.data!.docs;
                  final productIds = <String>{};
                  for (var doc in cartDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final productId = data['productId'] as String?;
                    if (productId != null) productIds.add(productId);
                  }
                  if (productIds.isEmpty) {
                    return Column(
                      children: [
                        _buildSummaryRow('Subtotal', '₱0.00'),
                        const SizedBox(height: AppTheme.smallPadding),
                        _buildSummaryRow('Shipping Cost', '₱0.00'),
                        const SizedBox(height: AppTheme.smallPadding),
                        _buildSummaryRow('Tax', '₱0.00'),
                        const SizedBox(height: AppTheme.smallPadding),
                        _buildSummaryRow('Total', '₱0.00', isTotal: true),
                      ],
                    );
                  }
                  return FutureBuilder<QuerySnapshot>(
                    future:
                        _firestore
                            .collection('products')
                            .where(
                              FieldPath.documentId,
                              whereIn: productIds.toList(),
                            )
                            .get(),
                    builder: (context, productSnapshot) {
                      if (!productSnapshot.hasData) {
                        return const SizedBox();
                      }
                      final productUserMap = <String, String>{};
                      for (var doc in productSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        productUserMap[doc.id] =
                            data['userId'] as String? ?? '';
                      }
                      final userIds = productUserMap.values.toSet();
                      if (userIds.isEmpty) {
                        return const SizedBox();
                      }
                      return FutureBuilder<QuerySnapshot>(
                        future:
                            _firestore
                                .collection('accounts')
                                .where(
                                  FieldPath.documentId,
                                  whereIn: userIds.toList(),
                                )
                                .get(),
                        builder: (context, sellerSnapshot) {
                          if (!sellerSnapshot.hasData) {
                            return const SizedBox();
                          }
                          final bannedMap = <String, bool>{};
                          for (var doc in sellerSnapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            bannedMap[doc.id] = data['isBanned'] == true;
                          }
                          final visibleCartDocs = _filterVisibleCartDocs(
                            cartDocs,
                            productUserMap,
                            bannedMap,
                          );

                          final subtotal = _calculateSubtotal(visibleCartDocs);
                          const double shipping = 50.0; // Fixed shipping fee
                          const double taxRate = 0.08;
                          final tax = subtotal * taxRate;
                          final total = subtotal + shipping + tax;

                          return Column(
                            children: [
                              _buildSummaryRow(
                                'Subtotal',
                                '₱${subtotal.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: AppTheme.smallPadding),
                              _buildSummaryRow(
                                'Shipping Cost',
                                '₱${shipping.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: AppTheme.smallPadding),
                              _buildSummaryRow(
                                'Tax',
                                '₱${tax.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: AppTheme.smallPadding),
                              _buildSummaryRow(
                                'Total',
                                '₱${total.toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppTheme.mediumPadding),
              StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('accounts')
                        .doc(_auth.currentUser!.uid)
                        .collection('cart')
                        .snapshots(),
                builder: (context, snapshot) {
                  final selectedTotal =
                      snapshot.hasData
                          ? _calculateSelectedSubtotal(snapshot.data!.docs)
                          : 0.0;

                  // Calculate tax (8% of the selected total)
                  const double taxRate = 0.08;
                  final tax = selectedTotal * taxRate;

                  // Add shipping cost
                  const double shipping = 50.0;

                  // Add tax and shipping to the selected total
                  final totalWithTaxAndShipping =
                      selectedTotal + tax + shipping;

                  return Column(
                    children: [
                      _buildSummaryRow(
                        'Selected Total',
                        '₱${totalWithTaxAndShipping.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.mediumPadding),
              _buildCouponInput(),
              const SizedBox(height: AppTheme.mediumPadding),
              _buildCheckoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppTheme.secondaryText,
          ),
          const SizedBox(height: AppTheme.mediumPadding),
          Text(
            'Your cart is empty',
            style: AppTheme.descriptionStyle.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.optionLabelStyle.copyWith(
            color: isTotal ? AppTheme.textPrimary : AppTheme.secondaryText,
          ),
        ),
        Text(
          value,
          style: isTotal ? AppTheme.titleStyle : AppTheme.optionValueStyle,
        ),
      ],
    );
  }

  Widget _buildCouponInput() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.tinyPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        children: [
          AppIcons.discountIcon(),
          const SizedBox(width: AppTheme.mediumPadding),
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: InputDecoration(
                hintText: 'Enter Coupon Code',
                hintStyle: AppTheme.descriptionStyle.copyWith(fontSize: 12),
                border: InputBorder.none,
              ),
              style: AppTheme.descriptionStyle.copyWith(fontSize: 12),
            ),
          ),
          Material(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: _applyCoupon,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 40,
                height: 40,
                child: Center(child: AppIcons.forwardArrowIcon()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _selectedItems.isEmpty
                ? null
                : () async {
                    try {
                      // Fetch selected items from the cart
                      final selectedItems = await Future.wait(
                        _selectedItems.map((cartId) async {
                          final doc = await _firestore
                              .collection('accounts')
                              .doc(_auth.currentUser!.uid)
                              .collection('cart')
                              .doc(cartId)
                              .get();
                          final data = doc.data();
                          if (data != null) {
                            data['id'] = cartId;
                          }
                          return data;
                        }),
                      );

                      debugPrint('Selected items for checkout: $selectedItems');

                      final validItems = selectedItems.whereType<Map<String, dynamic>>().toList();
                      if (validItems.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No valid items selected for checkout.')),
                          );
                        }
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            selectedItems: validItems,
                          ),
                        ),
                      );
                    } catch (e, stack) {
                      debugPrint('Checkout error: $e\n$stack');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Checkout failed: $e')),
                        );
                      }
                    }
                  },
        style: AppTheme.primaryButtonStyle,
        child: Text('Checkout', style: AppTheme.buttonTextStyle),
      ),
    );
  }

  // Helper to filter out cart docs from banned users
  List<DocumentSnapshot> _filterVisibleCartDocs(
    List<DocumentSnapshot> cartDocs,
    Map<String, String> productUserMap,
    Map<String, bool> bannedMap,
  ) {
    return cartDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final productId = data['productId'] as String?;
      final userId = productUserMap[productId];
      if (userId == null) return false;
      return bannedMap.containsKey(userId) && bannedMap[userId] != true;
    }).toList();
  }
}
