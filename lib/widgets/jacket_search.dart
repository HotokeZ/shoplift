import 'package:flutter/material.dart';

class JacketSearch extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget favoriteIcon; // Add favoriteIcon parameter

  const JacketSearch({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.errorBuilder,
    required this.favoriteIcon, // Add favoriteIcon to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle product tap
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder:
                        errorBuilder ??
                        (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                  ),
                  Positioned(
                    right: 10,
                    top: 5,
                    child: favoriteIcon, // Use the favoriteIcon here
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF272727),
                      fontFamily: 'Circular Std',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF272727),
                      fontFamily: 'Gabarito',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
