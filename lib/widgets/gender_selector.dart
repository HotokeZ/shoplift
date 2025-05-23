import 'package:flutter/material.dart';
import 'dart:ui';

/// A modal dialog for selecting gender options.
class GenderSelectionModal extends StatefulWidget {
  /// Callback function when a gender is selected
  final Function(String)? onSelect;

  /// Callback function when the modal is closed
  final VoidCallback? onClose;

  /// Initial selected gender (if any)
  final String? initialSelection;

  const GenderSelectionModal({
    Key? key,
    this.onSelect,
    this.onClose,
    this.initialSelection,
  }) : super(key: key);

  @override
  _GenderSelectionModalState createState() => _GenderSelectionModalState();
}

class _GenderSelectionModalState extends State<GenderSelectionModal>
    with SingleTickerProviderStateMixin {
  String? selectedGender;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialSelection;

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

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
    if (widget.onSelect != null) {
      widget.onSelect!(gender);
    }
  }

  void _clearSelection() {
    setState(() {
      selectedGender = null;
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
                        constraints: const BoxConstraints(maxWidth: 390),
                        height: 397,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          border: Border.all(
                            color: const Color.fromRGBO(216, 222, 228, 1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(140, 149, 159, 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Header
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Clear button
                                    GestureDetector(
                                      onTap: _clearSelection,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Text(
                                          'Clear',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(
                                              0xFF24292E,
                                            ).withOpacity(0.75),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Title
                                    Text(
                                      'Gender',
                                      style: const TextStyle(
                                        fontFamily: 'Mona Sans',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF24292F),
                                        letterSpacing: -0.24,
                                      ),
                                    ),
                                    // Placeholder to balance the row
                                    const SizedBox(width: 40),
                                  ],
                                ),
                              ),
                            ),

                            // Close button
                            Positioned(
                              top: 17,
                              right: 24,
                              child: GestureDetector(
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
                            ),

                            // Options container
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 71,
                                left: 24,
                                right: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Men option
                                  GenderOption(
                                    label: 'Men',
                                    isSelected: selectedGender == 'Men',
                                    onTap: () => _selectGender('Men'),
                                  ),
                                  const SizedBox(height: 16),

                                  // Women option
                                  GenderOption(
                                    label: 'Women',
                                    isSelected: selectedGender == 'Women',
                                    onTap: () => _selectGender('Women'),
                                  ),
                                  const SizedBox(height: 16),

                                  // Kids option
                                  GenderOption(
                                    label: 'kids',
                                    isSelected: selectedGender == 'kids',
                                    onTap: () => _selectGender('kids'),
                                  ),
                                ],
                              ),
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

/// Custom widget for gender option buttons
class GenderOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderOption({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _GenderOptionState createState() => _GenderOptionState();
}

class _GenderOptionState extends State<GenderOption> {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.37, 0.01, 0, 0.98),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(34, 18, 22, 14),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: _getBorderColor(), width: 1),
          ),
          child: Stack(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      isPressed && widget.isSelected
                          ? Colors.white
                          : const Color(0xFF24292E),
                  letterSpacing: -0.5,
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
                      painter: CheckIconPainter(
                        color: isPressed ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isPressed && widget.isSelected) {
      return const Color(0xFFFA3636); // Active state
    } else if (widget.isSelected) {
      return const Color(0xFFF6F8FA); // Selected state
    } else if (isHovered) {
      return const Color(0xFFF6F8FA); // Hover state
    } else {
      return Colors.white; // Default state
    }
  }

  Color _getBorderColor() {
    if (isPressed && widget.isSelected) {
      return const Color(0xFFFA3636); // Active state
    } else if (isHovered && !widget.isSelected) {
      return const Color(0xFF0366D6); // Hover state
    } else if (widget.isSelected) {
      return const Color(0xFFD8DEE4); // Selected state
    } else {
      return const Color(0xFFE1E4E8); // Default state
    }
  }
}

/// Custom painter for the check icon
class CheckIconPainter extends CustomPainter {
  final Color color;

  CheckIconPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final path =
        Path()
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
    final paint =
        Paint()
          ..color = const Color(0xFF272727)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // Draw X shape
    canvas.drawLine(const Offset(6, 6), const Offset(18, 18), paint);
    canvas.drawLine(const Offset(18, 6), const Offset(6, 18), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Function to show the gender selector modal or dialog
Future<void> showGenderSelector(
  BuildContext context, {
  required Function(String) onSelect,
}) async {
  final screenSize = MediaQuery.of(context).size;
  final bool isMobile = screenSize.width <= 640;

  if (isMobile) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GenderSelectionModal(
            onClose: () => Navigator.pop(context),
            onSelect: onSelect,
          ),
    );
  } else {
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: GenderSelectionModal(
              onClose: () => Navigator.pop(context),
              onSelect: onSelect,
            ),
          ),
    );
  }
}
