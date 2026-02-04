import 'package:flutter/material.dart';

/// Shared app colors and theme for Test Bank.
class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color primary = Color(0xFFb51837);
  static const Color primaryDark = Color(0xFF661c3a);
  static const Color primaryDarker = Color(0xFF301939);
  static const Color linkBlue = Color(0xFF034071);

  /// Gradient used on onboarding, signin, signup headers.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, primaryDark, primaryDarker],
    begin: Alignment.topLeft,
    end: Alignment.topRight,
  );

  /// Gradient for primary buttons (e.g. SIGN IN, SIGN UP submit).
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, primaryDark, primaryDarker],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.white60, width: 2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
