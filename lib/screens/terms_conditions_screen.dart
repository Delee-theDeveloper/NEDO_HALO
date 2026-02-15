import 'package:flutter/material.dart';

import 'privacy_policy_screen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyScaffold(
      title: 'Terms & Conditions',
      sections: [
        PolicySection(
          heading: 'Acceptance',
          body:
              'By using HALO, you agree to use the app responsibly and according to applicable laws and safety practices in your region.',
        ),
        PolicySection(
          heading: 'Account Responsibilities',
          body:
              'You are responsible for keeping account credentials secure and ensuring role assignments and shared profile data remain accurate.',
        ),
        PolicySection(
          heading: 'Appropriate Use',
          body:
              'HALO supports safety coordination and communications. You agree not to misuse alerts, impersonate responders, or access profiles without authorization.',
        ),
        PolicySection(
          heading: 'Service Updates',
          body:
              'Features may evolve to improve reliability, usability, and compliance. Continued use after updates indicates acceptance of current terms.',
        ),
      ],
    );
  }
}
