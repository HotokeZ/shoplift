import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A reusable widget for checkout sections (shipping address, payment method)
class CheckoutSection extends StatelessWidget {
  /// Title of the section
  final String title;

  /// Content of the section (can be a string or widget)
  final dynamic content;

  /// Callback when edit button is pressed
  final VoidCallback onEdit;

  const CheckoutSection({
    Key? key,
    required this.title,
    required this.content,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 12, 11, 23),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.darkText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 4),

          // Content
          content is String
              ? Text(
                content,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.darkText,
                  overflow: TextOverflow.ellipsis,
                ),
              )
              : content,
        ],
      ),
    );
  }
}
