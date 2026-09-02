import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color scaffoldBg = Color(0xFF09090B); // Deep charcoal black
  static const Color surfaceDark = Color(0xFF1E1E22);
  static const Color textPrimary = Color(0xFFEDEDED); // Clean off-white
  static const Color textSecondary = Color(0xFFA0A0A5);
  static Color border = Colors.white.withOpacity(0.08);

  static const Color accentPrimary = Color(0xFFE0E0E0); // Silver/White accent

  static ThemeData get oledTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        surface: surfaceDark,
        background: scaffoldBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: -1.5, height: 1.1),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
      ),
    );
  }
}
