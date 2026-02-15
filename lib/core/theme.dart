import 'package:flutter/material.dart';

class AppTheme {
  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandNavy = Color(0xFF1E3A8A);
  static const Color _brandSky = Color(0xFFEAF3FF);

  static ThemeData myHaloTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: _brandBlue,
      secondary: _brandNavy,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: const Color(0xFF1F2937),
    ),
    primaryColor: _brandBlue,
    scaffoldBackgroundColor: _brandSky,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1E3A8A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: Color(0xFF1E3A8A),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brandBlue),
      ),
      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 13),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.w800,
        fontSize: 30,
        letterSpacing: 0.4,
        color: Color(0xFF1E3A8A),
      ),
      titleLarge: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: 0.3,
        color: Color(0xFF1E3A8A),
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.45,
        color: Color(0xFF1F2937),
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.45,
        color: Color(0xFF344054),
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  );
}
