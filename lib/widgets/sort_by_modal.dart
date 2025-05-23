import 'package:flutter/material.dart';
import 'dart:ui';

/// A modal dialog for selecting sorting options.
class SortByModal extends StatefulWidget {
  /// Callback function when a sort option is selected
  final Function(String)? onSelect;

  /// Callback function when the modal is closed
  final VoidCallback? onClose;

  /// Initial selected sort option (if any)
  final String? initialSelection;

  const SortByModal({
    Key? key,
    this.onSelect,
    this.onClose,
    this.initialSelection,
  }) : super(key: key);

  @override
  _SortByModalState createState() => _SortByModalState();
}

class _SortByModalState extends State<SortByModal> with SingleTickerProviderStateMixin {
  String? selectedOption;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialSelection ?? 'Recommended'; // Default to Recommended

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Cubic(0.37, 0.01, 0, 0.98),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
    if (widget.onSelect != null) {
      widget.onSelect!(option);
    }
  }

  void _clearSelection() {
    setState(() {
      selectedOption = null;
    });
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
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
              color: const Color.fromRGBO(255, 255, 255, 0.95),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Transform.translate(
                    offset: Offset(0, (1 - _animation.value) * 100),
                    child: Opacity(
                      opacity: _animation.value,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxWidth: 390,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Clear button
                                GestureDetector(
                                  onTap: _clearSelection,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        fontFamily: 'Circular Std',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF272727),
                                      ),
                                    ),
                                  ),
                                ),
                                // Title
                                Text(
                                  'Sort by',
                                  style: const TextStyle(
                                    fontFamily: 'Gabarito',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF272727),
                                  ),
                                ),
                                // Close button
                                GestureDetector(
                                  onTap: _closeModal,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CustomPaint(
                                        painter: CloseIconPainter(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Sort options
                            Column(
                              children: [
                                SortOption(
                                  label: 'Recommended',
                                  isSelected: selectedOption == 'Recommended',
                                  onTap: () => _selectOption('Recommended'),
                                ),
                                const SizedBox(height: 16),
                                SortOption(
                                  label: 'Newest',
                                  isSelected: selectedOption == 'Newest',
                                  onTap: () => _selectOption('Newest'),
                                ),
                                const SizedBox(height: 16),
                                SortOption(
                                  label: 'Lowest - Highest Price',
                                  isSelected: selectedOption == 'Lowest - Highest Price',
                                  onTap: () => _selectOption('Lowest - Highest Price'),
                                ),
                                const SizedBox(height: 16),
                                SortOption(
                                  label: 'Highest - Lowest Price',
                                  isSelected: selectedOption == 'Highest - Lowest Price',
                                  onTap: () => _selectOption('Highest - Lowest Price'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom widget for sort option buttons
class SortOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SortOption({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _SortOptionState createState() => _SortOptionState();
}

class _SortOptionState extends State<SortOption> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 34),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFFFA3636) : const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Circular Std',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: widget.isSelected ? Colors.white : const Color(0xFF272727),
                ),
              ),
              if (widget.isSelected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomPaint(
                      painter: CheckIconPainter(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the check icon
class CheckIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(5, 12.1515)
      ..lineTo(8.81818, 16.8182)
      ..lineTo(19, 6.63635);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for the close icon
class CloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF272727)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw X shape
    canvas.drawLine(
      const Offset(6, 6),
      const Offset(18, 18),
      paint,
    );
    canvas.drawLine(
      const Offset(18, 6),
      const Offset(6, 18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}