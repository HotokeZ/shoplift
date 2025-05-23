import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_card.dart';
import '../utils/app_icons.dart';
import '../screens/product_detail_screen.dart';

class ItemSearchScreen extends StatefulWidget {
  final String searchQuery;
  final String sortBy;

  const ItemSearchScreen({
    Key? key,
    required this.searchQuery,
    required this.sortBy,
  }) : super(key: key);

  @override
  State<ItemSearchScreen> createState() => _ItemSearchScreenState();
}

class _ItemSearchScreenState extends State<ItemSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  bool _isPriceSortActive = false;
  bool _isPriceDescending = true;

  String _selectedSort = 'Latest';
  Map<String, int> _productOrderCounts = {};

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _currentSearchQuery = widget.searchQuery;
    _fetchOrderCounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _currentSearchQuery = query.trim();
    });
  }

  Future<void> _fetchOrderCounts() async {
    final orderDocs =
        await FirebaseFirestore.instance.collection('orders').get();
    final counts = <String, int>{};

    for (var order in orderDocs.docs) {
      final items = (order.data()['items'] as List<dynamic>?) ?? [];
      for (var item in items) {
        final productId = item['productId'] as String?;
        final quantity = item['quantity'] as int?;
        if (productId != null && quantity != null) {
          counts[productId] = (counts[productId] ?? 0) + quantity;
        }
      }
    }

    setState(() {
      _productOrderCounts = counts;
    });
  }

  // Update the _sortProducts method signature and return type
  List<QueryDocumentSnapshot> _sortProducts(
    List<QueryDocumentSnapshot> products,
  ) {
    switch (_selectedSort) {
      case 'Price: High to Low':
        products.sort((a, b) {
          final priceA = (a.data() as Map<String, dynamic>)['price'] ?? 0.0;
          final priceB = (b.data() as Map<String, dynamic>)['price'] ?? 0.0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'Price: Low to High':
        products.sort((a, b) {
          final priceA = (a.data() as Map<String, dynamic>)['price'] ?? 0.0;
          final priceB = (b.data() as Map<String, dynamic>)['price'] ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Most Sold':
        products.sort((a, b) {
          final countA = _productOrderCounts[a.id] ?? 0;
          final countB = _productOrderCounts[b.id] ?? 0;
          return countB.compareTo(countA);
        });
        break;
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 991 ? 40 : 24,
            vertical: MediaQuery.of(context).size.width > 991 ? 66 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar with Back Arrow
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AppIcons.backArrowIcon(
                      color: const Color(0xFF272727),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          AppIcons.searchIcon(
                            color: const Color(0xFF272727),
                            size: 16,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted:
                                  _handleSearch, // Only search on submit
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                isDense: true,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF272727),
                                  fontFamily: 'Circular Std',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF272727),
                                fontFamily: 'Circular Std',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController
                                      .clear(); // Only clear the text field
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFF272727),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Filter Tags
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort by:',
                    style: const TextStyle(
                      color: Color(0xFF272727),
                      fontFamily: 'Circular Std',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      underline: Container(),
                      icon: AppIcons.arrowDownIcon(
                        color: const Color(0xFF272727),
                        size: 12,
                      ),
                      items:
                          [
                            'Latest',
                            'Price: High to Low',
                            'Price: Low to High',
                            'Most Sold',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Color(0xFF272727),
                                  fontFamily: 'Circular Std',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSort = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Results Count
              const SizedBox(height: 17),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      'Searching...',
                      style: TextStyle(
                        color: Color(0xFF272727),
                        fontFamily: 'Circular Std',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(
                      '0 Results Found',
                      style: TextStyle(
                        color: Color(0xFF272727),
                        fontFamily: 'Circular Std',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    );
                  }

                  // Filter by search query
                  final filteredProducts = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    final categories = (data['categories'] as List<dynamic>?)
                            ?.map((e) => e.toString().toLowerCase())
                            .toList() ??
                        [];
                    final searchQuery = _currentSearchQuery.toLowerCase();
                    return name.contains(searchQuery) ||
                        categories.any((category) => category.contains(searchQuery));
                  }).toList();

                  // Gather all unique userIds
                  final userIds = <String>{};
                  for (var product in filteredProducts) {
                    final data = product.data() as Map<String, dynamic>;
                    final userId = data['userId'] as String?;
                    if (userId != null) userIds.add(userId);
                  }

                  if (userIds.isEmpty) {
                    return const Text(
                      '0 Results Found',
                      style: TextStyle(
                        color: Color(0xFF272727),
                        fontFamily: 'Circular Std',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    );
                  }

                  // Fetch ban status for these users
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('accounts')
                        .where(FieldPath.documentId, whereIn: userIds.toList())
                        .get(),
                    builder: (context, sellerSnapshot) {
                      if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Searching...',
                          style: TextStyle(
                            color: Color(0xFF272727),
                            fontFamily: 'Circular Std',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        );
                      }

                      if (!sellerSnapshot.hasData) {
                        return const Text(
                          '0 Results Found',
                          style: TextStyle(
                            color: Color(0xFF272727),
                            fontFamily: 'Circular Std',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        );
                      }

                      // Map userId -> isBanned
                      final bannedMap = <String, bool>{};
                      for (var doc in sellerSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        bannedMap[doc.id] = data['isBanned'] == true;
                      }

                      // Filter products whose user is not banned
                      final visibleProducts = filteredProducts.where((product) {
                        final data = product.data() as Map<String, dynamic>;
                        final userId = data['userId'] as String?;
                        if (userId == null) return false;
                        return bannedMap.containsKey(userId) && bannedMap[userId] != true;
                      }).toList();

                      return Text(
                        '${visibleProducts.length} Results Found',
                        style: const TextStyle(
                          color: Color(0xFF272727),
                          fontFamily: 'Circular Std',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      );
                    },
                  );
                },
              ),

              // Product Grid
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('products')
                          .orderBy(
                            _isPriceSortActive ? 'price' : 'name',
                            descending:
                                _isPriceSortActive ? _isPriceDescending : false,
                          )
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }

                    var products =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                              (data['name'] as String? ?? '').toLowerCase();
                          final categories =
                              (data['categories'] as List<dynamic>?)
                                  ?.map((e) => e.toString().toLowerCase())
                                  .toList() ??
                              [];
                          final searchQuery = _currentSearchQuery.toLowerCase();
                          return name.contains(searchQuery) ||
                              categories.any(
                                (category) => category.contains(searchQuery),
                              );
                        }).toList();

                    // Gather all unique userIds
                    final userIds = <String>{};
                    for (var product in products) {
                      final data = product.data() as Map<String, dynamic>;
                      final userId = data['userId'] as String?;
                      if (userId != null) userIds.add(userId);
                    }

                    if (userIds.isEmpty) {
                      return const Center(
                        child: Text('No matching products found.'),
                      );
                    }

                    // Fetch ban status for these users
                    return FutureBuilder<QuerySnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('accounts')
                              .where(
                                FieldPath.documentId,
                                whereIn: userIds.toList(),
                              )
                              .get(),
                      builder: (context, sellerSnapshot) {
                        if (sellerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!sellerSnapshot.hasData) {
                          return const Center(
                            child: Text('No matching products found.'),
                          );
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
                              final data =
                                  product.data() as Map<String, dynamic>;
                              final userId = data['userId'] as String?;
                              if (userId == null) return false;
                              return bannedMap.containsKey(userId) &&
                                  bannedMap[userId] != true;
                            }).toList();

                        // Apply sorting with correct type
                        final sortedProducts = _sortProducts(
                          visibleProducts as List<QueryDocumentSnapshot>,
                        );

                        if (sortedProducts.isEmpty) {
                          return const Center(
                            child: Text('No matching products found.'),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 1200
                                        ? 6 // Extra large screens
                                        : MediaQuery.of(context).size.width >
                                            991
                                        ? 4 // Desktop/Large tablets
                                        : MediaQuery.of(context).size.width >
                                            640
                                        ? 3 // Tablets
                                        : 2, // Mobile
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: sortedProducts.length,
                          itemBuilder: (context, index) {
                            final product = sortedProducts[index];
                            final data = product.data() as Map<String, dynamic>;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductDetailScreen(
                                          productId: product.id,
                                        ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSortField() {
    switch (widget.sortBy) {
      case 'Price: Low to High':
      case 'Price: High to Low':
        return 'price';
      case 'Latest':
        return 'createdAt';
      default:
        return 'createdAt';
    }
  }

  bool _getSortDirection() {
    switch (widget.sortBy) {
      case 'Price: Low to High':
        return true;
      case 'Price: High to Low':
        return false;
      case 'Latest':
        return false;
      default:
        return false;
    }
  }

  Widget _buildFilterTag({
    required String text,
    required bool isActive,
    Widget? customIcon, // Add a parameter for a custom icon
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFA3636) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customIcon != null) ...[
            customIcon, // Use the custom icon if provided
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF272727),
              fontFamily: 'Circular Std',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
