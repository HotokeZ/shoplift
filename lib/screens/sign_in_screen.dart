import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../constants/app_colors.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_back_button.dart';
import 'login_password_screen.dart';
import 'create_account_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorText;

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !EmailValidator.validate(email)) {
      setState(() {
        _errorText = 'Please enter a valid email address';
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  Future<void> _signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Sign in with Firebase Authentication using email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        print(
          'Firebase Authentication successful for user: ${userCredential.user!.uid}',
        );

        // Navigate to the password screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPasswordScreen(email: email),
          ),
        );
      }
    } catch (e) {
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed. Please check your credentials.'),
        ),
      );
    }
  }

  Future<void> _checkEmailExists() async {
    final email = _emailController.text.trim().toLowerCase();

    try {
      // Query Firestore for email
      final userDoc =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userDoc.docs.isNotEmpty) {
        // Prompt user to enter password and sign in
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPasswordScreen(email: email),
          ),
        );
      } else {
        setState(() {
          _errorText = 'No account found with this email';
        });
      }
    } catch (e) {
      print('Error checking email in Firestore: $e');
      setState(() {
        _errorText = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _validateAndSignIn(String email, String password) async {
    try {
      // Check if the email exists in Firestore
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('accounts')
              .where('email', isEqualTo: email)
              .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email not found. Please register.')),
        );
        return;
      }

      final userDoc = querySnapshot.docs.first;

      // Sign in anonymously with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();

      if (password.isEmpty) {
        print('Password is empty.');
        return;
      }

      print('Attempting to sign in with email: $email and password: $password');

      if (userCredential.user != null) {
        print(
          'Firebase Authentication successful for user: ${userCredential.user!.uid}',
        );

        // Log user login success
        print('User with email $email successfully logged in.');

        // Sync Firebase UID with Firestore
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(userDoc.id)
            .update({'firebaseUid': userCredential.user!.uid});

        // Navigate to the password screen
        Navigator.pushNamed(context, '/loginPassword', arguments: email);
      } else {
        print('Firebase Authentication failed: UserCredential.user is null.');
      }
    } catch (e) {
      print('Error during sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed. Please try again.')),
      );
    }
  }

  void _navigateToPasswordScreen() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPasswordScreen(email: email),
      ),
    );
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
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                errorText: _errorText,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => _validateEmail(),
                            ),
                            const SizedBox(height: 16),
                            AuthButton(
                              text: 'Continue',
                              onPressed: () async {
                                _validateEmail();
                                if (_errorText == null) {
                                  await _checkEmailExists();
                                }
                              },
                              isPrimary: true,
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Circular Std',
                                  fontSize: 12,
                                  letterSpacing: -0.408,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Don’t have an Account? ',
                                  ),
                                  TextSpan(
                                    text: 'Create One',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const CreateAccountScreen(),
                                              ),
                                            );
                                          },
                                  ),
                                ],
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
