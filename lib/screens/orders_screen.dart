import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet =
        screenWidth > AppTheme.mobileBreakpoint &&
        screenWidth <= AppTheme.tabletBreakpoint;
    final isMobile = screenWidth <= AppTheme.mobileBreakpoint;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet || isMobile ? double.infinity : 412,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: isTablet || isMobile ? 0 : (screenWidth - 412) / 2,
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: isMobile ? 40 : 71),
                child: Text(
                  'Orders',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 16,
                    color: AppTheme.darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isMobile ? 150 : 211),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/3f7fd91de98175549909c4d17547d9d26b70e0f5',
                    width: 100,
                    height: 100,
                    semanticLabel: 'Shopping cart with checkmark',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Orders yet',
                    style: AppTheme.optionLabelStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.circularRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      'Explore Categories',
                      style: AppTheme.buttonTextStyle.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 2, // Index for OrdersScreen
      ),
    );
  }
}
