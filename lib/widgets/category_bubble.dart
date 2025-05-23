import 'package:flutter/material.dart';

class CategoryBubble extends StatelessWidget {
  final String label;
  final bool isActive;

  const CategoryBubble({
    Key? key,
    required this.label,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.red : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}