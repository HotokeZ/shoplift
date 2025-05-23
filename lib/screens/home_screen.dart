import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_icons.dart';
import '../screens/categories_screen.dart';
import '../screens/cart_screen.dart';
import 'search_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/products_screen.dart';
import '../screens/product_detail_screen.dart'; // Ensure this import is present
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import '../screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import '../widgets/category_bubble.dart';
import '../theme/app_theme.dart'; // Import AppTheme for colors

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildCategories(),
                    const SizedBox(height: 24),
                    _buildTopSelling(),
                    const SizedBox(height: 24),
                    _buildNewIn(),
                    const SizedBox(height: 24),
                    _buildAllProducts(), // Add All Products section
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 0, // Index for HomeScreen
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // User is logged in, navigate to ProfileScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else {
              // No user is logged in, navigate to SignInScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            }
          },
          child: FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('accounts')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                );
              }

              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final avatarUrl = userData['avatarUrl'] as String?;

                if (avatarUrl != null && avatarUrl.isNotEmpty) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl),
                  );
                }
              }

              // Default profile icon if no avatar is available
              return const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.grey,
                child: Icon(Icons.person, color: Colors.white),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // User is logged in, navigate to CartScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            } else {
              // No user is logged in, navigate to SignInScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: SvgPicture.string(
                AppIcons.cart,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: SizedBox(
        height: 40,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              SvgPicture.string(AppIcons.search),
              const SizedBox(width: 12),
              Text('Search', style: AppStyles.searchText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    String selectedCategory = ''; // Track the selected category

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Categories', style: AppStyles.sectionTitle),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
              child: Text('See All', style: AppStyles.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No categories available.'));
            }

            // Extract unique categories from the array fields in products
            final products = snapshot.data!.docs;
            final categories = <String>{};
            for (var product in products) {
              final data = product.data() as Map<String, dynamic>;
              final productCategories = data['categories'] as List<dynamic>?;

              if (productCategories != null) {
                for (var category in productCategories) {
                  if (categories.length < 5) {
                    categories.add(category.toString());
                  }
                }
              }
            }

            if (categories.isEmpty) {
              return const Center(child: Text('No categories available.'));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductsScreen(
                                      selectedCategory: category,
                                    ), // Pass the selected category
                              ),
                            );
                          },
                          child: CategoryBubble(
                            label: category,
                            isActive: selectedCategory == category,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopSelling() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Top Selling', style: AppStyles.sectionTitle),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const ProductsScreen(
                          isTopSelling: true, // Set this flag to true
                        ),
                  ),
                );
              },
              child: Text('See All', style: AppStyles.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No top-selling products available.'),
              );
            }

            // Aggregate product order counts
            final orderDocs = snapshot.data!.docs;
            final productOrderCounts = <String, int>{};

            for (var order in orderDocs) {
              final data = order.data() as Map<String, dynamic>;
              final items = data['items'] as List<dynamic>?;

              if (items != null) {
                for (var item in items) {
                  final productId = item['productId'] as String?;
                  final quantity = item['quantity'] as int?;

                  if (productId != null && quantity != null) {
                    productOrderCounts[productId] =
                        (productOrderCounts[productId] ?? 0) + quantity;
                  }
                }
              }
            }

            // Sort products by order count
            final sortedProductIds =
                productOrderCounts.keys.toList()..sort(
                  (a, b) =>
                      productOrderCounts[b]!.compareTo(productOrderCounts[a]!),
                );

            if (sortedProductIds.isEmpty) {
              return const Center(
                child: Text('No top-selling products available.'),
              );
            }

            // Fetch product details for the top-selling products
            return FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('products')
                      .where(
                        FieldPath.documentId,
                        whereIn: sortedProductIds.take(5).toList(),
                      )
                      .get(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!productSnapshot.hasData ||
                    productSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No top-selling products available.'),
                  );
                }

                final products = productSnapshot.data!.docs;

                // Gather all unique userIds from these products
                final userIds = <String>{};
                for (var product in products) {
                  final data = product.data() as Map<String, dynamic>;
                  final userId = data['userId'] as String?;
                  if (userId != null) userIds.add(userId);
                }

                if (userIds.isEmpty) {
                  return const Center(
                    child: Text('No top-selling products available.'),
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!sellerSnapshot.hasData) {
                      return const Center(
                        child: Text('No top-selling products available.'),
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
                          final data = product.data() as Map<String, dynamic>;
                          final userId = data['userId'] as String?;
                          if (userId == null) return true;
                          return bannedMap[userId] != true;
                        }).toList();

                    if (visibleProducts.isEmpty) {
                      return const Center(
                        child: Text('No top-selling products available.'),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            visibleProducts.map((product) {
                              final data =
                                  product.data() as Map<String, dynamic>;
                              final imageUrl =
                                  (data['images'] != null &&
                                          (data['images'] as List<dynamic>)
                                              .isNotEmpty)
                                      ? (data['images'] as List<dynamic>)[0]
                                      : 'https://via.placeholder.com/150';
                              final name = data['name'] ?? 'Unnamed Product';
                              final price = data['price'] ?? 0.0;

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
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
                                    title: name,
                                    price: price,
                                    imageUrl: imageUrl,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNewIn() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('New In', style: AppStyles.sectionTitle),
            GestureDetector(
              onTap: () {
                // Navigate to ProductsScreen to display products created within the month
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductsScreen(
                          isNewIn:
                              true, // Pass a flag to indicate "New In" products
                        ),
                  ),
                );
              },
              child: Text('See All', style: AppStyles.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('products')
                  .where(
                    'createdAt',
                    isGreaterThanOrEqualTo: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                  )
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No new products available.'));
            }

            final products = snapshot.data!.docs;

            // Gather all unique userIds
            final userIds = <String>{};
            for (var product in products) {
              final data = product.data() as Map<String, dynamic>;
              final userId = data['userId'] as String?;
              if (userId != null) userIds.add(userId);
            }

            if (userIds.isEmpty) {
              return const Center(child: Text('No new products available.'));
            }

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
                  return const Center(
                    child: Text('No new products available.'),
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
                      final data = product.data() as Map<String, dynamic>;
                      final userId = data['userId'] as String?;
                      if (userId == null) return true;
                      return bannedMap[userId] != true;
                    }).toList();

                if (visibleProducts.isEmpty) {
                  return const Center(
                    child: Text('No new products available.'),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        visibleProducts.map((product) {
                          final data = product.data() as Map<String, dynamic>;
                          final imageUrl =
                              (data['images'] != null &&
                                      (data['images'] as List<dynamic>)
                                          .isNotEmpty)
                                  ? (data['images'] as List<dynamic>)[0]
                                  : 'https://via.placeholder.com/150'; // Placeholder if no image
                          final name = data['name'] ?? 'Unnamed Product';
                          final price = data['price'] ?? 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductDetailScreen(
                                          productId:
                                              product.id, // Pass the product ID
                                        ),
                                  ),
                                );
                              },
                              child: ProductCard(
                                title: name,
                                price: price,
                                imageUrl: imageUrl,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAllProducts() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Products', style: AppStyles.sectionTitle),
            GestureDetector(
              onTap: () {
                // Navigate to ProductsScreen to display all products
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductsScreen(),
                  ),
                );
              },
              child: Text('See All', style: AppStyles.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No products available.'));
            }

            final products = snapshot.data!.docs;

            // Gather all unique userIds (not sellerIds!)
            final userIds = <String>{};
            for (var product in products) {
              final data = product.data() as Map<String, dynamic>;
              final userId = data['userId'] as String?;
              if (userId != null) userIds.add(userId);
            }

            if (userIds.isEmpty) {
              return const Center(child: Text('No products available.'));
            }

            // Use a FutureBuilder to fetch all sellers' ban status in one go
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
                    products.where((product) {
                      final data = product.data() as Map<String, dynamic>;
                      final userId = data['userId'] as String?;
                      if (userId == null) return true; // Show if no userId
                      return bannedMap[userId] != true;
                    }).toList();

                if (visibleProducts.isEmpty) {
                  return const Center(child: Text('No products available.'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        visibleProducts.map((product) {
                          final data = product.data() as Map<String, dynamic>;
                          final imageUrl =
                              (data['images'] != null &&
                                      (data['images'] as List<dynamic>)
                                          .isNotEmpty)
                                  ? (data['images'] as List<dynamic>)[0]
                                  : 'https://via.placeholder.com/150';
                          final name = data['name'] ?? 'Unnamed Product';
                          final price = data['price'] ?? 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
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
                                title: name,
                                price: price,
                                imageUrl: imageUrl,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
