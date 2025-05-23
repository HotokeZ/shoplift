import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_styles.dart';

class CategoryItem extends StatefulWidget {
  final String title;
  final String? imageUrl; // Make imageUrl optional

  const CategoryItem({
    Key? key,
    required this.title,
    this.imageUrl, // Optional parameter
  }) : super(key: key);

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.imageUrl != null) // Only show the image if imageUrl is provided
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          widget.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}