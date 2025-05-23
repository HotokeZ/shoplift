import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';

/// Widget that displays a favorite product card with image, name, price and remove button
class FavoriteProductCard extends StatelessWidget {
  /// Product ID
  final String productId;

  /// Product name
  final String name;

  /// Product price
  final String price;

  /// Product image URL
  final String image;

  /// Callback function when removing from favorites
  final Function(String) onRemove; // Updated callback type

  const FavoriteProductCard({
    Key? key,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image - Adjusted height and made it flexible
                Expanded(
                  flex: 2, // Takes up 2/3 of available space
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Product details - Adjusted padding and made it flexible
                Expanded(
                  flex: 1, // Takes up 1/3 of available space
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min, // Added to prevent expansion
                      children: [
                        // Product name
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Circular Std',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.darkText,
                          ),
                          maxLines: 1, // Limit to one line
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // Add spacing
                        // Product price
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Gabarito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkText,
                            ),
                            children: [
                              const TextSpan(text: '\$'),
                              TextSpan(text: price),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Remove from favorites button - Unchanged
            Positioned(
              top: 5,
              right: 10,
              child: GestureDetector(
                onTap: () => onRemove(productId),
                child: Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.string(
                    '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M13.7267 3.31454C14.3133 3.97454 14.6667 4.8412 14.6667 5.79454C14.6667 10.4612 10.3467 13.2145 8.41334 13.8812C8.18668 13.9612 7.81334 13.9612 7.58668 13.8812C5.65334 13.2145 1.33334 10.4612 1.33334 5.79454C1.33334 3.73454 2.99334 2.06787 5.04001 2.06787C6.25334 2.06787 7.32668 2.65454 8.00001 3.5612C8.34253 3.09845 8.78866 2.72235 9.30267 2.46303C9.81669 2.20371 10.3843 2.06838 10.96 2.06787" fill="#FA3636"></path>
                    </svg>''',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
