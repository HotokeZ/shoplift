import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import '../widgets/favorite_product_card.dart';

/// Screen that displays the user's favorite products
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Add ScrollController
  final ScrollController _scrollController = ScrollController();

  /// Remove a product from favorites
  void _removeFavorite(String productId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .collection('wishlist')
          .doc(productId)
          .delete();

      setState(() {}); // Refresh the UI

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing item: $e'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  /// Navigate back to previous screen
  void _goBack() {
    Navigator.of(context).pop();
  }

  // Add stream instead of future for real-time updates
  Stream<QuerySnapshot> _getFavoritesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null as QuerySnapshot);

    return FirebaseFirestore.instance
        .collection('accounts')
        .doc(user.uid)
        .collection('wishlist')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: _getResponsivePadding(context),
          child: Column(
            children: [
              // Header with back button and title
              _buildHeader(),

              // Favorites grid
              Expanded(child: _buildFavoritesGrid()),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the header with back button and title
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: SvgPicture.string(
                  '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M7.46001 5.29336L5.71334 7.04003C5.20001 7.55336 5.20001 8.39336 5.71334 8.90669L10.06 13.2534M10.06 2.69336L9.36667 3.38669" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>''',
                  width: 16,
                  height: 16,
                ),
              ),
            ),
          ),

          // Title with favorites count
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('accounts')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('wishlist')
                    .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                  children: [
                    const TextSpan(text: 'My Favourites ('),
                    TextSpan(text: count.toString()),
                    const TextSpan(text: ')'),
                  ],
                ),
              );
            },
          ),

          // Empty container for alignment
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Build the grid of favorite products
  Widget _buildFavoritesGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFavoritesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final favorites = snapshot.data?.docs ?? [];

        if (favorites.isEmpty) {
          return const Center(child: Text('No items in wishlist yet'));
        }

        return GridView.builder(
          controller: _scrollController, // Add scroll controller
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: _getMaxCrossAxisExtent(context),
            mainAxisSpacing: _getGridSpacing(context),
            crossAxisSpacing: _getGridSpacing(context),
            childAspectRatio: 0.7,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index].data() as Map<String, dynamic>;
            return FavoriteProductCard(
              productId: favorites[index].id,
              name: item['name'],
              price: item['price'].toString(),
              image: item['image'],
              onRemove: (String id) => _removeFavorite(id),
            );
          },
        );
      },
    );
  }

  /// Get responsive padding based on screen width
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= AppTheme.mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 15, vertical: 10);
    } else if (width <= AppTheme.tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 25, vertical: 15);
    } else {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
    }
  }

  /// Get responsive grid spacing based on screen width
  double _getGridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= AppTheme.mobileBreakpoint) {
      return 4.0;
    } else if (width <= AppTheme.tabletBreakpoint) {
      return 6.0;
    } else {
      return 8.0;
    }
  }

  /// Get responsive max cross axis extent based on screen width
  double _getMaxCrossAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width <= AppTheme.mobileBreakpoint) {
      return 120.0;
    } else if (width <= AppTheme.tabletBreakpoint) {
      return 140.0;
    } else {
      return 160.0;
    }
  }
}
