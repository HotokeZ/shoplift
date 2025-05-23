import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom icon painters for the application
class AppIcons {
  // SVG-based icons
  static const String arrowDown = '''
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M10.6733 8.56668L8.92664 10.3133C8.4133 10.8267 7.5733 10.8267 7.05997 10.3133L2.71997 5.96667M13.28 5.96667L12.5866 6.66001" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static const String bag = '''
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M4.99988 5.11336V4.4667C4.99988 2.9667 6.20655 1.49336 7.70655 1.35336..." stroke="currentColor" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static const String search = '''
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M7.66658 1.33337C11.1666 1.33337 13.9999 4.16671 13.9999 7.66671C13.9999 11.1667 11.1666 14 7.66658 14..." stroke="#272727" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static const String cart = '''
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M6 6H21L20 10H7L6 6ZM7 10L6 18H20L21 10H7ZM9 21C8.44772 21 8 20.5523 8 20C8 19.4477 8.44772 19 9 19C9.55228 19 10 19.4477 10 20C10 20.5523 9.55228 21 9 21ZM17 21C16.4477 21 16 20.5523 16 20C16 19.4477 16.4477 19 17 19C17.5523 19 18 19.4477 18 20C18 20.5523 17.5523 21 17 21Z" 
      stroke="#272727" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static Widget home = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M22 10.498C22 9.28803 21.19 7.73803 20.2 7.04803L14.02 2.71803C12.62 1.73803 10.37 1.78803 9.02 2.83803..." stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget notification = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12.6667 6.441V9.771M21.2567 15.17C21.9867 16.39 21.4067 17.97 20.0567 18.42..." stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget receipt = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M20.5 7.04C20.5 3.01 19.56 2 15.78 2H8.22C4.44 2 3.5 3.01 3.5 7.04..." stroke="#FA3636" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget profile = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M15.68 3.96C16.16 4.67 16.44 5.52 16.44 6.44C16.43 8.84 14.54 10.79 12.16 10.87..." stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget arrowRight = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12.9 7.94001L15.52 10.56C16.29 11.33 16.29 12.59 15.52 13.36L9 19.87M9 4.04001L10.04 5.08001" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget creditCard = SvgPicture.string(
    '''<svg width="24" height="16" viewBox="0 0 24 16" fill="none" xmlns="http://www.w3.org/2000/svg">
      <circle cx="8" cy="8" r="8" fill="#F4BD2F"></circle>
      <circle cx="16" cy="8" r="8" fill="#FA3636"></circle>
    </svg>''',
    width: 24,
    height: 16,
  );

  // CustomPainter-based icons
  static CustomPainter get backArrow => _BackArrowPainter();
  static CustomPainter get heartPainter => _HeartPainter();
  static CustomPainter get downArrow => _DownArrowPainter();
  static CustomPainter get plus => _PlusPainter();
  static CustomPainter get minus => _MinusPainter();

  /// Back arrow icon
  static Widget backArrowIcon({
    Color color = const Color(0xFF272727),
    double size = 16,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: BackArrowPainter(color: color),
    );
  }

  /// Minus icon for quantity decrease
  static Widget minusIcon({Color color = Colors.white, double size = 12}) {
    return CustomPaint(
      size: Size(size, size),
      painter: MinusPainter(color: color),
    );
  }

  /// Plus icon for quantity increase
  static Widget plusIcon({Color color = Colors.white, double size = 12}) {
    return CustomPaint(
      size: Size(size, size),
      painter: PlusPainter(color: color),
    );
  }

  /// Forward arrow icon
  static Widget forwardArrowIcon({
    Color color = Colors.white,
    double size = 16,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: ForwardArrowPainter(color: color),
    );
  }

  /// Discount icon
  static Widget discountIcon({
    Color color = const Color(0xFF5FB567),
    double size = 24,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: DiscountPainter(color: color),
    );
  }

  /// Search icon (Magnifying Glass)
  static Widget searchIcon({
    Color color = const Color(0xFF272727),
    double size = 16,
  }) {
    return SvgPicture.string(
      '''
      <svg width="$size" height="$size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="11" cy="11" r="7" stroke="$color" stroke-width="2" />
        <line x1="16" y1="16" x2="20" y2="20" stroke="$color" stroke-width="2" stroke-linecap="round" />
      </svg>
      ''',
      width: size,
      height: size,
    );
  }

  /// Forward arrow icon
  static Widget forwardArrow({Color color = Colors.white, double size = 16}) {
    return CustomPaint(
      size: Size(size, size),
      painter: ForwardArrowPainter(color: color),
    );
  }

  /// Discount icon
  static Widget discount({
    Color color = const Color(0xFF5FB567),
    double size = 24,
  }) {
    return CustomPaint(
      size: Size(size, size),
      painter: DiscountPainter(color: color),
    );
  }

  /// Arrow Down Icon
  static Widget arrowDownIcon({
    Color color = const Color(0xFF272727),
    double size = 16,
    bool isDown = true,
  }) {
    return Transform.rotate(
      angle: isDown ? 0 : 3.14159, // Rotate 180 degrees if not down
      child: SvgPicture.string(
        '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M10.6733 8.56668L8.92664 10.3133C8.4133 10.8267 7.5733 10.8267 7.05997 10.3133L2.71997 5.96667M13.28 5.96667L12.5866 6.66001" 
          stroke="currentColor" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>''',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    ));
  }

  static Widget heart = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 21C-8 8 6-3 12 5C18-3 32 8 12 21Z" stroke="#FF0000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget filledHeart = SvgPicture.string(
    '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M13.7267 3.31454C14.3133 3.97454 14.6667 4.8412 14.6667 5.79454C14.6667 10.4612 10.3467 13.2145 8.41334 13.8812C8.18668 13.9612 7.81334 13.9612 7.58668 13.8812C5.65334 13.2145 1.33334 10.4612 1.33334 5.79454C1.33334 3.73454 2.99334 2.06787 5.04001 2.06787C6.25334 2.06787 7.32668 2.65454 8.00001 3.5612C8.34253 3.09845 8.78866 2.72235 9.30267 2.46303C9.81669 2.20371 10.3843 2.06838 10.96 2.06787" fill="#FA3636"></path>
    </svg>''',
    width: 16,
    height: 16,
  );

  static Widget filledHeartIcon({
    Color color = const Color(0xFFFA3636),
    double size = 16,
  }) {
    return SvgPicture.string(
      '''<svg width="$size" height="$size" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M13.7267 3.31454C14.3133 3.97454 14.6667 4.8412 14.6667 5.79454C14.6667 10.4612 10.3467 13.2145 8.41334 13.8812C8.18668 13.9612 7.81334 13.9612 7.58668 13.8812C5.65334 13.2145 1.33334 10.4612 1.33334 5.79454C1.33334 3.73454 2.99334 2.06787 5.04001 2.06787C6.25334 2.06787 7.32668 2.65454 8.00001 3.5612C8.34253 3.09845 8.78866 2.72235 9.30267 2.46303C9.81669 2.20371 10.3843 2.06838 10.96 2.06787" fill="$color"></path>
      </svg>''',
      width: size,
      height: size,
    );
  }
}

/// Custom painter for back arrow icon
class _BackArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF272727)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path =
        Path()
          ..moveTo(size.width * 0.466, size.height * 0.331)
          ..lineTo(size.width * 0.357, size.height * 0.44)
          ..lineTo(size.width * 0.629, size.height * 0.828)
          ..moveTo(size.width * 0.629, size.height * 0.168)
          ..lineTo(size.width * 0.585, size.height * 0.212);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for heart icon
class _HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF272727)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path =
        Path()
          ..moveTo(size.width * 0.858, size.height * 0.207)
          ..cubicTo(
            size.width * 0.896,
            size.height * 0.248,
            size.width * 0.917,
            size.height * 0.303,
            size.width * 0.917,
            size.height * 0.362,
          )
          ..cubicTo(
            size.width * 0.917,
            size.height * 0.654,
            size.width * 0.647,
            size.height * 0.826,
            size.width * 0.526,
            size.height * 0.868,
          )
          ..cubicTo(
            size.width * 0.512,
            size.height * 0.873,
            size.width * 0.488,
            size.height * 0.873,
            size.width * 0.474,
            size.height * 0.868,
          )
          ..cubicTo(
            size.width * 0.353,
            size.height * 0.826,
            size.width * 0.083,
            size.height * 0.654,
            size.width * 0.083,
            size.height * 0.362,
          )
          ..cubicTo(
            size.width * 0.083,
            size.height * 0.233,
            size.width * 0.187,
            size.height * 0.129,
            size.width * 0.315,
            size.height * 0.129,
          )
          ..cubicTo(
            size.width * 0.391,
            size.height * 0.129,
            size.width * 0.458,
            size.height * 0.166,
            size.width * 0.5,
            size.height * 0.223,
          )
          ..cubicTo(
            size.width * 0.521,
            size.height * 0.194,
            size.width * 0.549,
            size.height * 0.17,
            size.width * 0.582,
            size.height * 0.154,
          )
          ..cubicTo(
            size.width * 0.614,
            size.height * 0.138,
            size.width * 0.649,
            size.height * 0.129,
            size.width * 0.685,
            size.height * 0.129,
          );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for down arrow icon
class _DownArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF272727)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path =
        Path()
          ..moveTo(size.width * 0.667, size.height * 0.535)
          ..lineTo(size.width * 0.558, size.height * 0.644)
          ..lineTo(size.width * 0.441, size.height * 0.644)
          ..moveTo(size.width * 0.17, size.height * 0.373)
          ..lineTo(size.width * 0.787, size.height * 0.373);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for plus icon
class _PlusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // Horizontal line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for minus icon
class _MinusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // Horizontal line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the back arrow icon
class BackArrowPainter extends CustomPainter {
  final Color color;

  BackArrowPainter({this.color = const Color(0xFF272727)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path =
        Path()
          // First part of the arrow (top diagonal line)
          ..moveTo(10.06, 2.69336)
          ..lineTo(9.36664, 3.38669)
          // Middle part of the arrow (horizontal line)
          ..moveTo(7.45997, 5.29336)
          ..lineTo(5.71331, 7.04003)
          // Arrow head and bottom part
          ..moveTo(5.71331, 7.04003)
          ..lineTo(5.71331, 8.90669)
          ..lineTo(10.06, 13.2534);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for minus icon
class MinusPainter extends CustomPainter {
  final Color color;

  MinusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for plus icon
class PlusPainter extends CustomPainter {
  final Color color;

  PlusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // Horizontal line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for forward arrow icon
class ForwardArrowPainter extends CustomPainter {
  final Color color;

  ForwardArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path =
        Path()
          ..moveTo(size.width * 0.538, size.height * 0.331)
          ..lineTo(size.width * 0.647, size.height * 0.44)
          ..lineTo(size.width * 0.375, size.height * 0.828);

    final path2 =
        Path()
          ..moveTo(size.width * 0.375, size.height * 0.168)
          ..lineTo(size.width * 0.418, size.height * 0.212);

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for discount icon
class DiscountPainter extends CustomPainter {
  final Color color;

  DiscountPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // Main shape paths
    final path1 =
        Path()
          ..moveTo(size.width * 0.611, size.height * 0.834)
          ..lineTo(size.width * 0.548, size.height * 0.897)
          ..lineTo(size.width * 0.453, size.height * 0.897)
          ..lineTo(size.width * 0.39, size.height * 0.834)
          ..lineTo(size.width * 0.343, size.height * 0.814)
          ..lineTo(size.width * 0.253, size.height * 0.814)
          ..lineTo(size.width * 0.187, size.height * 0.748)
          ..lineTo(size.width * 0.187, size.height * 0.658)
          ..lineTo(size.width * 0.167, size.height * 0.611)
          ..lineTo(size.width * 0.104, size.height * 0.548)
          ..lineTo(size.width * 0.104, size.height * 0.453)
          ..lineTo(size.width * 0.167, size.height * 0.39)
          ..lineTo(size.width * 0.187, size.height * 0.343)
          ..lineTo(size.width * 0.187, size.height * 0.253)
          ..lineTo(size.width * 0.253, size.height * 0.187);

    final path2 =
        Path()
          ..moveTo(size.width * 0.389, size.height * 0.166)
          ..lineTo(size.width * 0.453, size.height * 0.103)
          ..lineTo(size.width * 0.547, size.height * 0.103)
          ..lineTo(size.width * 0.61, size.height * 0.166)
          ..lineTo(size.width * 0.657, size.height * 0.186)
          ..lineTo(size.width * 0.747, size.height * 0.186)
          ..lineTo(size.width * 0.813, size.height * 0.252)
          ..lineTo(size.width * 0.813, size.height * 0.342)
          ..lineTo(size.width * 0.833, size.height * 0.389)
          ..lineTo(size.width * 0.896, size.height * 0.452)
          ..lineTo(size.width * 0.896, size.height * 0.547)
          ..lineTo(size.width * 0.833, size.height * 0.61)
          ..lineTo(size.width * 0.813, size.height * 0.657)
          ..lineTo(size.width * 0.813, size.height * 0.747)
          ..lineTo(size.width * 0.747, size.height * 0.813);

    // Diagonal line
    final path3 =
        Path()
          ..moveTo(size.width * 0.375, size.height * 0.625)
          ..lineTo(size.width * 0.625, size.height * 0.375);

    // Dots
    final path4 =
        Path()..addOval(
          Rect.fromCircle(
            center: Offset(size.width * 0.604, size.height * 0.604),
            radius: size.width * 0.02,
          ),
        );

    final path5 =
        Path()..addOval(
          Rect.fromCircle(
            center: Offset(size.width * 0.396, size.height * 0.396),
            radius: size.width * 0.02,
          ),
        );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);

    // Draw dots with thicker stroke
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

    canvas.drawPath(path4, dotPaint);
    canvas.drawPath(path5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// filepath: c:\Users\justz\OneDrive\Desktop\Code\Shoplift\shoplift\lib\widgets\circular_icon_button.dart


class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const CircularIconButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.size = 40.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
