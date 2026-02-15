import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme.dart'; // EXACT
import 'splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } on FirebaseException {
    // Firebase config files were intentionally removed and will be re-added for a new project.
  }

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
      home: const SplashPage(),
    );
  }
}
