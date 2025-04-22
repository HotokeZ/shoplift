import 'package:flutter/material.dart';
import '../utils/app_icons.dart';

class OrderItemCard extends StatelessWidget {
  final String orderNumber;
  final int itemCount;

  const OrderItemCard({
    super.key,
    required this.orderNumber,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            child: AppIcons.receipt,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #$orderNumber',
                  style: const TextStyle(
                    color: Color(0xFF272727),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$itemCount items',
                  style: const TextStyle(
                    color: Color(0x80272727),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          AppIcons.arrowRight,
        ],
      ),
    );
  }
}