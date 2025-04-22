import 'package:flutter/material.dart';
import '../widgets/hoodie_card.dart';
import '../models/product.dart';

class HoodiesScreen extends StatefulWidget {
  const HoodiesScreen({super.key});

  @override
  State<HoodiesScreen> createState() => _HoodiesScreenState();
}

class _HoodiesScreenState extends State<HoodiesScreen> {
  final List<Product> products = [
    Product(
      id: '1',
      title: "Men's Fleece Pullover Hoodie",
      price: 100.00,
      imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/c520b8895060127d6e58c1886a750a7ca26f01b1',
      altText: 'Green Nike hoodie',
    ),
    Product(
      id: '2',
      title: 'Fleece Pullover Skate Hoodie',
      price: 150.97,
      imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/4c443dde201383be5e5a92b37e0765e3993e08a5',
      altText: 'Black skate hoodies',
    ),
    Product(
      id: '3',
      title: 'Fleece Skate Hoodie',
      price: 110.00,
      imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/e6a5d4101bf41abdbf16ab92bf3762a6750c12f5',
      altText: 'Yellow skate hoodies',
    ),
    Product(
      id: '4',
      title: "Men's Ice-Dye Pullover Hoodie",
      price: 128.97,
      imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/09b3b03fc5ae831fa53e1e4fe5dc35601f0987a9',
      altText: 'Tie dye hoodie',
    ),
    Product(
      id: '5',
      title: "Men's Monogram Hoodie",
      price: 52.97,
      originalPrice: 70.00,
      imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/5db07235bb4bafb560f34be2e3d9bf49661e8dbb',
      altText: 'Patterned black hoodie',
    ),
    Product(
      id: '6',
      title: "Men's Pullover Basketball Hoodie",
      price: 105.00,
      imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/359d0874a20fd477e5422661820051a0e476ad94',
      altText: 'Gray Nike hoodie',
    ),
  ];

  void _toggleFavorite(int index, bool value) {
    setState(() {
      products[index].isFavorite = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 991;
    final padding = isMobile ? 16.0 : 24.0;
    final crossAxisCount = isMobile ? 2 : 4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF272727),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Hoodies (${products.length})', // Dynamic product count
                  style: const TextStyle(
                    color: Color(0xFF272727),
                    fontFamily: 'Gabarito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: products[index],
                      onFavoriteToggle: (value) => _toggleFavorite(index, value),
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
}