import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedModal extends StatefulWidget {
  final String title;
  final List<String> options;
  final Function(String)? onSelect;

  const AnimatedModal({
    Key? key,
    required this.title,
    required this.options,
    this.onSelect,
  }) : super(key: key);

  @override
  _AnimatedModalState createState() => _AnimatedModalState();
}

class _AnimatedModalState extends State<AnimatedModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 100),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                  // Modal Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontFamily: 'Gabarito',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF272727),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Color(0xFF272727),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Options List
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        children:
                            widget.options.map((option) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      option != widget.options.last ? 16 : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () => _selectOption(option),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedOption == option
                                              ? const Color(0xFFFA3636)
                                              : const Color(0xFFF4F4F4),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontFamily: 'Circular Std',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              selectedOption == option
                                                  ? Colors.white
                                                  : const Color(0xFF272727),
                                        ),
                                      ),
                                    ),
                                  ),
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
        );
      },
    );
  }
}
