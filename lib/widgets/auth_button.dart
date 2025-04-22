import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  final bool isPrimary;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            if (icon != null)
              Positioned(
                left: 48,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: icon!,
                ),
              ),
            Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Circular Std',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 27 / 16,
                  letterSpacing: -0.496,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}