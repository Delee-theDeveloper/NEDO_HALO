import 'package:flutter/material.dart';
import 'core/theme.dart'; // EXACT
import 'screens/halo_intro_screen.dart';

void main() {
  runApp(const NedoHaloApp());
}

class NedoHaloApp extends StatelessWidget {
  const NedoHaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEDO HALO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.myHaloTheme,
      home: const HaloIntroScreen(),
    );
  }
}
