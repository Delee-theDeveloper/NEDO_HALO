import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData myHaloTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Orbitron',
    primaryColor: const Color(0xFF4AB3FF),
    scaffoldBackgroundColor: Colors.white,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
    ),
  );
}
