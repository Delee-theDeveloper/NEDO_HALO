import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData myHaloTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2563EB),
    scaffoldBackgroundColor: Colors.white,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.45,
        color: Color(0xFF1F2937),
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: 0.2,
        color: Color(0xFF0D1B2A),
      ),
    ),
  );
}
