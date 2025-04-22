import 'package:flutter/material.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_item_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/app_icons.dart';

class OrdersScreenItems extends StatelessWidget {
  const OrdersScreenItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 71),
                    const Text(
                      'Orders',
                      style: TextStyle(
                        color: Color(0xFF272727),
                        fontFamily: 'Gabarito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          OrderStatusChip(
                            label: 'Processing',
                            isActive: true,
                            onTap: () {},
                          ),
                          OrderStatusChip(
                            label: 'Shipped',
                            isActive: false,
                            onTap: () {},
                          ),
                          OrderStatusChip(
                            label: 'Delivered',
                            isActive: false,
                            onTap: () {},
                          ),
                          OrderStatusChip(
                            label: 'Returned',
                            isActive: false,
                            onTap: () {},
                          ),
                          OrderStatusChip(
                            label: 'Canceled',
                            isActive: false,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        children: const [
                          OrderItemCard(
                            orderNumber: '456765',
                            itemCount: 4,
                          ),
                          SizedBox(height: 12),
                          OrderItemCard(
                            orderNumber: '454569',
                            itemCount: 2,
                          ),
                          SizedBox(height: 12),
                          OrderItemCard(
                            orderNumber: '454809',
                            itemCount: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
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