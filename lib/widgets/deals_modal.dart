import 'package:flutter/material.dart';
import 'dart:ui';

/// A modal overlay for selecting deal options.
class DealsModal extends StatefulWidget {
  /// Callback function when an option is selected
  final Function(String)? onSelect;

  /// Callback function when the modal is closed
  final VoidCallback? onClose;

  /// Callback function when clear is pressed
  final VoidCallback? onClear;

  const DealsModal({
    Key? key,
    this.onSelect,
    this.onClose,
    this.onClear,
  }) : super(key: key);

  @override
  _DealsModalState createState() => _DealsModalState();
}

class _DealsModalState extends State<DealsModal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

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
    super.dispose();
  }

  void _handleClear() {
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

  void _handleOptionSelect(String option) {
    if (widget.onSelect != null) {
      widget.onSelect!(option);
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

                                // Space between Clear and Deals
                                const SizedBox(width: 100),

                                // Deals title
                                Text(
                                  'Deals',
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

                          // Options section
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 28, left: 5, bottom: -40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // On sale option
                                Container(
                                  margin: const EdgeInsets.only(left: 42, top: 16),
                                  width: 342,
                                  child: GestureDetector(
                                    onTap: () => _handleOptionSelect('On sale'),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFA3636),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'On sale',
                                              style: const TextStyle(
                                                fontFamily: 'Circular Std',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Image.network(
                                              'https://cdn.builder.io/api/v1/image/assets/TEMP/cf8bd7c6f4c9fa28e10a9699d319442f63cd9a0e?placeholderIfAbsent=true&apiKey=7e06566da64e450e915c0d66cef510c6',
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Free Shipping Eligible option
                                Container(
                                  margin: const EdgeInsets.only(left: 42, top: 32),
                                  width: 342,
                                  child: GestureDetector(
                                    onTap: () => _handleOptionSelect('Free Shipping Eligible'),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F4F4),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          'Free Shipping Eligible',
                                          style: const TextStyle(
                                            fontFamily: 'Circular Std',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF272727),
                                          ),
                                        ),
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