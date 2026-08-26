import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../dashboard/daily routine/daily_routine_screen.dart';
import '../../../services/user_service.dart';
import '../../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _darkText = Color(0xFF263A31);
  static const Color _grayText = Color(0xFF8A948E);
  static const Color _fieldFill = Color(0xFFF2F3F5);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController =
  TextEditingController(text: '170');
  final TextEditingController _weightController =
  TextEditingController(text: '65');

  final UserService _userService = UserService();

  String _gender = 'Female';

  double get _bmi {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height == null || weight == null || height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty ||
        age == null ||
        height == null ||
        weight == null ||
        height <= 0 ||
        weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid profile information.'),
        ),
      );
      return;
    }

    try {
      await _userService.updateUserProfile(
        username: name,
        age: age,
        gender: _gender,
        height: height,
        weight: weight,
        bmi: _bmi,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _heightController.addListener(() => setState(() {}));
    _weightController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 24),
                    _buildBasicInfoCard(),
                    const SizedBox(height: 16),
                    _buildBmiCard(),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _resetFields,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _grayText,
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
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  void _resetFields() {
    setState(() {
      _nameController.clear();
      _ageController.clear();
      _heightController.text = '170';
      _weightController.text = '65';
      _gender = 'Female';
    });
  }

  // ================================================================
  // HEADER
  // ================================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      color: _lightGreenHeader,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
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
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                image: const DecorationImage(
                  image: AssetImage('assets/images/profile_image.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Handle photo change
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5EAE7)),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 15,
                    color: _darkText,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap to change photo',
          style: TextStyle(
            fontSize: 13,
            color: _grayText,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // BASIC INFORMATION CARD
  // ================================================================
  Widget _buildBasicInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
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
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 18),
          _fieldLabel('Gender'),
          const SizedBox(height: 8),
          _genderToggle(),
        ],
      ),
    );
  }

  Widget _genderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _genderOption('Female')),
          Expanded(child: _genderOption('Male')),
        ],
      ),
    );
  }

  Widget _genderOption(String label) {
    final bool selected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
            color: selected ? _darkText : _grayText,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'BMI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              const Spacer(),
              Text(
                _bmi > 0 ? _bmi.toStringAsFixed(1) : '--',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _darkText,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'kg/m²',
                  style: TextStyle(
                    fontSize: 11,
                    color: _grayText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Height'),
                    const SizedBox(height: 8),
                    _unitField(
                      controller: _heightController,
                      unit: 'cm',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Weight'),
                    const SizedBox(height: 8),
                    _unitField(
                      controller: _weightController,
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
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
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
  // SHARED WIDGETS
  // ================================================================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _darkText,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: _darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _unitField({
    required TextEditingController controller,
    required String unit,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14, color: _darkText),
      decoration: InputDecoration(
        suffixText: unit,
        suffixStyle: const TextStyle(color: _grayText, fontSize: 13),
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================================================================
  // BOTTOM NAVIGATION BAR
  // ================================================================
  Widget _buildBottomNavBar(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,
                onTap: () {
                },
              ),
              _bottomItem(
                icon: Icons.calendar_today_outlined,
                label: 'Daily Routine',
                selected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DailyRoutineScreen(),
                    ),
                  );
                },
              ),
              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: true,
                onTap: () {
                  // Navigate to Profile screen
                },
              ),
              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: false,
                onTap: () {
                  // Navigate to Settings screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: selected ? _green : _grayText,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              color: selected ? _green : _grayText,
            ),
          ),
        ],
      ),
    );
  }
}