import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import the HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _handleAnimation();
  }

  Future<void> _handleAnimation() async {
    // Fade in
    await _animationController.forward();

    // Wait for 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));

    // Fade out
    await _animationController.reverse();

    // Navigate to HomeScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: const Color(0xFFFA3636),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double fontSize = 64.0;
                  EdgeInsets padding = const EdgeInsets.all(0);

                  // Responsive layout adjustments
                  if (constraints.maxWidth <= 640) {
                    fontSize = 32.0;
                    padding = const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    );
                  } else if (constraints.maxWidth <= 991) {
                    fontSize = 48.0;
                    padding = const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    );
                  }

                  return Padding(
                    padding: padding,
                    child: Center(
                      child: Text(
                        'Shoplift',
                        style: TextStyle(
                          fontFamily: 'Kalam',
                          fontSize: fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
