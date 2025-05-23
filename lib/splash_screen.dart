import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';

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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print("SplashScreen: Starting app initialization...");

    try {
      await Firebase.initializeApp();
      print("SplashScreen: Firebase initialized successfully.");
      print("SplashScreen: Initialized Firebase apps: ${Firebase.apps}");

      // Set the Firebase Authentication language code
      FirebaseAuth.instance.setLanguageCode('en');
      print("SplashScreen: FirebaseAuth language code set to 'en'.");
    } catch (e) {
      print("SplashScreen: Firebase initialization failed: $e");
    }

    await _playAnimation();
    _navigateToNext();
  }

  Future<void> _playAnimation() async {
    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    await _animationController.reverse();
  }

 void _navigateToNext() {
  if (!mounted) return;
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    print('SplashScreen: No user is logged in. Proceeding to home screen as guest.');
  } else {
    print('SplashScreen: User is logged in with UID: ${currentUser.uid}');
  }

  Navigator.pushReplacementNamed(context, '/home');
}


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Center(
              child: Text(
                'Shoplift',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
