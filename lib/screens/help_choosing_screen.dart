import 'package:flutter/material.dart';

class HelpChoosingScreen extends StatelessWidget {
  const HelpChoosingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFEAF3FB)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(14),
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
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Need Help Choosing?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pick the role that best matches how this app will be used first. You can still change it later in settings.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: const [
                        _RoleGuideCard(
                          title: 'Caregiver',
                          subtitle:
                              'Best when you support someone else day to day.',
                          icon: Icons.favorite,
                          accentColor: Color(0xFF2563EB),
                          iconBgColor: Color(0xFFE3ECFF),
                          points: [
                            'You are a parent, guardian, or professional caregiver.',
                            'You need alerts, location updates, and profile controls.',
                            'You will manage safety settings for another person.',
                          ],
                        ),
                        SizedBox(height: 12),
                        _RoleGuideCard(
                          title: 'Individual',
                          subtitle:
                              'Best when the app supports your own routines.',
                          icon: Icons.person,
                          accentColor: Color(0xFF0EA5E9),
                          iconBgColor: Color(0xFFDDF3FF),
                          points: [
                            'You are the person using alerts and communication tools.',
                            'You want quick access to emergency actions.',
                            'You prefer a simpler, personal dashboard.',
                          ],
                        ),
                        SizedBox(height: 12),
                        _RoleGuideCard(
                          title: 'Law Enforcement',
                          subtitle:
                              'Best for first responders and authorized officers.',
                          icon: Icons.local_police_rounded,
                          accentColor: Color(0xFF1E40AF),
                          iconBgColor: Color(0xFFDCEBFF),
                          points: [
                            'You may respond to active safety alerts.',
                            'You need role-based access to shared profiles.',
                            'You coordinate with caregivers during incidents.',
                          ],
                        ),
                        SizedBox(height: 12),
                        _TipCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleGuideCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color iconBgColor;
  final List<String> points;

  const _RoleGuideCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.iconBgColor,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(195),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF475467),
                  ),
                ),
                const SizedBox(height: 8),
                ...points.map(
                  (String point) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Still unsure? Start with the role that matches your primary daily use. You can update your role later in settings.',
        style: TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF667085)),
      ),
    );
  }
}
