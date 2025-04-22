import 'package:flutter/material.dart';
import '../widgets/jacket_search.dart';

class JacketSearchScreen extends StatelessWidget {
  const JacketSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 991 ? 40 : 24,
            vertical: MediaQuery.of(context).size.width > 991 ? 66 : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Row(
                children: [
                  Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/edfc382a605b152ae7b2aa2c5c12d0961f22b28e?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                'https://cdn.builder.io/api/v1/image/assets/TEMP/a51d990a3c9781f283c9b828f7569354757ed3a6?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Jacket',
                                style: TextStyle(
                                  color: Color(0xFF272727),
                                  fontFamily: 'Circular Std',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Image.network(
                            'https://cdn.builder.io/api/v1/image/assets/TEMP/5a8b936bf389607b621952b5b65cecc89fd9d6a3?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                            width: 16,
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Filter Tags
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTag(
                      text: '2',
                      icon: 'https://cdn.builder.io/api/v1/image/assets/TEMP/5f04795e539f2568eddfa7fbbf55e46391c20bd0?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      isActive: true,
                    ),
                    _buildFilterTag(
                      text: 'On Sale',
                      isActive: false,
                    ),
                    _buildFilterTag(
                      text: 'Price',
                      icon: 'https://cdn.builder.io/api/v1/image/assets/TEMP/3ec8760598e23f21a9ae5d9173b69c953184bd35?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      isActive: true,
                    ),
                    _buildFilterTag(
                      text: 'Sort by',
                      icon: 'https://cdn.builder.io/api/v1/image/assets/TEMP/b4928070d7af7f06bb5f725a82fe3d35d5b57b43?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      isActive: false,
                    ),
                    _buildFilterTag(
                      text: 'Men',
                      icon: 'https://cdn.builder.io/api/v1/image/assets/TEMP/3e495801e776d83206573dc74557e8f20957ab52?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      isActive: true,
                    ),
                  ],
                ),
              ),

              // Results Count
              const SizedBox(height: 17),
              const Text(
                '53 Results Found',
                style: TextStyle(
                  color: Color(0xFF272727),
                  fontFamily: 'Circular Std',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),

              // Product Grid
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 991
                        ? 4
                        : MediaQuery.of(context).size.width > 640
                            ? 2
                            : 1,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final products = [
                      {
                        'image': 'https://cdn.builder.io/api/v1/image/assets/TEMP/ee06c36f62927d30d181035147668d7208eaeb35?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                        'title': 'Club Fleece Mens Jacket',
                        'price': '\$56.97'
                      },
                      {
                        'image': 'https://cdn.builder.io/api/v1/image/assets/TEMP/52c347c104078920a32ed5a69a100626d11e17ba?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                        'title': 'Skate Jacket',
                        'price': '\$150.97'
                      },
                      {
                        'image': 'https://cdn.builder.io/api/v1/image/assets/TEMP/b68d2eaa450250ecc5a6c77c9bbc8b0aaa7497ec?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                        'title': 'Therma Fit Puffer Jacket',
                        'price': '\$280.97'
                      },
                      {
                        'image': 'https://cdn.builder.io/api/v1/image/assets/TEMP/947a875e48039e04a8c83ed5786be5cf07379ae2?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                        'title': 'Men\'s Workwear Jacket',
                        'price': '\$128.97'
                      },
                    ];

                    return JacketSearch(
                      imageUrl: products[index]['image']!,
                      title: products[index]['title']!,
                      price: products[index]['price']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTag({
    required String text,
    String? icon,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFA3636) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Image.network(
              icon,
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF272727),
              fontFamily: 'Circular Std',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}