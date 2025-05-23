import 'package:flutter/material.dart';
import 'dart:async'; // Add this import
import '../models/cart_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_modal.dart';

/// A widget that displays a single cart item with product details, quantity controls, and delete icon.
class CartItemWidget extends StatefulWidget {
  // Change to StatefulWidget
  final CartItem item;
  final Function(String id, int change) onUpdateQuantity;
  // Change back to the original VoidCallback
  final VoidCallback? onDelete;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onUpdateQuantity,
    this.onDelete,
  }) : super(key: key);

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  // Timers for continuous quantity change
  Timer? _incrementTimer;
  Timer? _decrementTimer;

  @override
  void dispose() {
    // Clean up timers
    _incrementTimer?.cancel();
    _decrementTimer?.cancel();
    super.dispose();
  }

  // Start continuous increment with simpler parameter
  void _startIncrement() {
    print("Long press increment started"); // Debug print

    // First call immediately
    widget.onUpdateQuantity(widget.item.id, 1);

    // Then set up continuous calls with faster initial response
    _incrementTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      print("Timer tick: ${timer.tick}"); // Debug print

      // If held for more than 1 second, speed up
      if (timer.tick > 10) {
        widget.onUpdateQuantity(widget.item.id, 5);
      } else {
        widget.onUpdateQuantity(widget.item.id, 1);
      }
    });
  }

  // Update _startDecrement to be quantity-aware
  void _startDecrement() {
    print("Long press decrement started");

    // If quantity is already 1, just do a single decrement
    if (widget.item.quantity <= 1) {
      widget.onUpdateQuantity(widget.item.id, -1);
      return; // Don't start the timer
    }

    // First call immediately
    widget.onUpdateQuantity(widget.item.id, -1);

    // Then set up continuous calls
    _decrementTimer = Timer.periodic(const Duration(milliseconds: 200), (
      timer,
    ) {
      print("Timer tick: ${timer.tick}");

      // Stop timer if quantity is at 1 to avoid multiple remove dialogs
      if (widget.item.quantity <= 1) {
        _stopDecrement();
        return;
      }

      // If held for more than 1 second, speed up but be careful near 1
      if (timer.tick > 5) {
        // Only decrement by 5 if it won't go below 1
        final change = widget.item.quantity > 6 ? -5 : -1;
        widget.onUpdateQuantity(widget.item.id, change);
      } else {
        widget.onUpdateQuantity(widget.item.id, -1);
      }
    });
  }

  // Stop continuous increment
  void _stopIncrement() {
    _incrementTimer?.cancel();
    _incrementTimer = null;
  }

  // Stop continuous decrement
  void _stopDecrement() {
    _decrementTimer?.cancel();
    _decrementTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallPadding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        children: [
          // Product image (unchanged)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              image: DecorationImage(
                image: NetworkImage(
                  widget.item.imageUrl ?? 'https://placeholder.com/60x60',
                ),
                fit: BoxFit.cover,
                // Add error handling for failed image loads
                onError: (_, __) => const Icon(Icons.image_not_supported),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.smallPadding),

          // Product details (unchanged)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: AppTheme.titleStyle.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.item.varieties.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.item.varieties.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(', '),
                      style: AppTheme.descriptionStyle.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '₱${widget.item.price.toStringAsFixed(2)}',
                  style: AppTheme.priceStyle,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppTheme.smallPadding),

          // Quantity controls with gesture detector
          Row(
            children: [
              // DECREMENT BUTTON
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GestureDetector(
                  onTap: () => widget.onUpdateQuantity(widget.item.id, -1),
                  onLongPress: _startDecrement,
                  onLongPressUp: _stopDecrement,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: const Center(child: Icon(Icons.remove, size: 18)),
                  ),
                ),
              ),
              // QUANTITY TEXT
              Container(
                width: 40,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.item.quantity.toString(),
                  style: AppTheme.titleStyle.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              // INCREMENT BUTTON
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GestureDetector(
                  onTap: () => widget.onUpdateQuantity(widget.item.id, 1),
                  onLongPress: _startIncrement,
                  onLongPressUp: _stopIncrement,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: const Center(child: Icon(Icons.add, size: 18)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: AppTheme.smallPadding),

          // Delete icon (simple version)
          GestureDetector(
            onTap: widget.onDelete,
            child: const Icon(
              Icons.delete_outline,
              color: AppTheme.primaryRed,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
