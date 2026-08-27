import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../assessment/assessment_result_screen.dart';
import '../dashboard/daily%20routine/daily_routine_screen.dart';
import '../dashboard/profile_screen.dart';
import '../settings/settings.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Current Password'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      hint: 'Enter your current password',
                      iconAsset: 'assets/icons/lock.svg',
                      obscure: _obscureCurrent,
                      onToggle: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('New Password'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hint: 'Create a strong password',
                      iconAsset: 'assets/icons/key.svg',
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Confirm New Password'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Re-enter your new password',
                      iconAsset: 'assets/icons/check-circle.svg',
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Use 8+ characters with a mix of letters, numbers, and symbols.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildConfirmButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION BAR
      // ============================================================
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
      );
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AssessmentResultScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DailyRoutineScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFDFF3D8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // NOTE: parameter is `iconAsset` (String path to an SVG), not `icon` (IconData).
  // This must match how the method is called above.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required String iconAsset,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.black45,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.black38,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () async {
            final currentPassword =
            _currentPasswordController.text.trim();

            final newPassword =
            _newPasswordController.text.trim();

            final confirmPassword =
            _confirmPasswordController.text.trim();

            // Check all fields
            if (currentPassword.isEmpty ||
                newPassword.isEmpty ||
                confirmPassword.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all password fields.'),
                ),
              );
              return;
            }

            // Check new password length
            if (newPassword.length < 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'New password must be at least 8 characters.',
                  ),
                ),
              );
              return;
            }

            // Check passwords match
            if (newPassword != confirmPassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New passwords do not match.'),
                ),
              );
              return;
            }

            try {
              await _authService.changePassword(
                currentPassword,
                newPassword,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully.'),
                ),
              );

              Navigator.pop(context);
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to change password: ${e.toString()}',
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/shield-check.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}