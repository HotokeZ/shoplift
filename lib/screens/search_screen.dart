import 'package:flutter/material.dart';
import 'jacket_search_screen.dart'; // Import the JacketSearch screen
import 'no_result_screen.dart'; // Import the NoResultScreen
import '../widgets/search_category.dart';
import '../widgets/sort_dialog.dart';
import '../widgets/custom_search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch(String query) {
    // Trim excess spaces and convert to lowercase
    final trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery == 'jacket') {
      // Navigate to the JacketSearch screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JacketSearchScreen()),
      );
    } else {
      // Navigate to the NoResultScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NoResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 66, 24, 82),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Replace the existing search bar with CustomSearchBar
                CustomSearchBar(
                  searchText: _searchController.text,
                  onBackPressed: () {
                    Navigator.pop(context);
                  },
                  onClearPressed: () {
                    _searchController.clear();
                  },
                  onSearchChanged: (value) {
                    _searchController.text = value;
                  },
                  onSubmitted: _handleSearch, // Handle search on submit
                ),

                SizedBox(height: 34),

                // Sort By button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder:
                            (context) =>
                                const SortDialog(), // Show SortDialog widget
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF272727),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Circular Std',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 34),

                // Categories title
                Text(
                  'Shop by Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF272727),
                  ),
                ),

                SizedBox(height: 14),

                // Categories list
                Column(
                  children: [
                    SearchCategory(
                      imageUrl:
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/f0df8b04af248364a4ec87d4fc6e224dafe76022?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      title: 'Hoodies',
                    ),
                    SizedBox(height: 8),
                    SearchCategory(
                      imageUrl:
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/6c6a2a026891b736ab1f8b00c72709560bcb952a?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      title: 'Accessories',
                    ),
                    SizedBox(height: 8),
                    SearchCategory(
                      imageUrl:
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/6dce91ecf4c052fd192e75c8b551283fc29e2e74?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      title: 'Shorts',
                    ),
                    SizedBox(height: 8),
                    SearchCategory(
                      imageUrl:
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/5a96a76756b89d9d730c7673d98757bffc491f1c?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      title: 'Shoes',
                    ),
                    SizedBox(height: 8),
                    SearchCategory(
                      imageUrl:
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/b85156355517af68fe1b2117d564429e59409b9d?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                      title: 'Bags',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
