import 'package:flutter/material.dart';

class AppTheme {
  // Main Colors - Keep it simple!
  static const Color primary = Color(0xFF4CAF50);      // Green
  static const Color secondary = Color(0xFFFF6B6B);    // Coral
  static const Color background = Colors.white;         // White
  static const Color surface = Color(0xFFFFFFFF);      // White

  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);     // Dark text
  static const Color textGrey = Color(0xFF7F8C8D);     // Grey text
  static const Color textLight = Color(0xFFBDC3C7);    // Light text

  // Status Colors
  static const Color success = Color(0xFF27AE60);      // Green
  static const Color warning = Color(0xFFF39C12);      // Orange
  static const Color error = Color(0xFFE74C3C);        // Red

  // Simple Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: error,
      ),

      // Simple button style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),

      // Simple input style
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),

      fontFamily: 'Inter',
    );
  }
}

// Simple Text Styles
class AppText {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppTheme.textDark,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppTheme.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppTheme.textDark,
  );

  static const TextStyle small = TextStyle(
    fontSize: 14,
    color: AppTheme.textGrey,
  );
}

// Simple Spacing
class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

// Simple Border Radius
class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
}
