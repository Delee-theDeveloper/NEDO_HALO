import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_subscription_screen.dart';

class SpecialFamilySignupScreen extends StatefulWidget {
  final String? initialEmail;

  const SpecialFamilySignupScreen({super.key, this.initialEmail});

  @override
  State<SpecialFamilySignupScreen> createState() =>
      _SpecialFamilySignupScreenState();
}

class _SpecialFamilySignupScreenState extends State<SpecialFamilySignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final TextEditingController _primaryEmergencyNameController =
      TextEditingController();
  final TextEditingController _primaryEmergencyPhoneController =
      TextEditingController();
  final TextEditingController _secondaryEmergencyNameController =
      TextEditingController();
  final TextEditingController _secondaryEmergencyPhoneController =
      TextEditingController();
  final TextEditingController _closeFriendOneNameController =
      TextEditingController();
  final TextEditingController _closeFriendOnePhoneController =
      TextEditingController();
  final TextEditingController _closeFriendTwoNameController =
      TextEditingController();
  final TextEditingController _closeFriendTwoPhoneController =
      TextEditingController();

  final List<_SpecialNeedsProfileEntry> _profiles = <_SpecialNeedsProfileEntry>[
    _SpecialNeedsProfileEntry(),
  ];

  Uint8List? _userAvatarBytes;
  String? _userAvatarFileName;

  Uint8List? _primaryEmergencyAvatarBytes;
  String? _primaryEmergencyAvatarFileName;
  Uint8List? _secondaryEmergencyAvatarBytes;
  String? _secondaryEmergencyAvatarFileName;

  Uint8List? _closeFriendOneAvatarBytes;
  String? _closeFriendOneAvatarFileName;
  Uint8List? _closeFriendTwoAvatarBytes;
  String? _closeFriendTwoAvatarFileName;

  bool _showSecondaryEmergency = false;
  bool _showAdditionalCloseFriend = false;
  bool _emergencyAlerts = true;
  bool _locationUpdates = true;
  bool _checkInReminders = false;

  bool _consentShare = false;
  bool _consentTerms = false;
  bool _isSaving = false;
  int _currentSetupStep = 0;
  bool _hasAdditionalProfileSubscription = false;

  String _relationship = 'Parent';

  static const List<String> _relationshipOptions = <String>[
    'Parent',
    'Legal Guardian',
    'Sibling',
    'Grandparent',
    'Other Family',
  ];

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
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _primaryEmergencyNameController.dispose();
    _primaryEmergencyPhoneController.dispose();
    _secondaryEmergencyNameController.dispose();
    _secondaryEmergencyPhoneController.dispose();
    _closeFriendOneNameController.dispose();
    _closeFriendOnePhoneController.dispose();
    _closeFriendTwoNameController.dispose();
    _closeFriendTwoPhoneController.dispose();

    for (final _SpecialNeedsProfileEntry profile in _profiles) {
      profile.dispose();
    }

    super.dispose();
  }

  String? _required(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required';
    }
    return null;
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
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0EA5E9)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.4),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFF0369A1),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: Color(0xFF344054),
        ),
      ),
    );
  }

  String _safeName(String fileName) {
    final String cleaned = fileName.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    if (cleaned.isEmpty) {
      return 'image.jpg';
    }
    return cleaned;
  }

  Future<void> _pickImage(
    void Function(Uint8List bytes, String fileName) onPicked,
  ) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1280,
      );
      if (picked == null) {
        return;
      }

      final Uint8List bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected image is empty.')),
        );
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        onPicked(bytes, _safeName(picked.name));
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pick image right now.')),
      );
    }
  }

  Future<String?> _uploadImageBytes({
    required Uint8List? bytes,
    required String ownerKey,
    required String folder,
    required String fileName,
  }) async {
    if (bytes == null) {
      return null;
    }

    final String safeFileName = _safeName(fileName);
    final String path =
        'profile_images/$ownerKey/$folder/${DateTime.now().microsecondsSinceEpoch}_$safeFileName';
    final Reference ref = FirebaseStorage.instance.ref().child(path);

    final TaskSnapshot snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return snapshot.ref.getDownloadURL();
  }

  bool _hasAnyText(Iterable<TextEditingController> controllers) {
    for (final TextEditingController controller in controllers) {
      if (controller.text.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  String? _validateImageRequirements() {
    if (_userAvatarBytes == null) {
      return 'Please upload your photo.';
    }

    if (_primaryEmergencyAvatarBytes == null) {
      return 'Please upload a photo for the primary emergency contact.';
    }

    if (_showSecondaryEmergency &&
        _hasAnyText(<TextEditingController>[
          _secondaryEmergencyNameController,
          _secondaryEmergencyPhoneController,
        ]) &&
        _secondaryEmergencyAvatarBytes == null) {
      return 'Please upload a photo for the secondary emergency contact.';
    }

    if (_hasAnyText(<TextEditingController>[
          _closeFriendOneNameController,
          _closeFriendOnePhoneController,
        ]) &&
        _closeFriendOneAvatarBytes == null) {
      return 'Please upload a photo for Close Friend 1.';
    }

    if (_hasAnyText(<TextEditingController>[
          _closeFriendTwoNameController,
          _closeFriendTwoPhoneController,
        ]) &&
        _showAdditionalCloseFriend &&
        _closeFriendTwoAvatarBytes == null) {
      return 'Please upload a photo for Close Friend 2.';
    }

    for (int i = 0; i < _profiles.length; i++) {
      if (_profiles[i].photoBytes == null) {
        return 'Please upload a photo for Profile ${i + 1}.';
      }
    }

    return null;
  }

  String? _validateFamilyImageRequirements() {
    if (_userAvatarBytes == null) {
      return 'Please upload your photo.';
    }

    if (_primaryEmergencyAvatarBytes == null) {
      return 'Please upload a photo for the primary emergency contact.';
    }

    if (_showSecondaryEmergency &&
        _hasAnyText(<TextEditingController>[
          _secondaryEmergencyNameController,
          _secondaryEmergencyPhoneController,
        ]) &&
        _secondaryEmergencyAvatarBytes == null) {
      return 'Please upload a photo for the secondary emergency contact.';
    }

    if (_hasAnyText(<TextEditingController>[
          _closeFriendOneNameController,
          _closeFriendOnePhoneController,
        ]) &&
        _closeFriendOneAvatarBytes == null) {
      return 'Please upload a photo for Close Friend 1.';
    }

    if (_hasAnyText(<TextEditingController>[
          _closeFriendTwoNameController,
          _closeFriendTwoPhoneController,
        ]) &&
        _showAdditionalCloseFriend &&
        _closeFriendTwoAvatarBytes == null) {
      return 'Please upload a photo for Close Friend 2.';
    }

    return null;
  }

  void _goToSpecialNeedsSetup() {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final String? familyImageError = _validateFamilyImageRequirements();
    if (familyImageError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(familyImageError)));
      return;
    }

    setState(() {
      _currentSetupStep = 1;
    });
  }

  Widget _imagePickerField({
    required String label,
    required String helperText,
    required IconData emptyIcon,
    required Uint8List? imageBytes,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD0D5DD)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EEF9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: ClipOval(
                  child: imageBytes == null
                      ? Icon(
                          emptyIcon,
                          color: const Color(0xFF1D4ED8),
                          size: 24,
                        )
                      : Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      helperText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onPick,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF93C5FD)),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.upload, size: 14),
                          label: Text(
                            imageBytes == null ? 'Upload' : 'Change',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        if (imageBytes != null)
                          TextButton(
                            onPressed: onClear,
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Remove',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _primaryAvatarPicker() {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  _pickImage((Uint8List bytes, String fileName) {
                    _userAvatarBytes = bytes;
                    _userAvatarFileName = fileName;
                  });
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EEF9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _userAvatarBytes == null
                        ? const Icon(
                            Icons.person_outline,
                            size: 38,
                            color: Color(0xFF1D4ED8),
                          )
                        : Image.memory(_userAvatarBytes!, fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: GestureDetector(
                  onTap: () {
                    _pickImage((Uint8List bytes, String fileName) {
                      _userAvatarBytes = bytes;
                      _userAvatarFileName = fileName;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add profile photo',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '(required)',
          style: TextStyle(fontSize: 10, color: Color(0xFF98A2B3)),
        ),
        if (_userAvatarBytes != null) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              setState(() {
                _userAvatarBytes = null;
                _userAvatarFileName = null;
              });
            },
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            child: const Text(
              'Remove photo',
              style: TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickProfileDob(_SpecialNeedsProfileEntry entry) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 10, now.month, now.day);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected == null || !mounted) {
      return;
    }

    final String mm = selected.month.toString().padLeft(2, '0');
    final String dd = selected.day.toString().padLeft(2, '0');
    final String yyyy = selected.year.toString();

    setState(() {
      entry.dateOfBirthController.text = '$mm/$dd/$yyyy';
    });
  }

  void _addSpecialNeedsProfile() {
    setState(() {
      _profiles.add(_SpecialNeedsProfileEntry());
    });
  }

  Future<void> _onAddAdditionalProfilePressed() async {
    if (_hasAdditionalProfileSubscription) {
      _addSpecialNeedsProfile();
      return;
    }

    final bool purchased =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (BuildContext context) =>
                const ProfileSubscriptionScreen(),
          ),
        ) ??
        false;

    if (!mounted) {
      return;
    }

    if (!purchased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription is required to unlock additional profiles.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _hasAdditionalProfileSubscription = true;
      _profiles.add(_SpecialNeedsProfileEntry());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription unlocked. You can add extra profiles now.'),
      ),
    );
  }

  void _removeSpecialNeedsProfile(int index) {
    if (index <= 0 || index >= _profiles.length) {
      return;
    }

    setState(() {
      final _SpecialNeedsProfileEntry removed = _profiles.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _saveSpecialFamilyProfile() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (_profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one special needs profile.'),
        ),
      );
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

    final String? imageValidationError = _validateImageRequirements();
    if (imageValidationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(imageValidationError)));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      final String ownerKey =
          user?.uid ?? 'pending_${DateTime.now().millisecondsSinceEpoch}';

      final String? userAvatarUrl = await _uploadImageBytes(
        bytes: _userAvatarBytes,
        ownerKey: ownerKey,
        folder: 'family',
        fileName: _userAvatarFileName ?? 'user_avatar.jpg',
      );

      final String? primaryEmergencyAvatarUrl = await _uploadImageBytes(
        bytes: _primaryEmergencyAvatarBytes,
        ownerKey: ownerKey,
        folder: 'contacts/primary',
        fileName: _primaryEmergencyAvatarFileName ?? 'primary_contact.jpg',
      );

      String? secondaryEmergencyAvatarUrl;
      if (_showSecondaryEmergency &&
          _hasAnyText(<TextEditingController>[
            _secondaryEmergencyNameController,
            _secondaryEmergencyPhoneController,
          ])) {
        secondaryEmergencyAvatarUrl = await _uploadImageBytes(
          bytes: _secondaryEmergencyAvatarBytes,
          ownerKey: ownerKey,
          folder: 'contacts/secondary',
          fileName:
              _secondaryEmergencyAvatarFileName ?? 'secondary_contact.jpg',
        );
      }

      String? closeFriendOneAvatarUrl;
      final bool hasCloseFriendOne =
          _hasAnyText(<TextEditingController>[
            _closeFriendOneNameController,
            _closeFriendOnePhoneController,
          ]) ||
          _closeFriendOneAvatarBytes != null;
      if (hasCloseFriendOne) {
        closeFriendOneAvatarUrl = await _uploadImageBytes(
          bytes: _closeFriendOneAvatarBytes,
          ownerKey: ownerKey,
          folder: 'contacts/close_friend_1',
          fileName: _closeFriendOneAvatarFileName ?? 'close_friend_1.jpg',
        );
      }

      String? closeFriendTwoAvatarUrl;
      final bool hasCloseFriendTwo =
          _showAdditionalCloseFriend &&
          (_hasAnyText(<TextEditingController>[
                _closeFriendTwoNameController,
                _closeFriendTwoPhoneController,
              ]) ||
              _closeFriendTwoAvatarBytes != null);
      if (hasCloseFriendTwo) {
        closeFriendTwoAvatarUrl = await _uploadImageBytes(
          bytes: _closeFriendTwoAvatarBytes,
          ownerKey: ownerKey,
          folder: 'contacts/close_friend_2',
          fileName: _closeFriendTwoAvatarFileName ?? 'close_friend_2.jpg',
        );
      }

      final List<Map<String, dynamic>> closeFriends = <Map<String, dynamic>>[];
      if (hasCloseFriendOne) {
        closeFriends.add(<String, dynamic>{
          'name': _closeFriendOneNameController.text.trim(),
          'phone': _closeFriendOnePhoneController.text.trim(),
          'avatarUrl': closeFriendOneAvatarUrl,
        });
      }
      if (hasCloseFriendTwo) {
        closeFriends.add(<String, dynamic>{
          'name': _closeFriendTwoNameController.text.trim(),
          'phone': _closeFriendTwoPhoneController.text.trim(),
          'avatarUrl': closeFriendTwoAvatarUrl,
        });
      }

      final List<Map<String, dynamic>> specialNeedsProfiles =
          <Map<String, dynamic>>[];
      for (int i = 0; i < _profiles.length; i++) {
        final _SpecialNeedsProfileEntry profile = _profiles[i];
        final String? specialNeedsAvatarUrl = await _uploadImageBytes(
          bytes: profile.photoBytes,
          ownerKey: ownerKey,
          folder: 'special_needs/profile_${i + 1}',
          fileName: profile.photoFileName ?? 'special_needs_${i + 1}.jpg',
        );
        specialNeedsProfiles.add(
          profile.toMap(photoUrl: specialNeedsAvatarUrl),
        );
      }

      final Map<String, dynamic> profileData = <String, dynamic>{
        'role': 'special_family',
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'relationshipToIndividual': _relationship,
        'homeAddress': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipController.text.trim(),
        'avatarUrl': userAvatarUrl,
        'specialNeedsProfiles': specialNeedsProfiles,
        'emergencyContacts': <String, dynamic>{
          'primary': <String, dynamic>{
            'name': _primaryEmergencyNameController.text.trim(),
            'phone': _primaryEmergencyPhoneController.text.trim(),
            'avatarUrl': primaryEmergencyAvatarUrl,
          },
          'secondary': _showSecondaryEmergency
              ? <String, dynamic>{
                  'name': _secondaryEmergencyNameController.text.trim(),
                  'phone': _secondaryEmergencyPhoneController.text.trim(),
                  'avatarUrl': secondaryEmergencyAvatarUrl,
                }
              : null,
        },
        'closeFriends': closeFriends,
        'notificationPreferences': <String, dynamic>{
          'emergencyAlerts': _emergencyAlerts,
          'locationUpdates': _locationUpdates,
          'checkInReminders': _checkInReminders,
        },
        'consentShareWithLawEnforcement': _consentShare,
        'consentTermsPrivacy': _consentTerms,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(<String, dynamic>{
              ...profileData,
              'uid': user.uid,
              'status': 'active',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance
            .collection('special_family_users')
            .add(<String, dynamic>{
              ...profileData,
              'status': 'pending_auth',
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Special family profile saved successfully.'),
        ),
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

  Widget _progressDot(bool active) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
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

  Widget _toggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2563EB),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _profileCard(int index, _SpecialNeedsProfileEntry entry) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Profile ${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              const Spacer(),
              if (index > 0)
                TextButton.icon(
                  onPressed: () => _removeSpecialNeedsProfile(index),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 14,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _imagePickerField(
            label: 'Profile Photo *',
            helperText:
                'Upload a clear photo of this special needs individual or loved one.',
            emptyIcon: Icons.person_outline,
            imageBytes: entry.photoBytes,
            onPick: () {
              _pickImage((Uint8List bytes, String fileName) {
                entry.photoBytes = bytes;
                entry.photoFileName = fileName;
              });
            },
            onClear: () {
              setState(() {
                entry.photoBytes = null;
                entry.photoFileName = null;
              });
            },
          ),
          const SizedBox(height: 8),
          _label('Name *'),
          TextFormField(
            controller: entry.nameController,
            validator: (String? value) => _required(value, 'Profile name'),
            decoration: _inputDecoration(hintText: 'Full name'),
          ),
          const SizedBox(height: 8),
          _label('Relationship *'),
          TextFormField(
            controller: entry.relationshipController,
            validator: (String? value) =>
                _required(value, 'Profile relationship'),
            decoration: _inputDecoration(
              hintText: 'Special needs individual / close family / friend',
            ),
          ),
          const SizedBox(height: 8),
          _label('Date of Birth *'),
          TextFormField(
            controller: entry.dateOfBirthController,
            readOnly: true,
            validator: (String? value) => _required(value, 'Date of Birth'),
            decoration: _inputDecoration(
              hintText: 'mm/dd/yyyy',
              suffixIcon: IconButton(
                onPressed: () => _pickProfileDob(entry),
                icon: const Icon(Icons.calendar_today, size: 16),
              ),
            ),
            onTap: () => _pickProfileDob(entry),
          ),
          const SizedBox(height: 8),
          _label('Primary Condition / Diagnosis *'),
          TextFormField(
            controller: entry.diagnosisController,
            validator: (String? value) => _required(value, 'Diagnosis'),
            decoration: _inputDecoration(
              hintText: 'Autism Spectrum Disorder, developmental disability…',
            ),
          ),
          const SizedBox(height: 8),
          _label('Special Needs Indicators (Customizable)'),
          const Text(
            'Add personalized indicators because every person is different.',
            style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < entry.indicatorControllers.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: entry.indicatorControllers[i],
                    decoration: _inputDecoration(
                      hintText: 'Indicator ${i + 1} (e.g. sensory overload)',
                    ),
                  ),
                ),
                if (entry.indicatorControllers.length > 1) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        final TextEditingController removed = entry
                            .indicatorControllers
                            .removeAt(i);
                        removed.dispose();
                      });
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
          ],
          TextButton.icon(
            onPressed: () {
              setState(() {
                entry.indicatorControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add, size: 14),
            label: const Text(
              'Add Custom Indicator',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          _label('Calming Methods (3 Custom Actions)'),
          const Text(
            'Add 3 calming methods that help this person de-escalate.',
            style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < entry.calmingMethodControllers.length; i++) ...[
            TextFormField(
              controller: entry.calmingMethodControllers[i],
              decoration: _inputDecoration(hintText: 'Calming method ${i + 1}'),
            ),
            if (i < entry.calmingMethodControllers.length - 1)
              const SizedBox(height: 6),
          ],
          const SizedBox(height: 8),
          _label('Behavior Triggers (Warning - 3 Custom Triggers)'),
          const Text(
            'List warning triggers that may cause challenging behaviors.',
            style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < entry.behaviorTriggerControllers.length; i++) ...[
            TextFormField(
              controller: entry.behaviorTriggerControllers[i],
              decoration: _inputDecoration(
                hintText: 'Behavior trigger ${i + 1}',
              ),
            ),
            if (i < entry.behaviorTriggerControllers.length - 1)
              const SizedBox(height: 6),
          ],
          const SizedBox(height: 8),
          _label('Additional Safety Notes'),
          TextFormField(
            controller: entry.additionalNotesController,
            minLines: 2,
            maxLines: 4,
            decoration: _inputDecoration(
              hintText: 'Medication, allergies, emergency instructions',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
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
                                color: Colors.black.withAlpha(14),
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () =>
                                Navigator.of(context).maybePop(false),
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
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.family_restroom,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Guardian Profile',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Create The Guardians Profile',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E3A8A),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Guardians are the trusted people in your circle who help watch over and protect the Halo.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _progressDot(_currentSetupStep == 0),
                        _progressLine(),
                        _progressDot(_currentSetupStep == 1),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_currentSetupStep == 0) ...[
                      _primaryAvatarPicker(),
                      const SizedBox(height: 12),
                      _label('Your Name *'),
                      TextFormField(
                        controller: _fullNameController,
                        validator: (String? value) =>
                            _required(value, 'Your Name'),
                        decoration: _inputDecoration(
                          hintText: 'Enter your full name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _label('Phone Number *'),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (String? value) =>
                            _required(value, 'Phone Number'),
                        decoration: _inputDecoration(
                          hintText: '(555) 123-4567',
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
                          hintText: 'you@example.com',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _label('Relationship *'),
                      DropdownButtonFormField<String>(
                        initialValue: _relationship,
                        decoration: _inputDecoration(
                          hintText: 'Select relationship',
                        ),
                        items: _relationshipOptions
                            .map(
                              (String role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _relationship = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _label('Home Address *'),
                      TextFormField(
                        controller: _addressController,
                        validator: (String? value) =>
                            _required(value, 'Home Address'),
                        decoration: _inputDecoration(
                          hintText: 'Street address',
                        ),
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
                          color: const Color(0xFFEFF5FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
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
                                  'Emergency Contacts',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _label('Primary Contact Name *'),
                            TextFormField(
                              controller: _primaryEmergencyNameController,
                              validator: (String? value) =>
                                  _required(value, 'Primary contact name'),
                              decoration: _inputDecoration(
                                hintText: 'Contact name',
                              ),
                            ),
                            const SizedBox(height: 8),
                            _label('Primary Contact Phone *'),
                            TextFormField(
                              controller: _primaryEmergencyPhoneController,
                              keyboardType: TextInputType.phone,
                              validator: (String? value) =>
                                  _required(value, 'Primary contact phone'),
                              decoration: _inputDecoration(
                                hintText: 'Contact phone number',
                              ),
                            ),
                            const SizedBox(height: 8),
                            _imagePickerField(
                              label: 'Primary Contact Photo *',
                              helperText:
                                  'Upload a photo for your primary emergency contact.',
                              emptyIcon: Icons.person_outline,
                              imageBytes: _primaryEmergencyAvatarBytes,
                              onPick: () {
                                _pickImage((Uint8List bytes, String fileName) {
                                  _primaryEmergencyAvatarBytes = bytes;
                                  _primaryEmergencyAvatarFileName = fileName;
                                });
                              },
                              onClear: () {
                                setState(() {
                                  _primaryEmergencyAvatarBytes = null;
                                  _primaryEmergencyAvatarFileName = null;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            if (_showSecondaryEmergency) ...[
                              _label('Secondary Contact Name'),
                              TextFormField(
                                controller: _secondaryEmergencyNameController,
                                decoration: _inputDecoration(
                                  hintText: 'Secondary contact name',
                                ),
                              ),
                              const SizedBox(height: 8),
                              _label('Secondary Contact Phone'),
                              TextFormField(
                                controller: _secondaryEmergencyPhoneController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration(
                                  hintText: 'Secondary contact phone number',
                                ),
                              ),
                              const SizedBox(height: 8),
                              _imagePickerField(
                                label: 'Secondary Contact Photo',
                                helperText:
                                    'Upload a photo if you are adding a secondary contact.',
                                emptyIcon: Icons.person_outline,
                                imageBytes: _secondaryEmergencyAvatarBytes,
                                onPick: () {
                                  _pickImage((
                                    Uint8List bytes,
                                    String fileName,
                                  ) {
                                    _secondaryEmergencyAvatarBytes = bytes;
                                    _secondaryEmergencyAvatarFileName =
                                        fileName;
                                  });
                                },
                                onClear: () {
                                  setState(() {
                                    _secondaryEmergencyAvatarBytes = null;
                                    _secondaryEmergencyAvatarFileName = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 6),
                            ],
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showSecondaryEmergency =
                                      !_showSecondaryEmergency;
                                  if (!_showSecondaryEmergency) {
                                    _secondaryEmergencyNameController.clear();
                                    _secondaryEmergencyPhoneController.clear();
                                    _secondaryEmergencyAvatarBytes = null;
                                    _secondaryEmergencyAvatarFileName = null;
                                  }
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF93C5FD),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              icon: Icon(
                                _showSecondaryEmergency
                                    ? Icons.remove
                                    : Icons.add,
                                size: 15,
                                color: const Color(0xFF1D4ED8),
                              ),
                              label: Text(
                                _showSecondaryEmergency
                                    ? 'Remove Secondary Contact'
                                    : 'Add Secondary Contact',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFBFDBFE)),
                            const SizedBox(height: 10),
                            const Text(
                              'Close Friends',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(170),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Close Friend 1',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _label('Name'),
                                  TextFormField(
                                    controller: _closeFriendOneNameController,
                                    decoration: _inputDecoration(
                                      hintText: 'Friend 1 full name',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _label('Phone'),
                                  TextFormField(
                                    controller: _closeFriendOnePhoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: _inputDecoration(
                                      hintText: 'Friend 1 phone number',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _imagePickerField(
                                    label: 'Photo',
                                    helperText:
                                        'Upload a photo if Close Friend 1 is provided.',
                                    emptyIcon: Icons.person_outline,
                                    imageBytes: _closeFriendOneAvatarBytes,
                                    onPick: () {
                                      _pickImage((
                                        Uint8List bytes,
                                        String fileName,
                                      ) {
                                        _closeFriendOneAvatarBytes = bytes;
                                        _closeFriendOneAvatarFileName =
                                            fileName;
                                      });
                                    },
                                    onClear: () {
                                      setState(() {
                                        _closeFriendOneAvatarBytes = null;
                                        _closeFriendOneAvatarFileName = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAdditionalCloseFriend =
                                      !_showAdditionalCloseFriend;
                                  if (!_showAdditionalCloseFriend) {
                                    _closeFriendTwoNameController.clear();
                                    _closeFriendTwoPhoneController.clear();
                                    _closeFriendTwoAvatarBytes = null;
                                    _closeFriendTwoAvatarFileName = null;
                                  }
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF93C5FD),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              icon: Icon(
                                _showAdditionalCloseFriend
                                    ? Icons.remove
                                    : Icons.add,
                                size: 15,
                                color: const Color(0xFF1D4ED8),
                              ),
                              label: Text(
                                _showAdditionalCloseFriend
                                    ? 'Remove Additional Close Friend'
                                    : 'Add Additional Close Friend',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            if (_showAdditionalCloseFriend) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(170),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Close Friend 2',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _label('Name'),
                                    TextFormField(
                                      controller: _closeFriendTwoNameController,
                                      decoration: _inputDecoration(
                                        hintText: 'Friend 2 full name',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _label('Phone'),
                                    TextFormField(
                                      controller:
                                          _closeFriendTwoPhoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: _inputDecoration(
                                        hintText: 'Friend 2 phone number',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _imagePickerField(
                                      label: 'Photo',
                                      helperText:
                                          'Upload a photo if Close Friend 2 is provided.',
                                      emptyIcon: Icons.person_outline,
                                      imageBytes: _closeFriendTwoAvatarBytes,
                                      onPick: () {
                                        _pickImage((
                                          Uint8List bytes,
                                          String fileName,
                                        ) {
                                          _closeFriendTwoAvatarBytes = bytes;
                                          _closeFriendTwoAvatarFileName =
                                              fileName;
                                        });
                                      },
                                      onClear: () {
                                        setState(() {
                                          _closeFriendTwoAvatarBytes = null;
                                          _closeFriendTwoAvatarFileName = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 13,
                                  color: Color(0xFF2563EB),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Notification Preferences',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _toggleRow(
                              label: 'Emergency Alerts',
                              subtitle: 'Immediate safety notifications',
                              value: _emergencyAlerts,
                              onChanged: (bool value) {
                                setState(() {
                                  _emergencyAlerts = value;
                                });
                              },
                            ),
                            _toggleRow(
                              label: 'Location Updates',
                              subtitle: 'Periodic location sharing updates',
                              value: _locationUpdates,
                              onChanged: (bool value) {
                                setState(() {
                                  _locationUpdates = value;
                                });
                              },
                            ),
                            _toggleRow(
                              label: 'Check-in Reminders',
                              subtitle: 'Scheduled wellness checks',
                              value: _checkInReminders,
                              onChanged: (bool value) {
                                setState(() {
                                  _checkInReminders = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _goToSpecialNeedsSetup,
                          child: Stack(
                            alignment: Alignment.center,
                            children: const <Widget>[
                              Opacity(
                                opacity: 0.18,
                                child: Icon(Icons.arrow_forward, size: 28),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Halo Profile Setup',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_currentSetupStep == 1) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.diversity_3,
                                  size: 14,
                                  color: Color(0xFF1D4ED8),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Special Needs Profiles',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: _onAddAdditionalProfilePressed,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDBEAFE),
                                    foregroundColor: const Color(0xFF1D4ED8),
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  icon: Icon(
                                    _hasAdditionalProfileSubscription
                                        ? Icons.add
                                        : Icons.lock_outline,
                                    size: 14,
                                  ),
                                  label: Text(
                                    _hasAdditionalProfileSubscription
                                        ? 'Add Additional Profile'
                                        : 'Unlock Additional Profile',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Add one or more profiles for special needs individuals and close family/friends.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            ...List<Widget>.generate(
                              _profiles.length,
                              (int index) =>
                                  _profileCard(index, _profiles[index]),
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
                        onChanged: (bool? v) {
                          setState(() {
                            _consentShare = v ?? false;
                          });
                        },
                        title: const Text(
                          'I consent to sharing profile information with law enforcement during emergencies',
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
                        onChanged: (bool? v) {
                          setState(() {
                            _consentTerms = v ?? false;
                          });
                        },
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
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentSetupStep = 0;
                            });
                          },
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text(
                            'Back to Guardian Profile',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : _saveSpecialFamilyProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
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
                                      'Save Family Setup',
                                      style: TextStyle(
                                        fontFamily: 'Orbitron',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward, size: 15),
                                  ],
                                ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _currentSetupStep == 0
                            ? 'Step 1 of 2 • Guardian Profile'
                            : 'Step 2 of 2 • Special Needs Profiles',
                        style: const TextStyle(
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
                          color: Color(0xFF1D4ED8),
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
}

class _SpecialNeedsProfileEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();
  final List<TextEditingController> indicatorControllers =
      <TextEditingController>[TextEditingController()];
  final List<TextEditingController> calmingMethodControllers =
      List<TextEditingController>.generate(
        3,
        (int _) => TextEditingController(),
      );
  final List<TextEditingController> behaviorTriggerControllers =
      List<TextEditingController>.generate(
        3,
        (int _) => TextEditingController(),
      );

  Uint8List? photoBytes;
  String? photoFileName;

  void dispose() {
    nameController.dispose();
    relationshipController.dispose();
    dateOfBirthController.dispose();
    diagnosisController.dispose();
    additionalNotesController.dispose();
    for (final TextEditingController controller in indicatorControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in calmingMethodControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in behaviorTriggerControllers) {
      controller.dispose();
    }
  }

  Map<String, dynamic> toMap({String? photoUrl}) {
    return <String, dynamic>{
      'name': nameController.text.trim(),
      'relationship': relationshipController.text.trim(),
      'dateOfBirth': dateOfBirthController.text.trim(),
      'diagnosis': diagnosisController.text.trim(),
      'avatarUrl': photoUrl,
      'specialNeedsIndicators': indicatorControllers
          .map((TextEditingController controller) => controller.text.trim())
          .where((String value) => value.isNotEmpty)
          .toList(),
      'calmingMethods': calmingMethodControllers
          .map((TextEditingController controller) => controller.text.trim())
          .where((String value) => value.isNotEmpty)
          .toList(),
      'behaviorTriggers': behaviorTriggerControllers
          .map((TextEditingController controller) => controller.text.trim())
          .where((String value) => value.isNotEmpty)
          .toList(),
      'additionalSafetyNotes': additionalNotesController.text.trim(),
    };
  }
}
