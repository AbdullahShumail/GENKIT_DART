import 'package:flutter/material.dart';

class OnboardingTheme {
  OnboardingTheme._();

  static const Color background = Color(0xFFF9F9F9); // Very light grey/off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111111); // Deep off-black
  static const Color textSecondary = Color(0xFF666666);
  static const Color border = Color(0xFFE5E5E5);
  
  // No cyan/purple. Pure elegant monochrome for buttons.
  static const Color buttonBackground = Color(0xFF111111);
  static const Color buttonText = Color(0xFFFFFFFF);
}
