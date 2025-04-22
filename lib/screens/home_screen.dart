import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_icons.dart';
import '../screens/categories_screen.dart';
import '../screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildCategories(),
                    const SizedBox(height: 24),
                    _buildTopSelling(),
                    const SizedBox(height: 24),
                    _buildNewIn(),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(radius: 20, backgroundColor: AppColors.grey),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Text('Men', style: AppStyles.categoryText),
              const SizedBox(width: 4),
              SvgPicture.string(AppIcons.arrowDown),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: SvgPicture.string(
              AppIcons.cart, // Replace with the cart icon
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            SvgPicture.string(AppIcons.search),
            const SizedBox(width: 12),
            Text('Search', style: AppStyles.searchText),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Categories', style: AppStyles.sectionTitle),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
              child: Text('See All', style: AppStyles.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              CategoryItem(
                title: 'Hoodies',
                imageUrl: 'https://example.com/images/hoodies.png',
              ),
              CategoryItem(
                title: 'Shorts',
                imageUrl: 'https://example.com/images/shorts.png',
              ),
              CategoryItem(
                title: 'Shoes',
                imageUrl: 'https://example.com/images/shoes.png',
              ),
              CategoryItem(
                title: 'Bag',
                imageUrl: 'https://example.com/images/bag.png',
              ),
              CategoryItem(
                title: 'Accessories',
                imageUrl: 'https://example.com/images/accessories.png',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopSelling() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Top Selling', style: AppStyles.sectionTitle),
            Text('See All', style: AppStyles.seeAll),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(right: index < 4 ? 12 : 0),
                child: ProductCard(
                  title: 'Top Selling ${index + 1}',
                  price: (50 + index * 10).toDouble(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewIn() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('New In', style: AppStyles.sectionTitle),
            Text('See All', style: AppStyles.seeAll),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(right: index < 4 ? 12 : 0),
                child: ProductCard(
                  title: 'New In ${index + 1}',
                  price: (50 + index * 10).toDouble(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
