import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardRouterScreen extends StatelessWidget {
  final String userId;

  const DashboardRouterScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.hasError) {
              return const _DashboardStatusScreen(
                title: 'Dashboard unavailable',
                subtitle:
                    'We could not load your dashboard right now. Please try again.',
                isLoading: false,
              );
            }

            if (!snapshot.hasData) {
              return const _DashboardStatusScreen(
                title: 'Loading dashboard',
                subtitle: 'Preparing your role-based view...',
                isLoading: true,
              );
            }

            final Map<String, dynamic> data =
                snapshot.data!.data() ?? <String, dynamic>{};
            final String role = _normalizedRole(data['role']);
            final String displayName = _displayNameFromData(data);

            switch (role) {
              case 'special_family':
                return _SpecialFamilyDashboard(displayName: displayName);
              case 'community_advocate':
                return _CommunityDashboard(displayName: displayName);
              case 'first_responder':
                return _FirstResponderDashboard(displayName: displayName);
              default:
                return _RoleSelectionDashboard(
                  userId: userId,
                  displayName: displayName,
                );
            }
          },
    );
  }

  String _displayNameFromData(Map<String, dynamic> data) {
    final String? fullName = data['fullName'] as String?;
    final String? displayName = data['displayName'] as String?;
    final String picked = (fullName ?? displayName ?? '').trim();
    if (picked.isEmpty) {
      return 'there';
    }
    final List<String> parts = picked.split(' ');
    return parts.first.trim();
  }

  String _normalizedRole(Object? roleRaw) {
    final String role = (roleRaw as String? ?? '').trim().toLowerCase();
    switch (role) {
      case 'special_family':
      case 'special families':
      case 'care_partner':
      case 'care partner':
      case 'caregiver':
      case 'caregivers':
        return 'special_family';
      case 'community_advocate':
      case 'community advocates':
      case 'connected_community':
      case 'connected community':
      case 'community':
        return 'community_advocate';
      case 'first_responder':
      case 'first responders':
      case 'law_enforcement':
      case 'law enforcement':
      case 'police':
        return 'first_responder';
      default:
        return '';
    }
  }
}

class _RoleSelectionDashboard extends StatefulWidget {
  final String userId;
  final String displayName;

  const _RoleSelectionDashboard({
    required this.userId,
    required this.displayName,
  });

  @override
  State<_RoleSelectionDashboard> createState() =>
      _RoleSelectionDashboardState();
}

class _RoleSelectionDashboardState extends State<_RoleSelectionDashboard> {
  bool _isSaving = false;
  String _selectedRole = '';

  Future<void> _setRole(String role) async {
    setState(() {
      _isSaving = true;
      _selectedRole = role;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set(<String, dynamic>{
            'uid': widget.userId,
            'role': role,
            'status': 'active',
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message ?? e.code}')),
      );
      setState(() {
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save role right now.')),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose Dashboard',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Welcome, ${widget.displayName}. Select the dashboard that matches your role.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475467),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              _RoleChoiceCard(
                title: 'Special Families',
                subtitle:
                    'For parents, close family/friends, and support partners.',
                icon: Icons.family_restroom,
                accent: const Color(0xFF2563EB),
                onTap: _isSaving ? null : () => _setRole('special_family'),
                isLoading:
                    _isSaving && _selectedRole.trim() == 'special_family',
              ),
              const SizedBox(height: 10),
              _RoleChoiceCard(
                title: 'Connected Community',
                subtitle:
                    'For trusted advocates supporting special needs families.',
                icon: Icons.people,
                accent: const Color(0xFF0EA5E9),
                onTap: _isSaving ? null : () => _setRole('community_advocate'),
                isLoading:
                    _isSaving && _selectedRole.trim() == 'community_advocate',
              ),
              const SizedBox(height: 10),
              _RoleChoiceCard(
                title: 'First Responders',
                subtitle: 'For law enforcement and emergency responders.',
                icon: Icons.local_police_rounded,
                accent: const Color(0xFF1E40AF),
                onTap: _isSaving ? null : () => _setRole('first_responder'),
                isLoading:
                    _isSaving && _selectedRole.trim() == 'first_responder',
              ),
              const SizedBox(height: 14),
              const Text(
                'You can change your role later in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final bool isLoading;

  const _RoleChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8E2F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475467),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF98A2B3),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStatusScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLoading;

  const _DashboardStatusScreen({
    required this.title,
    required this.subtitle,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                )
              else
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialFamilyDashboard extends StatelessWidget {
  final String displayName;

  const _SpecialFamilyDashboard({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return _DashboardShell(
      title: 'Special Families',
      subtitle: 'Welcome back, $displayName',
      accent: const Color(0xFF2563EB),
      stats: const [
        _DashboardStat(label: 'Profiles', value: '3'),
        _DashboardStat(label: 'Alerts', value: '1'),
        _DashboardStat(label: 'Contacts', value: '6'),
      ],
      actions: const [
        _DashboardAction(icon: Icons.warning_rounded, label: 'Send Alert'),
        _DashboardAction(icon: Icons.location_on, label: 'Share Location'),
        _DashboardAction(icon: Icons.edit_note, label: 'Update Profile'),
      ],
      timelineTitle: 'Today',
      timelineItems: const [
        _TimelineItem(
          title: 'Medication reminder',
          subtitle: '8:00 AM • Completed',
        ),
        _TimelineItem(title: 'Wellness check', subtitle: '1:30 PM • Scheduled'),
        _TimelineItem(
          title: 'School pickup window',
          subtitle: '3:15 PM • Upcoming',
        ),
      ],
    );
  }
}

class _CommunityDashboard extends StatelessWidget {
  final String displayName;

  const _CommunityDashboard({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return _DashboardShell(
      title: 'Connected Community',
      subtitle: 'Good to see you, $displayName',
      accent: const Color(0xFF0EA5E9),
      stats: const [
        _DashboardStat(label: 'Families', value: '12'),
        _DashboardStat(label: 'Check-ins', value: '5'),
        _DashboardStat(label: 'Requests', value: '2'),
      ],
      actions: const [
        _DashboardAction(icon: Icons.campaign, label: 'Community Update'),
        _DashboardAction(icon: Icons.support_agent, label: 'Support Queue'),
        _DashboardAction(icon: Icons.map, label: 'Coverage Map'),
      ],
      timelineTitle: 'Priority Follow-ups',
      timelineItems: const [
        _TimelineItem(
          title: 'Family A follow-up call',
          subtitle: 'Requested 20 minutes ago',
        ),
        _TimelineItem(
          title: 'Resource referral pending',
          subtitle: 'Due this afternoon',
        ),
        _TimelineItem(
          title: 'Neighborhood check-in',
          subtitle: 'Starts at 4:00 PM',
        ),
      ],
    );
  }
}

class _FirstResponderDashboard extends StatelessWidget {
  final String displayName;

  const _FirstResponderDashboard({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return _DashboardShell(
      title: 'First Responders',
      subtitle: 'Shift overview, $displayName',
      accent: const Color(0xFF1E40AF),
      stats: const [
        _DashboardStat(label: 'Active Calls', value: '2'),
        _DashboardStat(label: 'Nearby Profiles', value: '7'),
        _DashboardStat(label: 'Avg Response', value: '6m'),
      ],
      actions: const [
        _DashboardAction(icon: Icons.emergency, label: 'Incident Feed'),
        _DashboardAction(icon: Icons.badge, label: 'Profile Lookup'),
        _DashboardAction(icon: Icons.route, label: 'Dispatch Route'),
      ],
      timelineTitle: 'Recent Alerts',
      timelineItems: const [
        _TimelineItem(
          title: 'Priority alert acknowledged',
          subtitle: 'Downtown • 5 minutes ago',
        ),
        _TimelineItem(
          title: 'Welfare check assigned',
          subtitle: 'West District • En route',
        ),
        _TimelineItem(
          title: 'Safety profile requested',
          subtitle: 'North Sector • Pending',
        ),
      ],
    );
  }
}

class _DashboardShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final List<_DashboardStat> stats;
  final List<_DashboardAction> actions;
  final String timelineTitle;
  final List<_TimelineItem> timelineItems;

  const _DashboardShell({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.stats,
    required this.actions,
    required this.timelineTitle,
    required this.timelineItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD8E2F0)),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: stats
                    .map(
                      (final _DashboardStat stat) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD8E2F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.value,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stat.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF667085),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              ...actions.map(
                (final _DashboardAction action) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8E2F0)),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(action.icon, color: accent, size: 18),
                    ),
                    title: Text(
                      action.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timelineTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              ...timelineItems.map(
                (final _TimelineItem item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8E2F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStat {
  final String label;
  final String value;

  const _DashboardStat({required this.label, required this.value});
}

class _DashboardAction {
  final IconData icon;
  final String label;

  const _DashboardAction({required this.icon, required this.label});
}

class _TimelineItem {
  final String title;
  final String subtitle;

  const _TimelineItem({required this.title, required this.subtitle});
}
