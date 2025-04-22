import 'package:flutter/material.dart';
import 'notification_icons.dart';

class NotificationItem extends StatelessWidget {
  final String message;
  final bool hasRedDot;

  const NotificationItem({
    super.key,
    required this.message,
    required this.hasRedDot,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                NotificationIcons.bell,
                if (hasRedDot)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFA3636),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 21),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF272727),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}