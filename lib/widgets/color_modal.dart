import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoplift/utils/app_icons.dart'; // Import AppIcons

/// A modal dialog for selecting colors.
class ColorModal extends StatefulWidget {
  /// Callback function when a color is selected
  final Function(String, Color)? onSelect;

  /// Callback function when the modal is closed
  final VoidCallback? onClose;

  /// Initial selected color (if any)
  final String? initialSelection;

  const ColorModal({
    Key? key,
    this.onSelect,
    this.onClose,
    this.initialSelection,
  }) : super(key: key);

  @override
  _ColorModalState createState() => _ColorModalState();
}

class _ColorModalState extends State<ColorModal>
    with SingleTickerProviderStateMixin {
  String? selectedColor;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Define color options
  final List<Map<String, dynamic>> colorOptions = [
    {'id': '6', 'name': 'Orange', 'color': const Color(0xFFEC6D26)},
    {'id': '9', 'name': 'Black', 'color': const Color(0xFF272727)},
    {'id': '12', 'name': 'Red', 'color': const Color(0xFFFA3636)},
    {'id': '15', 'name': 'Yellow', 'color': const Color(0xFFF4BD2F)},
    {'id': '18', 'name': 'Blue', 'color': const Color(0xFF4468E5)},
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialSelection;

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

  void _selectColor(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedColor = id;
    });

    final selectedOption = colorOptions.firstWhere(
      (option) => option['id'] == id,
    );

    // Removed the SnackBar
    if (widget.onSelect != null) {
      widget.onSelect!(selectedOption['name'], selectedOption['color']);
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
                        // Header and color options remain unchanged
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
                                    'Color',
                                    style: const TextStyle(
                                      fontFamily: 'Gabarito',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF272727),
                                    ),
                                    semanticsLabel: 'Color selection dialog',
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
                                    child: AppIcons.arrowDownIcon( // Replace with the appropriate "X" icon from AppIcons
                                      color: const Color(0xFF272727), // Set the desired color
                                      size: 24, // Set the desired size
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Color options
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            child: Column(
                              children:
                                  colorOptions.map((option) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: option['id'] != '18' ? 16 : 0,
                                      ),
                                      child: ColorOption(
                                        id: option['id'],
                                        label: option['name'],
                                        color: option['color'],
                                        isSelected:
                                            selectedColor == option['id'],
                                        onTap: () => _selectColor(option['id']),
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

/// A selectable color option button for the color selection modal.
class ColorOption extends StatefulWidget {
  /// Unique identifier for the color option
  final String id;

  /// Display name of the color
  final String label;

  /// The actual color to display
  final Color color;

  /// Whether this option is currently selected
  final bool isSelected;

  /// Callback when this option is tapped
  final VoidCallback onTap;

  const ColorOption({
    Key? key,
    required this.id,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _ColorOptionState createState() => _ColorOptionState();
}

class _ColorOptionState extends State<ColorOption> {
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 68, 18),
          decoration: BoxDecoration(
            color:
                widget.isSelected
                    ? const Color(0xFFFA3636)
                    : const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Color name
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Circular Std',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      widget.isSelected
                          ? Colors.white
                          : const Color(0xFF272727),
                ),
                semanticsLabel: '${widget.label} color option',
              ),

              // Color circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
