import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget { // Renamed from CustomTabBar
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding calculation
    double horizontalPadding = 40.0;
    if (screenWidth <= 991) {
      horizontalPadding = 15.0;
    }
    if (screenWidth <= 640) {
      horizontalPadding = 10.0;
    }

    // Responsive gap calculation
    double gap = 20.0;
    if (screenWidth <= 991) {
      gap = 30.0;
    }
    if (screenWidth <= 640) {
      gap = 20.0;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth <= 640 ? 15.0 : 40.0,
              vertical: 20.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabImage("https://cdn.builder.io/api/v1/image/assets/TEMP/8e4fab5624f8d9b0751c40c9d575943aabb66e0f?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295", true),
                SizedBox(width: gap),
                _buildTabImage("https://cdn.builder.io/api/v1/image/assets/TEMP/168f8cba1f8bc340850f80edbf10504688a7961b?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295", false),
                SizedBox(width: gap),
                _buildTabImage("https://cdn.builder.io/api/v1/image/assets/TEMP/3dc5b8c88380ccb52dd575637b110821ea2b9775?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295", true),
                SizedBox(width: gap),
                _buildTabImage("https://cdn.builder.io/api/v1/image/assets/TEMP/681c520e67c01bf80c4113f34e0eb372e7a0e9a6?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295", true),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 20.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTabImage(String imageUrl, bool isRounded) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 40.0,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isRounded ? 100.0 : 0.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}