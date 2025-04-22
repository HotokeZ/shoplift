import 'package:flutter/material.dart';
import '../widgets/custom_search_bar.dart';

class NoResultScreen extends StatefulWidget {
  const NoResultScreen({Key? key}) : super(key: key);

  @override
  State<NoResultScreen> createState() => _NoResultScreenState();
}

class _NoResultScreenState extends State<NoResultScreen> {
  String searchText = 'Blouse and Jean';

  void performSearch(String query) {
    // Implement your search logic here
    print('Searching for: $query');
    // Example: Navigate to a results page or update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: EdgeInsets.zero,
        padding:
            MediaQuery.of(context).size.width > 991
                ? const EdgeInsets.all(20)
                : MediaQuery.of(context).size.width > 640
                ? const EdgeInsets.all(16)
                : const EdgeInsets.all(12),
        child: Stack(
          children: [
            CustomSearchBar(
              searchText: searchText,
              onBackPressed: () {
                // Handle back navigation
                Navigator.of(context).pop();
              },
              onClearPressed: () {
                setState(() {
                  searchText = '';
                });
              },
              onSearchChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              onSubmitted: (value) {
                performSearch(value); // Trigger search on submission
              },
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 342),
                padding:
                    MediaQuery.of(context).size.width > 991
                        ? EdgeInsets.zero
                        : MediaQuery.of(context).size.width > 640
                        ? const EdgeInsets.symmetric(horizontal: 20)
                        : const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/04d19bc0a1cfe2a4110ccbd2b0657bc3a8b73e39',
                      width: 100,
                      height: 100,
                      semanticLabel: 'Search',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Sorry, we couldn't find any matching result for your Search.",
                      style: TextStyle(
                        color: const Color(0xFF272727),
                        fontFamily: 'Inter',
                        fontSize:
                            MediaQuery.of(context).size.width > 640 ? 24 : 20,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width:
                          MediaQuery.of(context).size.width > 640
                              ? null
                              : double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // Handle category exploration
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFA3636),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'Explore Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
