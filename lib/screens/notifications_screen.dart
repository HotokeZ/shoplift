import 'package:flutter/material.dart';
import '../widgets/notification_item.dart';
import '../widgets/bottom_nav_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 71, bottom: 40),
              child: Text(
                'Notifications',
                style: const TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF272727),
                ),
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    children: const [
                      NotificationItem(
                        message:
                            'Gilbert, you placed and order check your order history for full details',
                        hasRedDot: true,
                      ),
                      SizedBox(height: 8),
                      NotificationItem(
                        message:
                            'Gilbert, Thank you for shopping with us we have canceled order #24568.',
                        hasRedDot: false,
                      ),
                      SizedBox(height: 8),
                      NotificationItem(
                        message:
                            'Gilbert, your Order #24568 has been confirmed check your order history for full details',
                        hasRedDot: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const CustomBottomNavBar(),
          ],
        ),
      ),
    );
  }
}
