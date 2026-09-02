import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../dashboard/daily routine/daily_routine_screen.dart';
import '../../../services/user_service.dart';
import '../../../widgets/bottom_navigation_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final Future<void> Function(bool) onThemeChanged;

  const EditProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _darkText = Color(0xFF263A31);
  static const Color _grayText = Color(0xFF8A948E);
  static const Color _fieldFill = Color(0xFFF2F3F5);

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _ageController =
  TextEditingController();

  final TextEditingController _heightController =
  TextEditingController(text: '170');

  final TextEditingController _weightController =
  TextEditingController(text: '65');

  final UserService _userService = UserService();

  final ImagePicker _imagePicker = ImagePicker();

  String _gender = 'Female';
  bool _isSaving = false;

  // ================================================================
  // PROFILE IMAGE
  // ================================================================

  File? _profileImage;

  String? _profileImageUrl;

  // ================================================================
  // BMI
  // ================================================================

  double get _bmi {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height == null ||
        weight == null ||
        height <= 0 ||
        weight <= 0) {
      return 0;
    }

    final heightInMeters = height / 100;

    return weight / (heightInMeters * heightInMeters);
  }

  // ================================================================
  // INIT
  // ================================================================

  @override
  void initState() {
    super.initState();

    _heightController.addListener(_onBmiChanged);
    _weightController.addListener(_onBmiChanged);

    _loadProfile();
  }

  void _onBmiChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ================================================================
  // LOAD PROFILE
  // ================================================================

  Future<void> _loadProfile() async {
    try {
      final user =
      await _userService.getCurrentUserProfile();

      if (!mounted || user == null) return;

      final imageUrl =
      await _userService.getProfilePictureUrl();

      if (!mounted) return;

      setState(() {
        _nameController.text = user.username;

        if (user.age != null) {
          _ageController.text =
              user.age.toString();
        }

        if (user.height != null) {
          _heightController.text =
              user.height!.toString();
        }

        if (user.weight != null) {
          _weightController.text =
              user.weight!.toString();
        }

        if (user.gender != null &&
            (user.gender == 'Male' ||
                user.gender == 'Female')) {
          _gender = user.gender!;
        }

        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load profile: $e',
          ),
        ),
      );
    }
  }

  // ================================================================
  // CHANGE PROFILE PHOTO
  // ================================================================

  Future<void> _changeProfilePhoto() async {
    try {
      final XFile? pickedFile =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _profileImage =
            File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select photo: $e',
          ),
        ),
      );
    }
  }

  // ================================================================
  // SAVE PROFILE
  // ================================================================

  Future<void> _saveProfile() async {
    final name =
    _nameController.text.trim();

    final age =
    int.tryParse(
      _ageController.text.trim(),
    );

    final height =
    double.tryParse(
      _heightController.text.trim(),
    );

    final weight =
    double.tryParse(
      _weightController.text.trim(),
    );

    if (name.isEmpty ||
        age == null ||
        height == null ||
        weight == null ||
        height <= 0 ||
        weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid profile information.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ------------------------------------------------------------
      // UPDATE PROFILE INFORMATION
      // ------------------------------------------------------------

      await _userService.updateUserProfile(
        username: name,
        age: age,
        gender: _gender,
        height: height,
        weight: weight,
        bmi: _bmi,
      );

      // ------------------------------------------------------------
      // UPLOAD PROFILE PICTURE
      // ------------------------------------------------------------

      if (_profileImage != null) {
        final uploadedImageUrl =
        await _userService.uploadProfilePicture(
          _profileImage!,
        );

        _profileImageUrl =
            uploadedImageUrl;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();

    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? _darkBackground
          : const Color(0xFFF5F6F8),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    _buildAvatar(),

                    const SizedBox(height: 24),

                    _buildBasicInfoCard(),

                    const SizedBox(height: 16),

                    _buildBmiCard(),

                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: _resetFields,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.isDarkMode
                              ? Colors.white60
                              : _grayText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      HappyLiverBottomNavBar(
        selectedIndex: 2,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    );
  }

  // ================================================================
  // RESET
  // ================================================================

  void _resetFields() {
    setState(() {
      _nameController.clear();
      _ageController.clear();

      _heightController.text = '170';
      _weightController.text = '65';

      _gender = 'Female';

      _profileImage = null;
    });
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),

      color: _lightGreenHeader,

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.maybePop(context);
            },

            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 34,
              height: 34,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // AVATAR
  // ================================================================

  Widget _buildAvatar() {
    return Column(
      children: [
        GestureDetector(
          onTap: _changeProfilePhoto,

          child: Stack(
            children: [
              Container(
                width: 96,
                height: 96,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),

                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(
                    _profileImage!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  )
                      : _profileImageUrl != null &&
                      _profileImageUrl!
                          .isNotEmpty
                      ? Image.network(
                    _profileImageUrl!,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Image.asset(
                        'assets/images/profile_image.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    'assets/images/profile_image.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,

                child: Container(
                  width: 30,
                  height: 30,

                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,

                    border: Border.all(
                      color:
                      const Color(0xFFE5EAE7),
                    ),
                  ),

                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 15,
                    color: _darkText,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: _changeProfilePhoto,

          child: Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 13,
              color: widget.isDarkMode
                  ? Colors.white60
                  : _grayText,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // BASIC INFORMATION
  // ================================================================

  Widget _buildBasicInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle('Basic Information'),

          const SizedBox(height: 18),

          _fieldLabel('Name'),

          const SizedBox(height: 8),

          _textField(
            controller: _nameController,
            hint: 'Enter your name',
          ),

          const SizedBox(height: 18),

          _fieldLabel('Age'),

          const SizedBox(height: 8),

          _textField(
            controller: _ageController,
            hint: 'Enter your age',
            keyboardType:
            TextInputType.number,
          ),

          const SizedBox(height: 18),

          _fieldLabel('Gender'),

          const SizedBox(height: 8),

          _genderToggle(),
        ],
      ),
    );
  }

  // ================================================================
  // GENDER
  // ================================================================

  Widget _genderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF2A2A2A)
            : _fieldFill,

        borderRadius:
        BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Expanded(
            child: _genderOption('Female'),
          ),

          Expanded(
            child: _genderOption('Male'),
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String label) {
    final bool selected =
        _gender == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = label;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 150),

        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,

          borderRadius:
          BorderRadius.circular(9),

          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.06),
              blurRadius: 6,
              offset:
              const Offset(0, 2),
            ),
          ]
              : null,
        ),

        alignment: Alignment.center,

        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,

            color: selected
                ? _darkText
                : widget.isDarkMode
                ? Colors.white60
                : _grayText,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BMI CARD
  // ================================================================

  Widget _buildBmiCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              _sectionTitle('BMI'),

              const Spacer(),

              Text(
                _bmi > 0
                    ? _bmi.toStringAsFixed(1)
                    : '--',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: widget.isDarkMode
                      ? Colors.white
                      : _darkText,
                ),
              ),

              const SizedBox(width: 4),

              Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 3,
                ),

                child: Text(
                  'kg/m²',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isDarkMode
                        ? Colors.white60
                        : _grayText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Height'),

                    const SizedBox(height: 8),

                    _unitField(
                      controller:
                      _heightController,
                      unit: 'cm',
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Weight'),

                    const SizedBox(height: 8),

                    _unitField(
                      controller:
                      _weightController,
                      unit: 'kg',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SAVE BUTTON
  // ================================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,

      child: ElevatedButton(
        onPressed:
        _isSaving ? null : _saveProfile,

        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),

        child: _isSaving
            ? const SizedBox(
          width: 22,
          height: 22,

          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'Save Changes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CARD
  // ================================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? _darkCard
            : Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              widget.isDarkMode
                  ? 0.25
                  : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: child,
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: widget.isDarkMode
            ? Colors.white
            : _darkText,
      ),
    );
  }

  // ================================================================
  // FIELD LABEL
  // ================================================================

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: widget.isDarkMode
            ? Colors.white70
            : _darkText,
      ),
    );
  }

  // ================================================================
  // TEXT FIELD
  // ================================================================

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      style: TextStyle(
        fontSize: 14,
        color: widget.isDarkMode
            ? Colors.white
            : _darkText,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color: widget.isDarkMode
              ? Colors.white38
              : Colors.black38,
          fontSize: 14,
        ),

        filled: true,

        fillColor: widget.isDarkMode
            ? const Color(0xFF2A2A2A)
            : _fieldFill,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================================================================
  // UNIT FIELD
  // ================================================================

  Widget _unitField({
    required TextEditingController controller,
    required String unit,
  }) {
    return TextField(
      controller: controller,

      keyboardType:
      TextInputType.number,

      style: TextStyle(
        fontSize: 14,
        color: widget.isDarkMode
            ? Colors.white
            : _darkText,
      ),

      decoration: InputDecoration(
        suffixText: unit,

        suffixStyle: TextStyle(
          color: widget.isDarkMode
              ? Colors.white60
              : _grayText,
          fontSize: 13,
        ),

        filled: true,

        fillColor: widget.isDarkMode
            ? const Color(0xFF2A2A2A)
            : _fieldFill,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}