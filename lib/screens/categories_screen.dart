import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight > 0 ? constraints.maxHeight : 800; // Fallback value
          final horizontalPadding = _getClampedValue(16, maxWidth * 0.03, 24);
          final verticalPadding = _getClampedValue(32, maxHeight * 0.06, 63);

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: verticalPadding), // Removed `const`
                  Text(
                    'Shop by Categories',
                    style: TextStyle(
                      color: const Color(0xFF272727),
                      fontFamily: 'Gabarito',
                      fontSize: _getClampedValue(20, maxWidth * 0.03, 24),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category Items
                  _buildCategoryItem(
                    context,
                    imageUrl: 'https://example.com/valid-image-url.png',
                    title: 'Hoodies',
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    context,
                    imageUrl: 'https://example.com/valid-image-url.png',
                    title: 'Accessories',
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    context,
                    imageUrl: 'https://example.com/valid-image-url.png',
                    title: 'Shorts',
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    context,
                    imageUrl: 'https://example.com/valid-image-url.png',
                    title: 'Shoes',
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryItem(
                    context,
                    imageUrl: 'https://example.com/valid-image-url.png',
                    title: 'Bags',
                  ),
                  SizedBox(height: verticalPadding), // Removed `const`
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, {required String imageUrl, required String title}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _getClampedValue(12, screenWidth * 0.02, 16),
        horizontal: _getClampedValue(16, screenWidth * 0.04, 24),
      ),
      margin: EdgeInsets.symmetric(horizontal: _getClampedValue(8, screenWidth * 0.02, 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(_getClampedValue(12, screenWidth * 0.02, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_getClampedValue(12, screenWidth * 0.02, 16)),
            child: Image.network(
              imageUrl,
              width: _getClampedValue(50, screenWidth * 0.12, 70),
              height: _getClampedValue(50, screenWidth * 0.12, 70),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF272727),
                fontSize: _getClampedValue(16, screenWidth * 0.04, 20),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _getClampedValue(double min, double preferred, double max) {
    return preferred.clamp(min, max);
  }
}