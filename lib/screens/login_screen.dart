import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'accessibility_policy_screen.dart';
import 'dashboard_router_screen.dart';
import 'forgot_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedRole;
  final String? selectedRoleLabel;

  const LoginScreen({super.key, this.selectedRole, this.selectedRoleLabel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isSigningIn = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _openTermsConditions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const TermsConditionsScreen(),
      ),
    );
  }

  void _openAccessibilityPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AccessibilityPolicyScreen(),
      ),
    );
  }

  String _mapAuthCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password login is disabled in Firebase. Enable it in Firebase Console.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes.';
      case 'user-disabled':
        return 'This account is disabled.';
      default:
        return 'Unable to sign in right now. Please try again.';
    }
  }

  String _resolvedRoleLabel() {
    final String explicit = (widget.selectedRoleLabel ?? '').trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }

    switch ((widget.selectedRole ?? '').trim()) {
      case 'special_family':
        return 'Special Families';
      case 'community_advocate':
        return 'Connected Community';
      case 'first_responder':
        return 'First Responders';
      default:
        return '';
    }
  }

  String _loginTitle() {
    final String roleLabel = _resolvedRoleLabel();
    if (roleLabel.isEmpty) {
      return 'Let\'s Login';
    }
    return '$roleLabel Login';
  }

  IconData _loginIcon() {
    switch ((widget.selectedRole ?? '').trim()) {
      case 'special_family':
        return Icons.family_restroom;
      case 'community_advocate':
        return Icons.people;
      case 'first_responder':
        return Icons.local_police_rounded;
      default:
        return Icons.lock_outline;
    }
  }

  Color _loginAccentColor() {
    switch ((widget.selectedRole ?? '').trim()) {
      case 'special_family':
        return const Color(0xFF2563EB);
      case 'community_advocate':
        return const Color(0xFF0EA5E9);
      case 'first_responder':
        return const Color(0xFF1E40AF);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Future<void> _ensureUserDoc(User user) async {
    final DocumentReference<Map<String, dynamic>> ref = FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
    final Map<String, dynamic> currentData = snap.data() ?? <String, dynamic>{};
    final String existingRole = (currentData['role'] as String? ?? '').trim();
    final String selectedRole = (widget.selectedRole ?? '').trim();
    final String selectedRoleLabel = _resolvedRoleLabel();

    final Map<String, dynamic> data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (selectedRoleLabel.isNotEmpty) {
      data['lastSelectedRoleLabel'] = selectedRoleLabel;
    }

    if (selectedRole.isNotEmpty) {
      data['lastSelectedRole'] = selectedRole;
    }

    if (existingRole.isEmpty && selectedRole.isNotEmpty) {
      data['role'] = selectedRole;
    }

    if (!snap.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['role'] = selectedRole.isNotEmpty ? selectedRole : null;
      data['status'] = 'active';
    }

    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> _signIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;
      if (user != null) {
        await _ensureUserDoc(user);
      } else {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to find this account.')),
        );
        return;
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              DashboardRouterScreen(userId: user.uid),
        ),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mapAuthCode(e.code))));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign in right now.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String selectedRoleLabel = _resolvedRoleLabel();
    final bool hasSelectedRole = selectedRoleLabel.isNotEmpty;
    final Color accentColor = _loginAccentColor();
    final IconData loginIcon = _loginIcon();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 86),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(24),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentColor.withAlpha(45),
                                ),
                              ),
                              child: Icon(
                                loginIcon,
                                color: accentColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                _loginTitle(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Sign in to continue to HALO.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                            if (selectedRoleLabel.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6EEFF),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                  ),
                                ),
                                child: Text(
                                  'User Type: $selectedRoleLabel',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE4E7EC),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF344054),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'name@example.com',
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        size: 18,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD0D5DD),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD0D5DD),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF344054),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        size: 18,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 18,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD0D5DD),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD0D5DD),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isSigningIn ? null : _signIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2563EB,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: _isSigningIn
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Center(
                                    child: TextButton(
                                      onPressed: _isSigningIn
                                          ? null
                                          : _openForgotPassword,
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475467),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 8 + keyboardInset,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _openPrivacyPolicy,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                            ),
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ),
                          const Text(
                            '|',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                          TextButton(
                            onPressed: _openTermsConditions,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                            ),
                            child: const Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ),
                          const Text(
                            '|',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                          TextButton(
                            onPressed: _openAccessibilityPolicy,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                            ),
                            child: const Text(
                              'Accessibility Policy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasSelectedRole)
                  Positioned(
                    top: 8,
                    left: 20,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: const Color(0xFFE4E7EC)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 17,
                          color: Color(0xFF475467),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
