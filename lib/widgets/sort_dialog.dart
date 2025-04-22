import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class SortDialog extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onClear;
  final Function(String)? onOptionSelected;

  const SortDialog({
    Key? key,
    this.onClose,
    this.onClear,
    this.onOptionSelected,
  }) : super(key: key);

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  String _selectedOption = 'Recommended';

  Widget _buildCloseIcon() {
    return CustomPaint(
      size: const Size(16, 16),
      painter: CloseIconPainter(),
    );
  }

  Widget _buildCheckIcon() {
    return CustomPaint(
      size: const Size(16, 16),
      painter: CheckIconPainter(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.onClear,
            child: Semantics(
              button: true,
              label: 'Clear selection',
              child: const Text(
                'Clear',
                style: ThemeConstants.actionStyle,
              ),
            ),
          ),
          const Text(
            'Sort by',
            style: ThemeConstants.titleStyle,
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Semantics(
              button: true,
              label: 'Close dialog',
              child: _buildCloseIcon(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String title, {bool isRecommended = false}) {
    final isSelected = _selectedOption == title;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedOption = title);
        widget.onOptionSelected?.call(title);
      },
      child: Semantics(
        button: true,
        selected: isSelected,
        label: 'Sort by $title',
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ThemeConstants.optionPadding,
            horizontal: 34,
          ),
          decoration: BoxDecoration(
            color: ThemeConstants.optionBackground,
            borderRadius: BorderRadius.circular(
              isRecommended ? ThemeConstants.recommendedBorderRadius : ThemeConstants.optionBorderRadius,
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: ThemeConstants.optionStyle,
              ),
              if (isSelected && isRecommended) ...[
                const SizedBox(width: 8),
                _buildCheckIcon(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth <= 640;

        return Container(
          width: isSmallScreen ? double.infinity : constraints.maxWidth * 0.9,
          height: isSmallScreen ? double.infinity : null,
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          decoration: BoxDecoration(
            color: ThemeConstants.backgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.dialogBorderRadius),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.all(ThemeConstants.dialogPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: ThemeConstants.headerSpacing),
              Column(
                children: [
                  _buildOption('Recommended', isRecommended: true),
                  const SizedBox(height: ThemeConstants.optionSpacing),
                  _buildOption('Newest'),
                  const SizedBox(height: ThemeConstants.optionSpacing),
                  _buildOption('Lowest - Highest Price'),
                  const SizedBox(height: ThemeConstants.optionSpacing),
                  _buildOption('Highest - Lowest Price'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class CloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeConstants.primaryText
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CheckIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}