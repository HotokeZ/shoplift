import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 991 ? 20 :
                         MediaQuery.of(context).size.width > 640 ? 15 : 10,
            ),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.width > 640 ? 103 : 60),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7),
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
                ),
                const SizedBox(height: 32),
                Container(
                  constraints: const BoxConstraints(maxWidth: 344),
                  child: Column(
                    children: [
                      const CustomTextField(placeholder: 'Email Address'),
                      const SizedBox(height: 16),
                      AuthButton(
                        text: 'Continue',
                        onPressed: () {},
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
                            const TextSpan(text: 'Dont have an Account ? '),
                            TextSpan(
                              text: 'Create One',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width > 640 ? 71 : 50),
                Container(
                  constraints: const BoxConstraints(maxWidth: 344),
                  child: Column(
                    children: [
                      AuthButton(
                        text: 'Continue With Apple',
                        onPressed: () {},
                        icon: Image.asset('assets/images/apple_icon.png'),
                      ),
                      const SizedBox(height: 12),
                      AuthButton(
                        text: 'Continue With Google',
                        onPressed: () {},
                        icon: Image.network('https://cdn.builder.io/api/v1/image/assets/TEMP/b7f1fc019a1a1c8710584408a8eed3b54c7811cc'),
                      ),
                      const SizedBox(height: 12),
                      AuthButton(
                        text: 'Continue With Facebook',
                        onPressed: () {},
                        icon: Image.network('https://cdn.builder.io/api/v1/image/assets/TEMP/f416f19d2c5e0c08c273b7d141c7979e40afbc3c'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}