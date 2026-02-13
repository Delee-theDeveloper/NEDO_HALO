import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'help_choosing_screen.dart';

class HaloIntroScreen extends StatelessWidget {
  const HaloIntroScreen({super.key});

  Future<void> _goBack(BuildContext context) async {
    final bool didPop = await Navigator.of(context).maybePop();
    if (!didPop &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.fuchsia)) {
      await SystemNavigator.pop();
    }
  }

  void _handleSwipeBack(BuildContext context, DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity > 350) {
      _goBack(context);
    }
  }

  void _openHelpChoosing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HelpChoosingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (DragEndDetails details) =>
            _handleSwipeBack(context, details),
        child: Container(
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
                          onPressed: () => _goBack(context),
                          icon: const _BarelyAnimatedIcon(
                            icon: Icons.arrow_back,
                            size: 17,
                            color: Color(0xFF475467),
                            phase: 0.05,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
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
                              letterSpacing: 0.3,
                              color: Color(0xFF1D2939),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 34),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Welcome to HALO',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Choose your role to get started with\npersonalized features and safety protocols.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _StepProgress(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Column(
                      children: [
                        const Expanded(
                          child: _RoleCard(
                            title: 'Caregiver',
                            description:
                                'Parent, family member, or professional caregiver',
                            icon: Icons.favorite,
                            iconBgColor: Color(0xFFE3ECFF),
                            iconColor: Color(0xFF2563EB),
                            tags: ['Safety Alerts', 'Location Tracking'],
                            tagColor: Color(0xFF2563EB),
                            phase: 0.18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Expanded(
                          child: _RoleCard(
                            title: 'Individual',
                            description: 'Person with autism or special needs',
                            icon: Icons.person,
                            iconBgColor: Color(0xFFDDF3FF),
                            iconColor: Color(0xFF0EA5E9),
                            tags: ['Emergency Button', 'Communication Aid'],
                            tagColor: Color(0xFF0EA5E9),
                            phase: 0.38,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Expanded(
                          child: _RoleCard(
                            title: 'Law Enforcement',
                            description: 'Police officer or first responder',
                            icon: Icons.local_police_rounded,
                            iconBgColor: Color(0xFFDCEBFF),
                            iconColor: Color(0xFF1E40AF),
                            tags: ['Alert Response', 'Profile Access'],
                            tagColor: Color(0xFF1E40AF),
                            phase: 0.58,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openHelpChoosing(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(165),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: _BarelyAnimatedIcon(
                              icon: Icons.help,
                              size: 14,
                              color: Color(0xFF2563EB),
                              phase: 0.72,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need help choosing?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF344054),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'You can change your role later in settings',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Color(0xFF98A2B3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Step 1 of 3 • Role Selection',
                      style: TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress();

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(active: true),
        const SizedBox(width: 6),
        _connector(),
        const SizedBox(width: 6),
        _dot(active: false),
        const SizedBox(width: 6),
        _connector(),
        const SizedBox(width: 6),
        _dot(active: false),
      ],
    );
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

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.tags,
    required this.tagColor,
    this.phase = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(190),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                    letterSpacing: -0.2,
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
            child: _BarelyAnimatedIcon(
              icon: Icons.chevron_right,
              color: const Color(0xFF98A2B3),
              size: 16,
              phase: (phase + 0.25) % 1.0,
            ),
          ),
        ],
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
