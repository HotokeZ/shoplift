import 'package:flutter/material.dart';

class OrderStatusItem extends StatelessWidget {
  final String imageUrl;
  final String status;
  final String date;

  const OrderStatusItem({
    super.key,
    required this.imageUrl,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(
              imageUrl,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: const TextStyle(
                fontFamily: 'CircularStd',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF272727),
              ),
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'CircularStd',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF272727),
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}