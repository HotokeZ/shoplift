import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A menu item widget for the profile screen
class ProfileMenuItem extends StatefulWidget {
  /// The label text to display
  final String label;

  /// Callback function when the item is tapped
  final VoidCallback onTap;

  const ProfileMenuItem({Key? key, required this.label, required this.onTap})
    : super(key: key);

  @override
  _ProfileMenuItemState createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFEBEBEB) : AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: AppTheme.darkText,
                ),
              ),
              const ArrowRightIcon(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the arrow right icon
class ArrowRightIcon extends StatelessWidget {
  const ArrowRightIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(24, 24), painter: ArrowRightPainter());
  }
}

class ArrowRightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppTheme.darkText
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path =
        Path()
          ..moveTo(12.9, 7.94)
          ..lineTo(15.52, 10.56)
          ..arcToPoint(
            const Offset(15.52, 13.36),
            radius: const Radius.circular(1),
            largeArc: false,
          )
          ..lineTo(9, 19.87)
          ..moveTo(9, 4.04)
          ..lineTo(10.04, 5.08);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
