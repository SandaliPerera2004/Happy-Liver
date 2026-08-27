import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../assessment/assessment_result_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import 'daily routine/daily_routine_screen.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../settings/settings.dart';


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {


  static const Color _green = Color(0xFF2DCB59);
  static const Color _darkGreen = Color(0xFF1B5E20);
  static const Color _darkText = Color(0xFF263A31);
  static const Color _grayText = Color(0xFF8A948E);

  // Consistent horizontal margin used by every section below the header.
  static const double _hPad = 20;

  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  Future<void> _loadUserProfile() async {
    print('LOAD USER PROFILE CALLED');
    try {
      final user = await _userService.getCurrentUserProfile();
      print('USER RESULT: $user');

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _hPad,
                        24,
                        _hPad,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStatsRow(),
                          const SizedBox(height: 26),
                          const Text(
                            'Account Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAccountSettingsCard(context),
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
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_darkGreen, _green],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3),
              image: const DecorationImage(
                image: AssetImage('assets/images/profile_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _user?.username ?? 'User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Edit.png',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STATS ROW
  // ================================================================
  Widget _buildStatsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _statCard(
            imageAsset: 'assets/images/weekly.png',
            label: 'WEEKLY REPORT',
            value: '85%',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            imageAsset: 'assets/images/target.png',
            label: 'ACHIEVED GOALS',
            value: '12/15',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String imageAsset,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imageAsset,
            width: 70,
            height: 70,
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: _grayText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _darkText,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ACCOUNT SETTINGS CARD
  // ================================================================
  Widget _buildAccountSettingsCard(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _settingsRow(
            iconAsset: 'assets/images/change.png',
            iconBg: const Color(0xFFE9F9EE),
            label: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _settingsRow(
            iconAsset: 'assets/images/crown.png',
            iconBg: const Color(0xFFFFF6DE),
            label: 'Premium Features',
            onTap: () {
              // Navigate to premium screen
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _settingsRow(
            iconAsset: 'assets/images/logout.png',
            iconBg: const Color(0xFFFCEAEA),
            label: 'Log Out',
            labelColor: const Color(0xFFE3453A),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _settingsRow({
    required String iconAsset,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
    Color labelColor = _darkText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Image.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: _grayText,
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) return; // Already on Profile

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

  Widget _buildBottomNavBar(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: 2,
      onTap: _onBottomNavTapped,
    );
  }
}