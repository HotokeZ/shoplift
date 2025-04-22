import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/explore_button.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 71),
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/4bd7660d9531a35a1d1cdcf99ab04b3437b1e20a',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Notification yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Explore Categories',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const CustomBottomNavBar(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}