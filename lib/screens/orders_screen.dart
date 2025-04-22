import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 640 && screenWidth <= 991;
    final isMobile = screenWidth <= 640;

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
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: isMobile ? 40 : 71,
                    ),
                    child: Text(
                      'Orders',
                      style: AppTheme.gabaritoBold.copyWith(
                        fontSize: 16,
                        color: AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isMobile ? 150 : 211),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'https://cdn.builder.io/api/v1/image/assets/TEMP/3f7fd91de98175549909c4d17547d9d26b70e0f5',
                        width: 100,
                        height: 100,
                        semanticLabel: 'Shopping cart with checkmark',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Orders yet',
                        style: AppTheme.circularStd.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor,
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
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          'Explore Categories',
                          style: AppTheme.circularStd.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomBottomNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}