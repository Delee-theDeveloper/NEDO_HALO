import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_preference_keys.dart';
import 'screens/halo_intro_screen.dart';
import 'screens/login_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _routeFromSplash();
  }

  Future<void> _routeFromSplash() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding =
        prefs.getBool(AppPreferenceKeys.hasSeenOnboarding) ?? false;
    final String selectedRole =
        prefs.getString(AppPreferenceKeys.selectedRole)?.trim() ?? '';
    final String selectedRoleLabel =
        prefs.getString(AppPreferenceKeys.selectedRoleLabel)?.trim() ?? '';

    if (!mounted) {
      return;
    }

    final Widget destination = hasSeenOnboarding
        ? LoginScreen(
            selectedRole: selectedRole.isEmpty ? null : selectedRole,
            selectedRoleLabel: selectedRoleLabel.isEmpty
                ? null
                : selectedRoleLabel,
          )
        : const HaloIntroScreen();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/nedo_halo_logo.png'),
          width: 220,
        ),
      ),
    );
  }
}
