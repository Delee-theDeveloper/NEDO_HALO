import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyScaffold(
      title: 'Privacy Policy',
      sections: [
        PolicySection(
          heading: 'Overview',
          body:
              'HALO is designed to support safety workflows for individuals, families, and responders. We collect only the data needed to operate core safety features and improve reliability.',
        ),
        PolicySection(
          heading: 'Data We Use',
          body:
              'Data may include account details, profile context, device identifiers, and feature usage events. If location-based features are enabled, location data is used only for those workflows.',
        ),
        PolicySection(
          heading: 'How Data Is Used',
          body:
              'Information is used to deliver alerts, enable role-based access, and provide communications and support tools. Data is not sold to third parties.',
        ),
        PolicySection(
          heading: 'Your Controls',
          body:
              'You can manage role access, notification settings, and available profile information in app settings. You may also request account support for data-related questions.',
        ),
      ],
    );
  }
}

class PolicyScaffold extends StatelessWidget {
  final String title;
  final List<PolicySection> sections;

  const PolicyScaffold({required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2939),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: sections
            .map(
              (PolicySection section) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.heading,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D2939),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section.body,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Color(0xFF475467),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class PolicySection {
  final String heading;
  final String body;

  const PolicySection({required this.heading, required this.body});
}
