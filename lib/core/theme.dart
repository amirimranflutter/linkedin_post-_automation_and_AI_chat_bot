import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF0A66C2),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A66C2),
          secondary: Color(0xFF004182),
          surface: Color(0xFF1E1E1E),
          onSurface: Color(0xFFE8F0FE),
          onPrimary: Colors.white,
          error: Color(0xFFC05A00),
          tertiary: Color(0xFF1A7F37),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE8F0FE),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF004182), width: 1),
          ),
          elevation: 0,
        ),
      );
}
