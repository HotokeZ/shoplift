import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_modal.dart';

/// A card widget that displays an address with an edit button
class AddressCard extends StatelessWidget {
  /// The address text to display
  final String address;

  /// Callback function when the card is tapped
  final VoidCallback? onTap;

  /// Callback function when edit button is pressed
  final VoidCallback? onEdit;

  /// Callback function when delete button is pressed
  final VoidCallback? onDelete;

  const AddressCard({
    Key? key,
    required this.address,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding calculation
    double horizontalPadding = 20.0;
    double verticalPadding = 18.0;

    if (screenWidth <= AppTheme.breakpointTablet) {
      horizontalPadding = 16.0;
      verticalPadding = 16.0;
    }
    if (screenWidth <= AppTheme.breakpointMobile) {
      horizontalPadding = 14.0;
      verticalPadding = 14.0;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9), // Off-white color
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Address text with truncation
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontFamily: 'Circular Std',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.darkText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryRed),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
