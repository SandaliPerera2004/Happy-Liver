import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _gender = 'Female';

  static const Color kGreen = Color(0xFF2E7D32);
  static const Color kLightGreenAppBar = Color(0xFFDDF2DD);
  static const Color kFieldBorder = Color(0xFFD9D9D9);

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _ageController.clear();
      _heightController.clear();
      _weightController.clear();
      _gender = 'Female';
    });
  }

  void _saveProfile() {
    // TODO: wire up save logic (API call / local storage / state mgmt)
    final profile = {
      'name': _nameController.text,
      'age': _ageController.text,
      'gender': _gender,
      'height': _heightController.text,
      'weight': _weightController.text,
    };
    debugPrint('Saving profile: $profile');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Green header bar — starts below the status bar
              Container(
                width: double.infinity,
                color: kLightGreenAppBar,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: SvgPicture.asset(
                        'assets/icons/Arrow left-circle.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Name'),
        _buildTextField(controller: _nameController),
        const SizedBox(height: 20),

        _buildLabel('Age'),
        _buildTextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),

        _buildLabel('Gender'),
        const SizedBox(height: 4),
        _buildGenderOption('Female'),
        _buildGenderOption('Male'),
        const SizedBox(height: 12),

        const Text(
          'BMI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        _buildLabelWithUnit('Height', 'cm'),
        _buildTextField(
          controller: _heightController,
          keyboardType: TextInputType.number,
          highlighted: true,
        ),
        const SizedBox(height: 20),

        _buildLabelWithUnit('Weight', 'kg'),
        _buildTextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          highlighted: true,
        ),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              label: 'Reset',
              color: Colors.grey.shade400,
              onPressed: _resetForm,
            ),
            const SizedBox(width: 20),
            _buildButton(
              label: 'Save',
              color: kGreen,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLabelWithUnit(String label, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              unit,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool highlighted = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: highlighted ? kGreen : kFieldBorder,
            width: highlighted ? 1.5 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: highlighted ? kGreen : kFieldBorder,
            width: highlighted ? 1.5 : 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: kGreen, width: 1),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String value) {
    return InkWell(
      onTap: () => setState(() => _gender = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _gender,
              activeColor: kGreen,
              onChanged: (val) => setState(() => _gender = val!),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 130,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}