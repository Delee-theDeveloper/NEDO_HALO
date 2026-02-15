import 'package:flutter/material.dart';

import 'community_signup_screen.dart';
import 'help_choosing_screen.dart';
import 'login_screen.dart';
import 'special_family_signup_screen.dart';

class HaloIntroScreen extends StatefulWidget {
  const HaloIntroScreen({super.key});

  @override
  State<HaloIntroScreen> createState() => _HaloIntroScreenState();
}

class _HaloIntroScreenState extends State<HaloIntroScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  int _currentPage = 0;
  String? _selectedRole;
  String? _selectedRoleLabel;
  bool _isRoutingToLogin = false;

  final List<_SlideSpec> _slides = const [
    _SlideSpec(
      title: 'Welcome to HALO',
      subtitle:
          'A simple way to protect loved ones with\npersonalized safety workflows.',
      stepLabel: 'Getting Started',
      showHelpCard: false,
      hintTitle: 'Quick tip',
      hintSubtitle: 'Swipe or tap Next to move through onboarding',
      hintIcon: Icons.info,
      hintColor: Color(0xFF2563EB),
      cards: [
        _SlideCardSpec(
          title: 'Family & Friends',
          description: 'Support tools built for special needs families',
          icon: Icons.family_restroom,
          iconBgColor: Color(0xFFE3ECFF),
          iconColor: Color(0xFF2563EB),
          tags: ['Family Support', 'Safety Plans'],
          tagColor: Color(0xFF2563EB),
          phase: 0.12,
        ),
        _SlideCardSpec(
          title: 'Connected Community',
          description:
              'Connected community advocate members who support the app',
          icon: Icons.people,
          iconBgColor: Color(0xFFDDF3FF),
          iconColor: Color(0xFF0EA5E9),
          tags: ['Community Access', 'Trusted Network'],
          tagColor: Color(0xFF0EA5E9),
          phase: 0.34,
        ),
        _SlideCardSpec(
          title: 'First Responders',
          description: 'Police and first responders equipped for safer action',
          icon: Icons.local_police_rounded,
          iconBgColor: Color(0xFFDCEBFF),
          iconColor: Color(0xFF1E40AF),
          tags: ['Police Ready', 'Rapid Response'],
          tagColor: Color(0xFF1E40AF),
          phase: 0.56,
        ),
      ],
    ),
    _SlideSpec(
      title: 'Safety That Adapts',
      subtitle:
          'HALO adjusts to your needs with role-aware\nfeatures and communication tools.',
      stepLabel: 'Core Features',
      showHelpCard: false,
      hintTitle: 'Your setup is flexible',
      hintSubtitle: 'You can always change preferences later in settings',
      hintIcon: Icons.settings,
      hintColor: Color(0xFF1E40AF),
      cards: [
        _SlideCardSpec(
          title: 'Smart Alerts',
          description: 'Reduce noise and get alerts that matter most',
          icon: Icons.notifications_active,
          iconBgColor: Color(0xFFE3ECFF),
          iconColor: Color(0xFF2563EB),
          tags: ['Priority Rules', 'Escalation'],
          tagColor: Color(0xFF2563EB),
          phase: 0.22,
        ),
        _SlideCardSpec(
          title: 'Location Awareness',
          description: 'Use live and last-known location when needed',
          icon: Icons.location_on,
          iconBgColor: Color(0xFFDDF3FF),
          iconColor: Color(0xFF0EA5E9),
          tags: ['Live Map', 'Safe Zones'],
          tagColor: Color(0xFF0EA5E9),
          phase: 0.44,
        ),
        _SlideCardSpec(
          title: 'Communication Support',
          description: 'Help share context quickly during high-stress moments',
          icon: Icons.chat_bubble,
          iconBgColor: Color(0xFFDCEBFF),
          iconColor: Color(0xFF1E40AF),
          tags: ['Quick Messages', 'Guided Prompts'],
          tagColor: Color(0xFF1E40AF),
          phase: 0.66,
        ),
      ],
    ),
    _SlideSpec(
      title: 'Choose Your Role',
      subtitle: 'Select the role that matches how you will\nuse HALO the most.',
      stepLabel: 'Role Selection',
      showHelpCard: true,
      hintTitle: 'Need help choosing?',
      hintSubtitle: 'You can change your role later in settings',
      hintIcon: Icons.help,
      hintColor: Color(0xFF2563EB),
      cards: [
        _SlideCardSpec(
          title: 'Care Partners',
          description:
              'Parent, close family/friend, or professional support partner',
          icon: Icons.favorite,
          iconBgColor: Color(0xFFE3ECFF),
          iconColor: Color(0xFF2563EB),
          tags: ['Safety Alerts', 'Location Tracking'],
          tagColor: Color(0xFF2563EB),
          phase: 0.18,
          roleValue: 'special_family',
        ),
        _SlideCardSpec(
          title: 'Community Advocates',
          description: 'Trusted community advocates for special needs families',
          icon: Icons.person,
          iconBgColor: Color(0xFFDDF3FF),
          iconColor: Color(0xFF0EA5E9),
          tags: ['Community Access', 'Family Advocacy'],
          tagColor: Color(0xFF0EA5E9),
          phase: 0.38,
          roleValue: 'community_advocate',
        ),
        _SlideCardSpec(
          title: 'Law Enforcement',
          description: 'Police officer or first responder',
          icon: Icons.local_police_rounded,
          iconBgColor: Color(0xFFDCEBFF),
          iconColor: Color(0xFF1E40AF),
          tags: ['Alert Response', 'Profile Access'],
          tagColor: Color(0xFF1E40AF),
          phase: 0.58,
          roleValue: 'first_responder',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openHelpChoosing() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HelpChoosingScreen(),
      ),
    );
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openFeaturePage({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<String> bullets,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => _FeatureDetailScreen(
          title: title,
          subtitle: subtitle,
          icon: icon,
          accentColor: accentColor,
          bullets: bullets,
        ),
      ),
    );
  }

  Future<void> _animateToPage(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _skipToLast() {
    _animateToPage(_slides.length - 1);
  }

  void _selectRole(String role, String label) {
    setState(() {
      _selectedRole = role;
      _selectedRoleLabel = label;
    });

    _startRoleSignupAndLoginFlow(role: role, label: label);
  }

  Future<void> _startRoleSignupAndLoginFlow({
    required String role,
    required String label,
  }) async {
    if (_isRoutingToLogin) {
      return;
    }

    setState(() {
      _isRoutingToLogin = true;
    });

    final bool proceedToLogin = await _openSignupForRole(role);
    if (!mounted) {
      return;
    }

    if (!proceedToLogin) {
      setState(() {
        _isRoutingToLogin = false;
      });
      return;
    }

    await _goToLogin(role: role, label: label);
    if (!mounted) {
      return;
    }

    setState(() {
      _isRoutingToLogin = false;
    });
  }

  Future<bool> _openSignupForRole(String role) async {
    switch (role.trim()) {
      case 'special_family':
        final bool? saved = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext context) => const SpecialFamilySignupScreen(),
          ),
        );
        return saved == true;
      case 'community_advocate':
        final bool? saved = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext context) => const CommunitySignupScreen(),
          ),
        );
        return saved == true;
      case 'first_responder':
        return true;
      default:
        return true;
    }
  }

  Future<void> _goToLogin({String? role, String? label}) async {
    final String? selectedRole = (role ?? _selectedRole ?? '').trim().isEmpty
        ? null
        : (role ?? _selectedRole ?? '').trim();
    final String? selectedRoleLabel =
        (label ?? _selectedRoleLabel ?? '').trim().isEmpty
        ? null
        : (label ?? _selectedRoleLabel ?? '').trim();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LoginScreen(
          selectedRole: selectedRole,
          selectedRoleLabel: selectedRoleLabel,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (_pageController.hasClients && _currentPage != _slides.length - 1) {
      await _pageController.animateToPage(
        _slides.length - 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage >= _slides.length - 1) {
      return;
    }
    _animateToPage(_currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEAF3FB),
      endDrawer: _AppMenuDrawer(
        onOverview: () => _animateToPage(0),
        onRoleSelection: () => _animateToPage(_slides.length - 1),
        onHelp: _openHelpChoosing,
        onSafetyAlerts: () => _openFeaturePage(
          title: 'Safety Alerts',
          subtitle: 'Create priority-based alerts for trusted responders.',
          icon: Icons.notifications_active,
          accentColor: const Color(0xFF2563EB),
          bullets: const [
            'Set who is alerted first during incidents.',
            'Escalate alerts automatically if no response is received.',
            'Tune notification sensitivity by scenario.',
          ],
        ),
        onLocationTracking: () => _openFeaturePage(
          title: 'Location Tracking',
          subtitle: 'Use live and last-known location when support is needed.',
          icon: Icons.location_on,
          accentColor: const Color(0xFF0EA5E9),
          bullets: const [
            'Share live location with trusted contacts.',
            'Set safe zones and receive exit/entry alerts.',
            'Review timeline history for follow-up.',
          ],
        ),
        onEmergencyButton: () => _openFeaturePage(
          title: 'Emergency Button',
          subtitle: 'Trigger immediate assistance in a single action.',
          icon: Icons.warning_rounded,
          accentColor: const Color(0xFF2563EB),
          bullets: const [
            'Send rapid alert packages with profile context.',
            'Route notifications to the right responders.',
            'Attach current location automatically.',
          ],
        ),
        onCommunicationAid: () => _openFeaturePage(
          title: 'Communication Aid',
          subtitle: 'Support clear communication during high-stress moments.',
          icon: Icons.chat_bubble,
          accentColor: const Color(0xFF0EA5E9),
          bullets: const [
            'Use guided prompts for common situations.',
            'Share pre-written quick messages instantly.',
            'Reduce confusion with structured context cards.',
          ],
        ),
        onAlertResponse: () => _openFeaturePage(
          title: 'Alert Response',
          subtitle:
              'Coordinate response workflows from first signal to closure.',
          icon: Icons.local_police_rounded,
          accentColor: const Color(0xFF1E40AF),
          bullets: const [
            'Track response status across participants.',
            'Capture timeline details for incident review.',
            'Close events with final notes and outcomes.',
          ],
        ),
        onProfileAccess: () => _openFeaturePage(
          title: 'Profile Access',
          subtitle: 'Give authorized users the right information quickly.',
          icon: Icons.badge,
          accentColor: const Color(0xFF1E40AF),
          bullets: const [
            'Store support preferences and essential details.',
            'Control access by role and trust level.',
            'Keep profile updates synchronized across devices.',
          ],
        ),
        onSettings: () => _openFeaturePage(
          title: 'Settings & Preferences',
          subtitle: 'Configure roles, alerts, and app behavior.',
          icon: Icons.settings,
          accentColor: const Color(0xFF475467),
          bullets: const [
            'Change role and personalization options.',
            'Manage notification channels and quiet hours.',
            'Update privacy and sharing controls.',
          ],
        ),
        onSupport: () => _openFeaturePage(
          title: 'Support',
          subtitle: 'Get guidance, onboarding help, and technical assistance.',
          icon: Icons.support_agent,
          accentColor: const Color(0xFF475467),
          bullets: const [
            'Open help guides for setup and usage.',
            'Contact support for account or app issues.',
            'Report feature requests and improvement ideas.',
          ],
        ),
        onAbout: () => _openFeaturePage(
          title: 'About HALO',
          subtitle: 'Learn how HALO supports safer community care.',
          icon: Icons.info_outline,
          accentColor: const Color(0xFF475467),
          bullets: const [
            'Understand the mission and product scope.',
            'Review core safety principles and workflows.',
            'See what is coming next in future updates.',
          ],
        ),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
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
              children: [
                Row(
                  children: [
                    const SizedBox(width: 34, height: 34),
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2563EB),
                              ),
                              child: Image.asset(
                                'assets/images/halo_shieldLogoWht.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'HALO',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Color(0xFF1D2939),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: _openMenu,
                          child: const Icon(
                            Icons.menu_rounded,
                            size: 18,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (BuildContext context, int index) {
                      final _SlideSpec slide = _slides[index];
                      return _OnboardingSlide(
                        slide: slide,
                        stepNumber: index + 1,
                        totalSteps: _slides.length,
                        currentStep: _currentPage,
                        selectedRole: _selectedRole,
                        onRoleSelected: index == _slides.length - 1
                            ? _selectRole
                            : null,
                        onHelpTap: slide.showHelpCard
                            ? _openHelpChoosing
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (_currentPage >= _slides.length - 1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text(
                      'Choose one of the 3 paths above to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475467),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      TextButton(
                        onPressed: _skipToLast,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _SlideSpec slide;
  final int stepNumber;
  final int totalSteps;
  final int currentStep;
  final String? selectedRole;
  final void Function(String role, String label)? onRoleSelected;
  final VoidCallback? onHelpTap;

  const _OnboardingSlide({
    required this.slide,
    required this.stepNumber,
    required this.totalSteps,
    required this.currentStep,
    required this.selectedRole,
    required this.onRoleSelected,
    required this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            slide.title,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _StepProgress(currentStep: currentStep, totalSteps: totalSteps),
        const SizedBox(height: 14),
        Expanded(
          child: Column(
            children: [
              for (int i = 0; i < slide.cards.length; i++) ...[
                Expanded(
                  child: _RoleCard(
                    title: slide.cards[i].title,
                    description: slide.cards[i].description,
                    icon: slide.cards[i].icon,
                    iconBgColor: slide.cards[i].iconBgColor,
                    iconColor: slide.cards[i].iconColor,
                    tags: slide.cards[i].tags,
                    tagColor: slide.cards[i].tagColor,
                    phase: slide.cards[i].phase,
                    onTap:
                        slide.cards[i].roleValue != null &&
                            onRoleSelected != null
                        ? () => onRoleSelected!(
                            slide.cards[i].roleValue!,
                            slide.cards[i].title,
                          )
                        : null,
                    isSelected:
                        slide.cards[i].roleValue != null &&
                        onRoleSelected != null &&
                        selectedRole == slide.cards[i].roleValue,
                  ),
                ),
                if (i < slide.cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _HintCard(
          title: slide.hintTitle,
          subtitle: slide.hintSubtitle,
          icon: slide.hintIcon,
          iconColor: slide.hintColor,
          onTap: onHelpTap,
          showChevron: slide.showHelpCard,
        ),
        const SizedBox(height: 10),
        Text(
          'Step $stepNumber of $totalSteps • ${slide.stepLabel}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
        ),
      ],
    );
  }
}

class _HintCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const _HintCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.showChevron,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(165),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF344054),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF98A2B3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppMenuDrawer extends StatelessWidget {
  final VoidCallback onOverview;
  final VoidCallback onRoleSelection;
  final VoidCallback onHelp;
  final VoidCallback onSafetyAlerts;
  final VoidCallback onLocationTracking;
  final VoidCallback onEmergencyButton;
  final VoidCallback onCommunicationAid;
  final VoidCallback onAlertResponse;
  final VoidCallback onProfileAccess;
  final VoidCallback onSettings;
  final VoidCallback onSupport;
  final VoidCallback onAbout;

  const _AppMenuDrawer({
    required this.onOverview,
    required this.onRoleSelection,
    required this.onHelp,
    required this.onSafetyAlerts,
    required this.onLocationTracking,
    required this.onEmergencyButton,
    required this.onCommunicationAid,
    required this.onAlertResponse,
    required this.onProfileAccess,
    required this.onSettings,
    required this.onSupport,
    required this.onAbout,
  });

  void _closeAndRun(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    Future<void>.delayed(const Duration(milliseconds: 180), action);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FB),
                border: Border(
                  bottom: BorderSide(color: Colors.black.withAlpha(18)),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu_rounded, color: Color(0xFF475467), size: 18),
                  SizedBox(width: 10),
                  Text(
                    'HALO Menu',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const _DrawerSectionLabel(title: 'Onboarding'),
                  ListTile(
                    leading: const Icon(
                      Icons.slideshow,
                      color: Color(0xFF475467),
                    ),
                    title: const Text('Overview'),
                    onTap: () => _closeAndRun(context, onOverview),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge, color: Color(0xFF475467)),
                    title: const Text('Role Selection'),
                    onTap: () => _closeAndRun(context, onRoleSelection),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF475467),
                    ),
                    title: const Text('Need Help Choosing'),
                    onTap: () => _closeAndRun(context, onHelp),
                  ),
                  const Divider(height: 16),
                  const _DrawerSectionLabel(title: 'Core Tools'),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text('Safety Alerts'),
                    onTap: () => _closeAndRun(context, onSafetyAlerts),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Color(0xFF0EA5E9),
                    ),
                    title: const Text('Location Tracking'),
                    onTap: () => _closeAndRun(context, onLocationTracking),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.warning_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text('Emergency Button'),
                    onTap: () => _closeAndRun(context, onEmergencyButton),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.chat_bubble,
                      color: Color(0xFF0EA5E9),
                    ),
                    title: const Text('Communication Aid'),
                    onTap: () => _closeAndRun(context, onCommunicationAid),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.local_police_rounded,
                      color: Color(0xFF1E40AF),
                    ),
                    title: const Text('Alert Response'),
                    onTap: () => _closeAndRun(context, onAlertResponse),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge, color: Color(0xFF1E40AF)),
                    title: const Text('Profile Access'),
                    onTap: () => _closeAndRun(context, onProfileAccess),
                  ),
                  const Divider(height: 16),
                  const _DrawerSectionLabel(title: 'App'),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Color(0xFF475467),
                    ),
                    title: const Text('Settings & Preferences'),
                    onTap: () => _closeAndRun(context, onSettings),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.support_agent,
                      color: Color(0xFF475467),
                    ),
                    title: const Text('Support'),
                    onTap: () => _closeAndRun(context, onSupport),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF475467),
                    ),
                    title: const Text('About HALO'),
                    onTap: () => _closeAndRun(context, onAbout),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  final String title;

  const _DrawerSectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Color(0xFF98A2B3),
        ),
      ),
    );
  }
}

class _FeatureDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<String> bullets;

  const _FeatureDetailScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFEAF3FB)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final String bullet in bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF344054),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepProgress({required this.currentStep, required this.totalSteps});

  Widget _dot({required bool active}) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : const Color(0xFFD0D5DD),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _connector() {
    return Container(
      width: 20,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFFD0D5DD),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < totalSteps; i++) {
      children.add(_dot(active: i == currentStep));
      if (i < totalSteps - 1) {
        children.add(const SizedBox(width: 6));
        children.add(_connector());
        children.add(const SizedBox(width: 6));
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final List<String> tags;
  final Color tagColor;
  final double phase;
  final VoidCallback? onTap;
  final bool isSelected;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.tags,
    required this.tagColor,
    this.phase = 0,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(190),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? iconColor : const Color(0xFFE4E7EC),
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? iconColor.withAlpha(36)
                : Colors.black.withAlpha(12),
            blurRadius: isSelected ? 12 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _BarelyAnimatedIcon(
                  icon: icon,
                  color: iconColor,
                  size: 18,
                  phase: phase,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF475467),
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags
                      .map(
                        (String tag) => _TagChip(label: tag, color: tagColor),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: onTap == null
                ? _BarelyAnimatedIcon(
                    icon: Icons.chevron_right,
                    color: const Color(0xFF98A2B3),
                    size: 16,
                    phase: (phase + 0.25) % 1.0,
                  )
                : Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? iconColor : const Color(0xFF98A2B3),
                    size: 18,
                  ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _BarelyAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double phase;

  const _BarelyAnimatedIcon({
    required this.icon,
    required this.color,
    required this.size,
    this.phase = 0.0,
  });

  @override
  State<_BarelyAnimatedIcon> createState() => _BarelyAnimatedIconState();
}

class _BarelyAnimatedIconState extends State<_BarelyAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    final double initialPhase = widget.phase < 0
        ? 0
        : (widget.phase > 1 ? 1 : widget.phase);
    _controller.value = initialPhase;
    _controller.repeat();

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.025), weight: 16),
      TweenSequenceItem(tween: Tween(begin: 1.025, end: 1.0), weight: 16),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 68),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}

class _SlideSpec {
  final String title;
  final String subtitle;
  final String stepLabel;
  final List<_SlideCardSpec> cards;
  final bool showHelpCard;
  final String hintTitle;
  final String hintSubtitle;
  final IconData hintIcon;
  final Color hintColor;

  const _SlideSpec({
    required this.title,
    required this.subtitle,
    required this.stepLabel,
    required this.cards,
    required this.showHelpCard,
    required this.hintTitle,
    required this.hintSubtitle,
    required this.hintIcon,
    required this.hintColor,
  });
}

class _SlideCardSpec {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final List<String> tags;
  final Color tagColor;
  final double phase;
  final String? roleValue;

  const _SlideCardSpec({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.tags,
    required this.tagColor,
    required this.phase,
    this.roleValue,
  });
}
