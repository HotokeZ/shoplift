import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import '../constants/app_colors.dart';
import '../widgets/custom_back_button.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class LoginPasswordScreen extends StatefulWidget {
  final String email; // Accept email as a parameter
  const LoginPasswordScreen({super.key, required this.email});

  @override
  _LoginPasswordScreenState createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;
  bool _isLoading = false; // Add this state variable

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorText = 'Password cannot be empty';
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  Future<void> _signIn() async {
    final password = _passwordController.text.trim();
    _validatePassword();

    if (_errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorText!)));
      return;
    }

    // Set loading state to true when sign-in starts
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with Firebase Authentication using email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: widget.email, password: password);

      if (userCredential.user != null) {
        print('Firebase Authentication successful for user: ${userCredential.user!.uid}');

        // Wait for Firebase data to be fully available
        await Future.delayed(Duration(milliseconds: 500));

        if (!mounted) return;

        // Navigate to the home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // Clear the navigation stack
        );
      }
    } catch (e) {
      // Set loading state back to false when there's an error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      print('Error during login: $e');
      String errorMessage = 'Login failed. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          default:
            errorMessage = 'Error: ${e.message}';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: CustomBackButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width > 991
                            ? 20
                            : MediaQuery.of(context).size.width > 640
                            ? 15
                            : 10,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Sign in',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Circular Std',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 34.5 / 32,
                            letterSpacing: -0.408,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 344),
                        child: Column(
                          children: [
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                errorText: _errorText,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) => _validatePassword(),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _isLoading ? null : _signIn, // Disable when loading
                              style: TextButton.styleFrom(
                                backgroundColor: _isLoading ? AppColors.primary.withOpacity(0.7) : AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 49,
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: _isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Continue',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.5,
                                          height: 2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                              ),
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
    );
  }
}
