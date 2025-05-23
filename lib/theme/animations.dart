import 'package:flutter/material.dart';

/// Utility class for common animations used throughout the app
class AppAnimations {
  /// Creates a scale animation that starts from 0 and ends at 1
  static Animation<double> createScaleInAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  /// Creates a pulse animation that scales between 1.0 and the specified maxScale
  static Animation<double> createPulseAnimation(
    AnimationController controller, {
    double maxScale = 1.5,
  }) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: maxScale),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: maxScale, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Creates a fade-in animation
  static Animation<double> createFadeInAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
    );
  }

  /// Creates a slide-in animation from the bottom
  static Animation<Offset> createSlideInFromBottomAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  /// Creates a checkmark drawing animation
  static Animation<double> createCheckmarkAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }
}