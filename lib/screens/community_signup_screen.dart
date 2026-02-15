import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunitySignupScreen extends StatefulWidget {
  final String? initialEmail;

  const CommunitySignupScreen({super.key, this.initialEmail});

  @override
  State<CommunitySignupScreen> createState() => _CommunitySignupScreenState();
}

class _CommunitySignupScreenState extends State<CommunitySignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _preferredNameController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _specialNeedsAdditionalController =
      TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyRelationController =
      TextEditingController();

  bool _autismSpectrum = false;
  bool _nonVerbal = false;
  bool _sensorySensitivities = false;
  bool _otherNeeds = false;

  bool _consentShare = false;
  bool _consentTerms = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if ((widget.initialEmail ?? '').trim().isNotEmpty) {
      _emailController.text = widget.initialEmail!.trim();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _preferredNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _specialNeedsAdditionalController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (selected == null) {
      return;
    }
    final String mm = selected.month.toString().padLeft(2, '0');
    final String dd = selected.day.toString().padLeft(2, '0');
    final String yyyy = selected.year.toString();
    setState(() {
      _dobController.text = '$mm/$dd/$yyyy';
    });
  }

  Future<void> _saveCommunityProfile() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (!_consentShare || !_consentTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to both consent checkboxes to continue.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final Map<String, dynamic> profileData = <String, dynamic>{
      'role': 'community_advocate',
      'fullName': _fullNameController.text.trim(),
      'preferredName': _preferredNameController.text.trim(),
      'dateOfBirth': _dobController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'homeAddress': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zipCode': _zipController.text.trim(),
      'specialNeeds': <String, dynamic>{
        'autismSpectrum': _autismSpectrum,
        'nonVerbalOrLimitedSpeech': _nonVerbal,
        'sensorySensitivities': _sensorySensitivities,
        'other': _otherNeeds,
        'additionalInfo': _specialNeedsAdditionalController.text.trim(),
      },
      'emergencyContact': <String, dynamic>{
        'name': _emergencyNameController.text.trim(),
        'phone': _emergencyPhoneController.text.trim(),
        'relationship': _emergencyRelationController.text.trim(),
      },
      'consentShareWithLawEnforcement': _consentShare,
      'consentTermsPrivacy': _consentTerms,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(<String, dynamic>{
              ...profileData,
              'uid': user.uid,
              'status': 'active',
              'profileCompleted': true,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance
            .collection('community_users')
            .add(<String, dynamic>{
              ...profileData,
              'status': 'pending_auth',
              'profileCompleted': true,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community profile saved successfully.')),
      );
      Navigator.of(context).maybePop(true);
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: ${e.message ?? e.code}')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save profile right now.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF344054),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF22C55E)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F4EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.of(context).maybePop(false),
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 17,
                              color: Color(0xFF475467),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Community Advocate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Create Your Profile',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Help us set up your profile with your information',
                      style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _progressDot(true),
                        _progressLine(),
                        _progressDot(true),
                        _progressLine(),
                        _progressDot(false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 86,
                                height: 86,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 26,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add profile photo (optional)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _label('Full Name *'),
                    TextFormField(
                      controller: _fullNameController,
                      validator: (String? value) =>
                          _required(value, 'Full Name'),
                      decoration: _inputDecoration(
                        hintText: 'Enter your full name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _label('Preferred Name'),
                    TextFormField(
                      controller: _preferredNameController,
                      decoration: _inputDecoration(
                        hintText: 'What should we call you?',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _label('Date of Birth *'),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      validator: (String? value) =>
                          _required(value, 'Date of Birth'),
                      decoration: _inputDecoration(
                        hintText: 'mm/dd/yyyy',
                        suffixIcon: IconButton(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, size: 16),
                        ),
                      ),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 10),
                    _label('Phone Number *'),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (String? value) =>
                          _required(value, 'Phone Number'),
                      decoration: _inputDecoration(
                        hintText: '+1 (555) 123-4567',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _label('Email Address *'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? value) =>
                          _required(value, 'Email Address'),
                      decoration: _inputDecoration(
                        hintText: 'your.email@example.com',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _label('Home Address *'),
                    TextFormField(
                      controller: _addressController,
                      validator: (String? value) =>
                          _required(value, 'Home Address'),
                      decoration: _inputDecoration(hintText: 'Street address'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            validator: (String? value) =>
                                _required(value, 'City'),
                            decoration: _inputDecoration(hintText: 'City'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            validator: (String? value) =>
                                _required(value, 'State'),
                            decoration: _inputDecoration(hintText: 'State'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _zipController,
                      keyboardType: TextInputType.number,
                      validator: (String? value) =>
                          _required(value, 'ZIP Code'),
                      decoration: _inputDecoration(hintText: 'ZIP Code'),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFFAF3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFB7E4C7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                size: 14,
                                color: Color(0xFF15803D),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Special Needs Information',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF14532D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _autismSpectrum,
                            onChanged: (bool? v) =>
                                setState(() => _autismSpectrum = v ?? false),
                            title: const Text(
                              'Autism Spectrum Disorder',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _nonVerbal,
                            onChanged: (bool? v) =>
                                setState(() => _nonVerbal = v ?? false),
                            title: const Text(
                              'Non-verbal or limited speech',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _sensorySensitivities,
                            onChanged: (bool? v) => setState(
                              () => _sensorySensitivities = v ?? false,
                            ),
                            title: const Text(
                              'Sensory sensitivities',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _otherNeeds,
                            onChanged: (bool? v) =>
                                setState(() => _otherNeeds = v ?? false),
                            title: const Text(
                              'Other (specify below)',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          TextFormField(
                            controller: _specialNeedsAdditionalController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              hintText:
                                  'Additional information that first responders should know...',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF5FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 13,
                                color: Color(0xFF1D4ED8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Emergency Contact',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emergencyNameController,
                            validator: (String? value) =>
                                _required(value, 'Emergency Contact name'),
                            decoration: _inputDecoration(
                              hintText: 'Contact name',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emergencyPhoneController,
                            keyboardType: TextInputType.phone,
                            validator: (String? value) =>
                                _required(value, 'Emergency Contact phone'),
                            decoration: _inputDecoration(
                              hintText: 'Contact phone number',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emergencyRelationController,
                            validator: (String? value) => _required(
                              value,
                              'Emergency Contact relationship',
                            ),
                            decoration: _inputDecoration(
                              hintText: 'Relationship',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _consentShare,
                      onChanged: (bool? v) =>
                          setState(() => _consentShare = v ?? false),
                      title: const Text(
                        'I consent to sharing my profile information with law enforcement during emergencies',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _consentTerms,
                      onChanged: (bool? v) =>
                          setState(() => _consentTerms = v ?? false),
                      title: const Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveCommunityProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue to Safety Settings',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, size: 15),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Step 2 of 3 • Profile Setup',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        '✓ Your information is encrypted and secure',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressDot(bool active) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _progressLine() {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: const Color(0xFFD1D5DB),
    );
  }
}
