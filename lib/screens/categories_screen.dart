import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/products_screen.dart';
import '../theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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
      backgroundColor: Colors.white,
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
        title: const Text(
          'Categories',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          // Categories List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No categories available.'));
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
                  return const Center(child: Text('No categories available.'));
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
                      return const Center(child: Text('No categories available.'));
                    }

                    // Map userId -> isBanned
                    final bannedMap = <String, bool>{};
                    for (var doc in sellerSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      bannedMap[doc.id] = data['isBanned'] == true;
                    }

                    // Only include categories from non-banned users
                    final categories = <String>{};
                    for (var product in products) {
                      final data = product.data() as Map<String, dynamic>;
                      final userId = data['userId'] as String?;
                      if (userId == null) continue;
                      if (!bannedMap.containsKey(userId) || bannedMap[userId] == true) continue;
                      final productCategories = data['categories'] as List<dynamic>?;
                      if (productCategories != null) {
                        categories.addAll(productCategories.map((e) => e.toString()));
                      }
                    }

                    final sortedCategories = categories.toList()..sort();

                    // Filter categories based on search
                    final filteredCategories = sortedCategories
                        .where((category) => category.toLowerCase().contains(_searchQuery))
                        .toList();

                    if (filteredCategories.isEmpty) {
                      return const Center(
                        child: Text('No matching categories found.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsScreen(
                                    selectedCategory: category,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      color: Color(0xFF272727),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Color(0xFF272727),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
