import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;
  final bool isBanned;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.isBanned = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isBanned) {
      return Container(
        width: 159,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Product Unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 159, // Fixed width for consistent card size
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AspectRatio(
              aspectRatio: 1, // Ensures the image is square
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Ensures the image fills the space proportionally
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey,
                    child: const Icon(Icons.image, color: Colors.white, size: 50),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title
                Text(
                  title,
                  style: AppStyles.productTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Product Price
                Text(
                  '₱${price.toStringAsFixed(2)}',
                  style: AppStyles.productPrice,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
