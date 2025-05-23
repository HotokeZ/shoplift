import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoplift/utils/app_icons.dart'; // Import AppIcons

/// A modal dialog for selecting sizes or varieties.
class SizeModal extends StatefulWidget {
  final Function(String)? onSelect;
  final VoidCallback? onClose;
  final String? initialSelection;
  final List<String> options; // Accept options dynamically (e.g., sizes or varieties)

  const SizeModal({
    Key? key,
    this.onSelect,
    this.onClose,
    this.initialSelection,
    required this.options, // Mark as required
  }) : super(key: key);

  @override
  _SizeModalState createState() => _SizeModalState();
}

class _SizeModalState extends State<SizeModal> with SingleTickerProviderStateMixin {
  String? selectedOption;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.initialSelection;

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

  void _selectOption(String option) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedOption = option;
    });

    if (widget.onSelect != null) {
      widget.onSelect!(option);
    }
  }

  void _closeModal() {
    HapticFeedback.lightImpact();
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
          backgroundColor:
              Colors.transparent, // Keep the background transparent
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 100),
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.15),
                          blurRadius: 12,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header and size options remain unchanged
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 24),
                              // Title
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Select Variety',
                                    style: const TextStyle(
                                      fontFamily: 'Gabarito',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF272727),
                                    ),
                                    semanticsLabel: 'Size selection dialog',
                                  ),
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
                                    child: AppIcons.arrowDownIcon(
                                      // Replace with the appropriate "X" icon from AppIcons
                                      color: const Color(
                                        0xFF272727,
                                      ), // Set the desired color
                                      size: 24, // Set the desired size
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Size options
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            child: Column(
                              children:
                                  widget.options.map((option) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: option != widget.options.last ? 16 : 0,
                                      ),
                                      child: SizeOption(
                                        size: option,
                                        isSelected: selectedOption == option,
                                        onTap: () => _selectOption(option),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A selectable size option button for the size selection modal.
class SizeOption extends StatelessWidget {
  /// The size label (e.g., S, M, L)
  final String size;

  /// Whether this option is currently selected
  final bool isSelected;

  /// Callback when this option is tapped
  final VoidCallback onTap;

  const SizeOption({
    Key? key,
    required this.size,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFA3636) : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              fontFamily: 'Circular Std',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF272727),
            ),
            semanticsLabel: '$size size option',
          ),
        ),
      ),
    );
  }
}
