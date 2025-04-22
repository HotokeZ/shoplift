import 'package:flutter/material.dart';

class JacketSearch extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;

  const JacketSearch({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
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
                  ),
                  Positioned(
                    right: 10,
                    top: 5,
                    child: Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/29644ec814ae1b39fb04d6faf4daa9da217481dd?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      width: 24,
                      height: 24,
                    ),
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