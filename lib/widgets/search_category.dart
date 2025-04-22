import 'package:flutter/material.dart';

class SearchCategory extends StatelessWidget {
  final String imageUrl;
  final String title;

  const SearchCategory({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w400,
                color: Color(0xFF272727),
              ),
            ),
          ),
        ],
      ),
    );
  }
}