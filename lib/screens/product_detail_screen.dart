import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import '../widgets/product_detail/product_image_gallery.dart';
import '../widgets/product_detail/product_option_selector.dart';
import '../widgets/product_detail/add_to_bag_button.dart';
import '../widgets/size_modal.dart';
import '../widgets/banned_product_overlay.dart'; // Import the BannedProductOverlay

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  Map<String, String> selectedVarieties =
      {}; // To hold selected varieties for each type
  double selectedPrice =
      0.0; // To hold the highest price among selected varieties
  Map<String, dynamic>? productData;
  bool isLoading = true;
  int availableQuantity = 0;
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _checkWishlistStatus();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Check if the seller is banned
        if (data['bannedSeller'] == true) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BannedProductOverlay(),
              ),
            );
          }
          return;
        }

        setState(() {
          productData = data;
          isLoading = false;

          // Set default price if no varieties exist
          selectedPrice = productData?['price'] ?? 0.0;

          // Initialize default selections for each variety type
          if (productData?['varietyTypes'] != null &&
              (productData!['varietyTypes'] as List).isNotEmpty) {
            final varietyTypes = List<Map<String, dynamic>>.from(
              productData!['varietyTypes'],
            );
            for (var type in varietyTypes) {
              if (type['values'] != null &&
                  (type['values'] as List).isNotEmpty) {
                final defaultVariety = type['values'][0];
                selectedVarieties[type['name']] = defaultVariety['value'] ?? '';

                // Handle price conversion and use default price if empty
                final defaultPrice =
                    defaultVariety['price'] is String
                        ? (defaultVariety['price'].isEmpty
                            ? productData!['price'] ?? 0.0
                            : double.tryParse(defaultVariety['price']) ?? 0.0)
                        : defaultVariety['price'] ??
                            productData!['price'] ??
                            0.0;

                selectedPrice =
                    defaultPrice > selectedPrice ? defaultPrice : selectedPrice;

                // Handle quantity conversion
                availableQuantity =
                    defaultVariety['quantity'] is String
                        ? int.tryParse(defaultVariety['quantity']) ?? 0
                        : defaultVariety['quantity'] ?? 0;
              }
            }
          } else {
            // No varieties, set available quantity to a default value
            availableQuantity = productData?['quantity'] ?? 0;
          }
        });
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BannedProductOverlay(),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product details: $e')),
      );
    }
  }

  Future<void> _checkWishlistStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('accounts')
              .doc(user.uid)
              .collection('wishlist')
              .doc(widget.productId)
              .get();

      setState(() {
        isInWishlist = docSnapshot.exists;
      });
    }
  }

  void _selectVariety(String type, Map<String, dynamic> variety) {
    setState(() {
      // Update the selected variety for the given type
      selectedVarieties[type] = variety['value'] ?? '';

      // Recalculate the highest price based on all selected varieties
      double highestPrice =
          productData!['price'] ?? 0.0; // Start with the default price
      for (var entry in selectedVarieties.entries) {
        final varietyType = productData!['varietyTypes'].firstWhere(
          (type) => type['name'] == entry.key,
          orElse: () => null,
        );
        if (varietyType != null) {
          final selectedVariety = (varietyType['values'] as List).firstWhere(
            (v) => v['value'] == entry.value,
            orElse: () => null,
          );
          if (selectedVariety != null) {
            final varietyPrice =
                selectedVariety['price'] is String
                    ? (selectedVariety['price'].isEmpty
                        ? productData!['price'] ?? 0.0
                        : double.tryParse(selectedVariety['price']) ?? 0.0)
                    : selectedVariety['price'] ?? productData!['price'] ?? 0.0;
            if (varietyPrice > highestPrice) {
              highestPrice = varietyPrice; // Update the highest price
            }
          }
        }
      }

      selectedPrice = highestPrice;

      // Update the available quantity for the selected variety
      availableQuantity =
          variety['quantity'] is String
              ? int.tryParse(variety['quantity']) ?? 0
              : variety['quantity'] ?? 0;

      quantity = 1; // Reset quantity when variety changes
    });
  }

  void _increaseQuantity() {
    if (quantity < availableQuantity) {
      setState(() {
        quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Cannot exceed available quantity ($availableQuantity)",
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _addToCart() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final cartRef = FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .collection('cart');

      // Check if the product with the same varieties already exists in the cart
      final querySnapshot =
          await cartRef
              .where('productId', isEqualTo: widget.productId)
              .where('varieties', isEqualTo: selectedVarieties)
              .get();

      int totalCartQuantity = 0;

      // Calculate the total quantity of the product in the cart
      for (var doc in querySnapshot.docs) {
        totalCartQuantity += doc['quantity'] as int;
      }

      // Check if adding the selected quantity exceeds the available quantity
      if (totalCartQuantity + quantity > availableQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Cannot add to cart. Total quantity exceeds available stock ($availableQuantity).",
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
        return;
      }

      if (querySnapshot.docs.isNotEmpty) {
        // If the product with the same varieties exists, update the quantity
        final cartItemDoc = querySnapshot.docs.first;
        final currentQuantity = cartItemDoc['quantity'] as int;
        final newQuantity = currentQuantity + quantity;

        await cartItemDoc.reference.update({'quantity': newQuantity});
      } else {
        // If the product with the same varieties doesn't exist, add it as a new item
        final cartItem = {
          'productId': widget.productId,
          'name': productData!['name'],
          'price': selectedPrice, // Use the highest selected price
          'quantity': quantity,
          'varieties': selectedVarieties,
          'image':
              productData!['images'].isNotEmpty
                  ? productData!['images'][0]
                  : null,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await cartRef.add(cartItem);
      }

      debugPrint('Product added to user cart successfully!');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to cart successfully!'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    } catch (e) {
      debugPrint('Failed to add product to cart: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
    }
  }

  Future<void> _toggleWishlist() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save items'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
        return;
      }

      final wishlistRef = FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .collection('wishlist')
          .doc(widget.productId);

      setState(() {
        isInWishlist = !isInWishlist; // Update state immediately for better UX
      });

      if (!isInWishlist) {
        // Remove from wishlist
        await wishlistRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      } else {
        // Add to wishlist
        await wishlistRef.set({
          'productId': widget.productId,
          'name': productData!['name'],
          'price': productData!['price'],
          'image': productData!['images'][0],
          'addedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to wishlist'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } catch (e) {
      // Revert state if operation fails
      setState(() {
        isInWishlist = !isInWishlist;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (productData == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    final List<String> imageUrls = List<String>.from(
      productData!['images'] ?? [],
    );
    final String name = productData!['name'] ?? 'Unnamed Product';
    final String description =
        productData!['description'] ?? 'No description available.';
    final List<Map<String, dynamic>> varietyTypes =
        List<Map<String, dynamic>>.from(productData?['varietyTypes'] ?? []);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: AppTheme.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 80,
                        bottom: AppTheme.mediumPadding,
                      ),
                      child: _buildProductImageGallery(imageUrls),
                    ),
                    _buildProductTitle(name),
                    _buildProductOptions(varietyTypes),
                    _buildProductDescription(description),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            AddToBagButton(
              price:
                  '₱${(selectedPrice * quantity).toStringAsFixed(2)}', // Reflect the highest selected price
              onTap: _addToCart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallPadding),
      margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
            icon: Icons.arrow_back, // Use a Material icon
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: AppTheme.lightGray,
            iconColor: AppTheme.darkText,
          ),
          CircularIconButton(
            icon: isInWishlist ? Icons.favorite : Icons.favorite_border,
            onPressed: _toggleWishlist,
            backgroundColor: AppTheme.lightGray,
            iconColor: AppTheme.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildProductTitle(String name) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppTheme.mediumPadding,
        bottom: AppTheme.smallPadding,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallPadding),
      child: Text(name, style: AppTheme.titleStyle),
    );
  }

  Widget _buildProductOptions(List<Map<String, dynamic>> varietyTypes) {
    if (varietyTypes.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
        child: Text(
          'Price: ₱${selectedPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
      child: Column(
        children:
            varietyTypes.map((type) {
              final List<Map<String, dynamic>> values =
                  List<Map<String, dynamic>>.from(type['values'] ?? []);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        values.map((variety) {
                          final isSelected =
                              selectedVarieties[type['name']] ==
                              variety['value'];
                          return ChoiceChip(
                            label: Text(variety['value']),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _selectVariety(type['name'], variety);
                              }
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: AppTheme.mediumPadding),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildProductDescription(String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.mediumPadding),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.smallPadding),
          Text(description, style: AppTheme.descriptionStyle),
        ],
      ),
    );
  }

  Widget _buildProductImageGallery(List<String> imageUrls) {
    PageController _pageController = PageController();
    int _currentPage = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showImageDialog(context, imageUrls, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 10 : 6,
                  height: _currentPage == index ? 10 : 6,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? AppTheme.primaryRed
                            : AppTheme.lightGray,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  void _showImageDialog(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    final pageController = PageController(initialPage: initialIndex);
    final currentDialogIndex = ValueNotifier<int>(initialIndex);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss image viewer',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: imageUrls.length,
                pageController: pageController,
                onPageChanged: (index) => currentDialogIndex.value = index,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(imageUrls[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<int>(
                  valueListenable: currentDialogIndex,
                  builder: (context, index, _) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${index + 1} / ${imageUrls.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
