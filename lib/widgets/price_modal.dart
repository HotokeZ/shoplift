import 'package:flutter/material.dart';
import 'dart:ui';

/// A modal overlay for selecting price sorting options.
class PriceModal extends StatefulWidget {
  /// Callback function when an option is selected
  final Function(String)? onSelect;

  /// Callback function when the modal is closed
  final VoidCallback? onClose;

  /// Callback function when clear is pressed
  final VoidCallback? onClear;

  const PriceModal({Key? key, this.onSelect, this.onClose, this.onClear})
    : super(key: key);

  @override
  _PriceModalState createState() => _PriceModalState();
}

class _PriceModalState extends State<PriceModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: const Cubic(0.37, 0.01, 0, 0.98),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _handleClear() {
    _minController.clear();
    _maxController.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  void _applyFilter() {
    final String minText = _minController.text;
    final String maxText = _maxController.text;

    double? minPrice = minText.isNotEmpty ? double.tryParse(minText) : null;
    double? maxPrice = maxText.isNotEmpty ? double.tryParse(maxText) : null;

    if (widget.onSelect != null) {
      widget.onSelect!('Min: $minPrice, Max: $maxPrice');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white.withOpacity(0.95),
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, (1 - _animation.value) * 50),
                  child: Opacity(
                    opacity: _animation.value,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 390,
                        minHeight: 300,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: const Color.fromRGBO(230, 230, 230, 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section
                          Padding(
                            padding: const EdgeInsets.only(left: 52, top: -3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Clear button
                                GestureDetector(
                                  onTap: _handleClear,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      'Clear',
                                      style: const TextStyle(
                                        fontFamily: 'Circular Std',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF272727),
                                      ),
                                    ),
                                  ),
                                ),

                                // Space between Clear and Price
                                const SizedBox(width: 100),

                                // Price title
                                Text(
                                  'Price',
                                  style: const TextStyle(
                                    fontFamily: 'Gabarito',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF272727),
                                  ),
                                ),

                                // Close icon
                                const SizedBox(width: 19),
                                GestureDetector(
                                  onTap: _handleClose,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Image.network(
                                      'https://cdn.builder.io/api/v1/image/assets/TEMP/b2090d53e961d38033e447e4781146f2a6a61c1d?placeholderIfAbsent=true&apiKey=7e06566da64e450e915c0d66cef510c6',
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Min and Max input fields
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                              top: 28,
                              left: 5,
                              bottom: -40,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Min input field
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 42,
                                    top: 16,
                                  ),
                                  width: 342,
                                  child: TextField(
                                    controller: _minController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Min',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 28,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                ),

                                // Max input field
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 42,
                                    top: 32,
                                  ),
                                  width: 342,
                                  child: TextField(
                                    controller: _maxController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Max',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 28,
                                            vertical: 16,
                                          ),
                                    ),
                                  ),
                                ),

                                // Apply button
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 42,
                                    top: 32,
                                  ),
                                  width: 342,
                                  child: ElevatedButton(
                                    onPressed: _applyFilter,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text(
                                      'Apply',
                                      style: TextStyle(
                                        fontFamily: 'Circular Std',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
