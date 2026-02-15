import 'package:flutter/material.dart';

import 'privacy_policy_screen.dart';

class AccessibilityPolicyScreen extends StatelessWidget {
  const AccessibilityPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyScaffold(
      title: 'Accessibility Policy',
      sections: [
        PolicySection(
          heading: 'Commitment',
          body:
              'HALO is built to support users with diverse communication, cognitive, and sensory needs through clear layouts, guided interactions, and readable content.',
        ),
        PolicySection(
          heading: 'Design Principles',
          body:
              'We prioritize legible typography, meaningful color contrast, clear navigation patterns, and role-based flows that reduce confusion during high-stress moments.',
        ),
        PolicySection(
          heading: 'Ongoing Improvements',
          body:
              'Accessibility is continuously reviewed as features evolve. We test usability and iterate on controls, labels, and content clarity.',
        ),
        PolicySection(
          heading: 'Feedback',
          body:
              'If you encounter an accessibility barrier, please contact support so we can prioritize fixes and improve the experience for everyone.',
        ),
      ],
    );
  }
}
