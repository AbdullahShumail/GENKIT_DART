import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Color Palette (Premium Light Mode) ────────────────────
  static const Color scaffoldBg = Color(0xFFF8FAFC); // Very light gray/blue
  static const Color surfaceDark = Color(0xFFFFFFFF); // White for cards
  static const Color surfaceLight = Color(0xFFF1F5F9); // Slightly darker background
  static const Color cardColor = Color(0xFFFFFFFF);

  // Accent gradient — fresh royal blue to cyan
  static const Color accentPrimary = Color(0xFF3B82F6); // Blue
  static const Color accentSecondary = Color(0xFF0EA5E9); // Sky blue

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A); // Almost black
  static const Color textSecondary = Color(0xFF475569); // Medium gray
  static const Color textMuted = Color(0xFF94A3B8); // Light gray

  // User bubble gradient
  static const LinearGradient userBubbleGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], // Smooth blue gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color aiBubbleColor = Color(0xFFFFFFFF); // White AI bubbles
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Border Radius ──────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  // ─── Shadows ────────────────────────────────────────────
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: accentPrimary.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];
      
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  // ─── ThemeData ──────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: surfaceDark,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
