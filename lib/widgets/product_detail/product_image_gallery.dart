import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A widget that displays a horizontal gallery of product images
class ProductImageGallery extends StatelessWidget {
  /// List of image URLs to display
  final List<String> imageUrls;

  /// Alternative text for images
  final List<String> altTexts;

  const ProductImageGallery({
    Key? key,
    required this.imageUrls,
    required this.altTexts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate image dimensions based on screen size
    double imageWidth;
    double imageHeight;

    if (screenWidth <= AppTheme.mobileBreakpoint) {
      imageWidth = 80;
      imageHeight = 123;
    } else if (screenWidth <= AppTheme.tabletBreakpoint) {
      imageWidth = 100;
      imageHeight = 154;
    } else {
      imageWidth = 161;
      imageHeight = 248;
    }

    return Row(
      children: List.generate(
        imageUrls.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            right: index < imageUrls.length - 1 ? 10 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Image.network(
              imageUrls[index],
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              semanticLabel: altTexts[index],
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: AppTheme.lightGray,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryRed,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: AppTheme.lightGray,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppTheme.darkText,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}