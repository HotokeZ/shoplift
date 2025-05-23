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
        color: hasRedDot ? const Color(0xFFF4F4F4) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            child: NotificationIcons.bell,
          ),
          const SizedBox(width: 21),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: hasRedDot
                    ? const Color(0xFF272727)
                    : const Color(0xFF666666),
                fontSize: 12,
                fontWeight:
                    hasRedDot ? FontWeight.w500 : FontWeight.w400,
                height: 1.6,
              ),
            ),
          ),
          if (hasRedDot)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFA3636),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}