import 'package:flutter/material.dart';

import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../services/theme_controller.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final Future<void> Function(bool) onThemeChanged;

  const UserProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color _green = Color(0xFF2DCB59);
  static const Color _darkGreen = Color(0xFF1B5E20);
  static const Color _darkText = Color(0xFF263A31);
  static const Color _grayText = Color(0xFF8A948E);

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);

  static const double _hPad = 20;

  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Make sure the global theme controller starts
    // with the theme received by this screen.
    ThemeController.isDarkMode.value = widget.isDarkMode;

    _loadUserProfile();
  }

  // ================================================================
  // LOAD USER PROFILE
  // ================================================================

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

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          // =========================================================
          // BACKGROUND
          // =========================================================

          backgroundColor: isDarkMode
              ? _darkBackground
              : const Color(0xFFF5F6F8),

          // =========================================================
          // BODY
          // =========================================================

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
                        // =================================================
                        // HEADER
                        // =================================================

                        _buildHeader(
                          context,
                          isDarkMode,
                        ),

                        // =================================================
                        // MAIN CONTENT
                        // =================================================

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            _hPad,
                            24,
                            _hPad,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                            children: [
                              // =================================================
                              // STATS
                              // =================================================

                              _buildStatsRow(isDarkMode),

                              const SizedBox(height: 26),

                              // =================================================
                              // ACCOUNT SETTINGS TITLE
                              // =================================================

                              Text(
                                'Account Settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode
                                      ? Colors.white
                                      : _darkText,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // =================================================
                              // ACCOUNT SETTINGS CARD
                              // =================================================

                              _buildAccountSettingsCard(
                                context,
                                isDarkMode,
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

          // =========================================================
          // SHARED BOTTOM NAVIGATION
          // =========================================================

          bottomNavigationBar: HappyLiverBottomNavBar(
            selectedIndex: 2,

            // IMPORTANT:
            // Use the current ValueNotifier value,
            // NOT widget.isDarkMode.
            isDarkMode: isDarkMode,

            onThemeChanged: widget.onThemeChanged,
          ),
        );
      },
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.only(
        top: 24,
        bottom: 28,
      ),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _darkGreen,
            _green,
          ],
        ),
      ),

      child: Column(
        children: [
          // =========================================================
          // PROFILE IMAGE
          // =========================================================

          Container(
            width: 96,
            height: 96,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.black,
                width: 3,
              ),

              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/profile_image.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // =========================================================
          // USERNAME
          // =========================================================

          Text(
            _user?.username ?? 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // =========================================================
          // EDIT PROFILE BUTTON
          // =========================================================

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    // IMPORTANT:
                    // Pass the CURRENT theme value.
                    isDarkMode: isDarkMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
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

  Widget _buildStatsRow(bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _statCard(
            imageAsset: 'assets/images/weekly.png',
            label: 'WEEKLY REPORT',
            value: '85%',
            isDarkMode: isDarkMode,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _statCard(
            imageAsset: 'assets/images/target.png',
            label: 'ACHIEVED GOALS',
            value: '12/15',
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // STAT CARD
  // ================================================================

  Widget _statCard({
    required String imageAsset,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),

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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: isDarkMode
                  ? Colors.white70
                  : _grayText,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDarkMode
                  ? Colors.white
                  : _darkText,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ACCOUNT SETTINGS CARD
  // ================================================================

  Widget _buildAccountSettingsCard(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          // ========================================================
          // CHANGE PASSWORD
          // ========================================================

          _settingsRow(
            iconAsset: 'assets/images/change.png',
            iconBg: const Color(0xFFE9F9EE),
            label: 'Change Password',
            isDarkMode: isDarkMode,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangePasswordScreen(
                    // IMPORTANT:
                    // Pass CURRENT theme value.
                    isDarkMode: isDarkMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),

          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDarkMode
                ? Colors.white12
                : Colors.grey.shade200,
          ),

          // ========================================================
          // PREMIUM FEATURES
          // ========================================================

          _settingsRow(
            iconAsset: 'assets/images/crown.png',
            iconBg: const Color(0xFFFFF6DE),
            label: 'Premium Features',
            isDarkMode: isDarkMode,

            onTap: () {
              // Navigate to Premium Features screen
            },
          ),

          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDarkMode
                ? Colors.white12
                : Colors.grey.shade200,
          ),

          // ========================================================
          // LOG OUT
          // ========================================================

          _settingsRow(
            iconAsset: 'assets/images/logout.png',
            iconBg: const Color(0xFFFCEAEA),
            label: 'Log Out',
            labelColor: const Color(0xFFE3453A),
            isDarkMode: isDarkMode,

            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SETTINGS ROW
  // ================================================================

  Widget _settingsRow({
    required String iconAsset,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
    Color? labelColor,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        child: Row(
          children: [
            // =======================================================
            // ICON BACKGROUND
            // =======================================================

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

            // =======================================================
            // LABEL
            // =======================================================

            Expanded(
              child: Text(
                label,

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,

                  color: labelColor ??
                      (isDarkMode
                          ? Colors.white
                          : _darkText),
                ),
              ),
            ),

            // =======================================================
            // ARROW
            // =======================================================

            Icon(
              Icons.chevron_right,
              size: 20,

              color: isDarkMode
                  ? Colors.white60
                  : _grayText,
            ),
          ],
        ),
      ),
    );
  }
}