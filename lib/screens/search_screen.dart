import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the HomeScreen
import 'item_search_screen.dart'; // Import the JacketSearch screen
import 'no_result_screen.dart'; // Import the NoResultScreen
import '../widgets/search_category.dart';
import '../widgets/sort_dialog.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/bottom_nav_bar.dart'; // Import the CustomBottomNavBar
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import '../widgets/product_card.dart'; // Import the ProductCard widget
import 'product_detail_screen.dart'; // Import the ProductDetailScreen

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch(String query) {
    // Trim excess spaces and convert to lowercase
    final trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemSearchScreen(
            searchQuery: trimmedQuery,
            sortBy: 'Latest', // Add default sort value
          ),
        ),
      );
    }
  }

  // Update the StreamBuilder's stream to include category search
  Stream<QuerySnapshot> _getSearchStream() {
    if (_searchController.text.isEmpty) {
      return FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }

    final searchQuery = _searchController.text.toLowerCase();
    
    // Create the queries for name and categories
    return FirebaseFirestore.instance
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThan: searchQuery + 'z')
        .snapshots()
        .asyncMap((nameSnapshot) async {
          // Get category results
          final categorySnapshot = await FirebaseFirestore.instance
              .collection('products')
              .where('categories', arrayContains: searchQuery)
              .get();
          
          // Combine results and remove duplicates using a Set
          final Set<DocumentSnapshot> uniqueDocs = {};
          uniqueDocs.addAll(nameSnapshot.docs);
          uniqueDocs.addAll(categorySnapshot.docs);
          
          final allDocs = uniqueDocs.toList();
          
          // Sort the results
          allDocs.sort((a, b) {
            final dateA = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
            final dateB = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
            return dateB.compareTo(dateA);
          });
          
          return nameSnapshot;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchBar(
                    searchText: _searchController.text,
                    onBackPressed: () {
                      Navigator.pop(context);
                    },
                    onClearPressed: () {
                      setState(() {
                        _searchController.clear(); // Only clear the text field
                      });
                    },
                    onSearchChanged: (value) {
                      _searchController.text = value;
                    },
                    onSubmitted: _handleSearch,
                  ),
                ],
              ),
            ),
            // Product Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getSearchStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products available.'));
                  }

                  final products = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] as String? ?? '').toLowerCase();
                    final categories = (data['categories'] as List<dynamic>?)
                        ?.map((e) => e.toString().toLowerCase())
                        .toList() ?? [];
                    final searchQuery = _searchController.text.toLowerCase();
                    return name.contains(searchQuery) ||
                        categories.any((category) => category.contains(searchQuery));
                  }).toList();

                  // Gather all unique userIds
                  final userIds = <String>{};
                  for (var product in products) {
                    final data = product.data() as Map<String, dynamic>;
                    final userId = data['userId'] as String?;
                    if (userId != null) userIds.add(userId);
                  }

                  if (userIds.isEmpty) {
                    return const Center(child: Text('No matching products found.'));
                  }

                  // Fetch ban status for these users
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('accounts')
                        .where(FieldPath.documentId, whereIn: userIds.toList())
                        .get(),
                    builder: (context, sellerSnapshot) {
                      if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!sellerSnapshot.hasData) {
                        return const Center(child: Text('No matching products found.'));
                      }

                      // Map userId -> isBanned
                      final bannedMap = <String, bool>{};
                      for (var doc in sellerSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        bannedMap[doc.id] = data['isBanned'] == true;
                      }

                      // Filter products whose user is not banned
                      final visibleProducts = products.where((product) {
                        final data = product.data() as Map<String, dynamic>;
                        final userId = data['userId'] as String?;
                        if (userId == null) return false;
                        return bannedMap.containsKey(userId) && bannedMap[userId] != true;
                      }).toList();

                      if (visibleProducts.isEmpty) {
                        return const Center(child: Text('No matching products found.'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: visibleProducts.length,
                        itemBuilder: (context, index) {
                          final product = visibleProducts[index];
                          final data = product.data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                            child: ProductCard(
                              title: data['name'] ?? 'Unnamed Product',
                              price: (data['price'] ?? 0.0).toDouble(),
                              imageUrl: (data['images'] as List<dynamic>?)?.firstOrNull?.toString() ??
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
