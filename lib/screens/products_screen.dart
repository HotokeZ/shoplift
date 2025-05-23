import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_card.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductsScreen extends StatefulWidget {
  final bool isNewIn;
  final bool isTopSelling;
  final String? selectedCategory;

  const ProductsScreen({
    super.key,
    this.isNewIn = false,
    this.isTopSelling = false,
    this.selectedCategory,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryRed,
        leading: IconButton(
          icon: SvgPicture.string(
            '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M7.46004 5.29336L5.71337 7.04003C5.20004 7.55336 5.20004 8.39336 5.71337 8.90669L10.06 13.2534M10.06 2.69336L9.3667 3.38669"
              stroke="#FFFFFF" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>''',
            width: 16,
            height: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.selectedCategory ??
              (widget.isTopSelling
                  ? 'Top Selling'
                  : widget.isNewIn
                  ? 'New In'
                  : 'All Products'),
          style: const TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 800),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.fromLTRB(19, 10, 11, 11),
                  child: Row(
                    children: [
                      SvgPicture.string(
                        '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                          <g clip-path="url(#clip0_7_593)">
                            <path d="M7.66671 1.33337C11.1667 1.33337 14 4.16671 14 7.66671C14 11.1667 11.1667 14 7.66671 14C4.16671 14 1.33337 11.1667 1.33337 7.66671C1.33337 5.20004 2.74004 3.06671 4.80004 2.02004M14.6667 14.6667L13.3334 13.3334"
                          stroke="#272727" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                          </g>
                        </svg>''',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: Color(0xFF272727),
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF272727),
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: SvgPicture.string(
                            '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                              <path d="M12 4L4 12M4 4L12 12" stroke="#272727" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>''',
                            width: 16,
                            height: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          tooltip: 'Clear search',
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Products Grid
              Expanded(
                child:
                    widget.isTopSelling
                        ? _buildTopSellingProducts()
                        : _buildRegularProducts(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildTopSellingProducts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data?.docs ?? [];
        Map<String, int> productCounts = {};

        // Count product occurrences
        for (var order in orders) {
          List<dynamic> items =
              (order.data() as Map<String, dynamic>)['items'] ?? [];
          for (var item in items) {
            String productId = item['productId'];
            int quantity = item['quantity'];
            productCounts[productId] =
                (productCounts[productId] ?? 0) + quantity;
          }
        }

        // Get top selling product IDs
        var sortedProducts =
            productCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        List<String> topProductIds = sortedProducts.map((e) => e.key).toList();

        if (topProductIds.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        // Get product details
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('products')
                  .where(FieldPath.documentId, whereIn: topProductIds)
                  .snapshots(),
          builder: (context, productsSnapshot) {
            if (productsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = productsSnapshot.data?.docs ?? [];

            // Gather all unique userIds
            final userIds = <String>{};
            for (var product in products) {
              final data = product.data() as Map<String, dynamic>;
              final userId = data['userId'] as String?;
              if (userId != null) userIds.add(userId);
            }

            if (userIds.isEmpty) {
              return const Center(child: Text('No products found'));
            }

            // Fetch ban status for these users
            return FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('accounts')
                      .where(FieldPath.documentId, whereIn: userIds.toList())
                      .get(),
              builder: (context, sellerSnapshot) {
                if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!sellerSnapshot.hasData) {
                  return const Center(child: Text('No products found'));
                }

                // Map userId -> isBanned
                final bannedMap = <String, bool>{};
                for (var doc in sellerSnapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  bannedMap[doc.id] = data['isBanned'] == true;
                }

                // Filter products whose user is not banned
                final visibleProducts =
                    products.where((product) {
                      final data = product.data() as Map<String, dynamic>;
                      final userId = data['userId'] as String?;
                      if (userId == null) return false;
                      return bannedMap.containsKey(userId) &&
                          bannedMap[userId] != true;
                    }).toList();

                // Sort products according to their order count
                visibleProducts.sort((a, b) {
                  int aCount = productCounts[a.id] ?? 0;
                  int bCount = productCounts[b.id] ?? 0;
                  return bCount.compareTo(aCount);
                });

                // Filter products based on search query
                final filteredProducts =
                    visibleProducts.where((product) {
                      final data = product.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] as String? ?? '').toLowerCase();
                      final categories =
                          (data['categories'] as List<dynamic>? ?? [])
                              .map(
                                (category) => category.toString().toLowerCase(),
                              )
                              .toList();

                      return name.contains(_searchQuery) ||
                          categories.any(
                            (category) => category.contains(_searchQuery),
                          );
                    }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('No matching products found.'),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot product = filteredProducts[index];
                    Map<String, dynamic> data =
                        product.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                      child: ProductCard(
                        title: data['name'] ?? 'Unnamed Product',
                        price: (data['price'] ?? 0.0).toDouble(),
                        imageUrl:
                            data['images']?[0] ??
                            'https://via.placeholder.com/150',
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRegularProducts() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          widget.selectedCategory != null
              ? FirebaseFirestore.instance
                  .collection('products')
                  .where('categories', arrayContains: widget.selectedCategory)
                  .snapshots()
              : widget.isNewIn
              ? FirebaseFirestore.instance
                  .collection('products')
                  .where(
                    'createdAt',
                    isGreaterThanOrEqualTo: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                  )
                  .orderBy('createdAt', descending: true)
                  .snapshots()
              : FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products available.'));
        }

        final allProducts = snapshot.data!.docs;

        // Gather all unique userIds
        final userIds = <String>{};
        for (var product in allProducts) {
          final data = product.data() as Map<String, dynamic>;
          final userId = data['userId'] as String?;
          if (userId != null) userIds.add(userId);
        }

        if (userIds.isEmpty) {
          return const Center(child: Text('No products available.'));
        }

        // Fetch ban status for these users
        return FutureBuilder<QuerySnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('accounts')
                  .where(FieldPath.documentId, whereIn: userIds.toList())
                  .get(),
          builder: (context, sellerSnapshot) {
            if (sellerSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!sellerSnapshot.hasData) {
              return const Center(child: Text('No products available.'));
            }

            // Map userId -> isBanned
            final bannedMap = <String, bool>{};
            for (var doc in sellerSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              bannedMap[doc.id] = data['isBanned'] == true;
            }

            // Filter products whose user is not banned
            final visibleProducts =
                allProducts.where((product) {
                  final data = product.data() as Map<String, dynamic>;
                  final userId = data['userId'] as String?;
                  if (userId == null) return false;
                  return bannedMap.containsKey(userId) &&
                      bannedMap[userId] != true;
                }).toList();

            // Filter products based on search query
            final filteredProducts =
                visibleProducts.where((product) {
                  final data = product.data() as Map<String, dynamic>;
                  final name = (data['name'] as String? ?? '').toLowerCase();
                  final categories =
                      (data['categories'] as List<dynamic>? ?? [])
                          .map((category) => category.toString().toLowerCase())
                          .toList();

                  return name.contains(_searchQuery) ||
                      categories.any(
                        (category) => category.contains(_searchQuery),
                      );
                }).toList();

            if (filteredProducts.isEmpty) {
              return const Center(child: Text('No matching products found.'));
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final data = product.data() as Map<String, dynamic>;
                final imageUrl =
                    (data['images'] != null &&
                            (data['images'] as List<dynamic>).isNotEmpty)
                        ? (data['images'] as List<dynamic>)[0]
                        : 'https://via.placeholder.com/150';
                final name = data['name'] ?? 'Unnamed Product';
                final price = data['price'] ?? 0.0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  child: ProductCard(
                    title: name,
                    price: price,
                    imageUrl: imageUrl,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
