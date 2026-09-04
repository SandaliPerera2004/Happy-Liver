import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _darkText = Color(0xFF1B1F1D);
  static const Color _grayText = Color(0xFF6B756E);
  static const Color _grayNav = Color(0xFF9AA29D);
  static const Color _borderColor = Color(0xFFE5EAE7);

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);

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

          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      28,
                      20,
                      20,
                    ),
                    child: Column(
                      children: [
                        _buildLogo(isDarkMode),

                        const SizedBox(height: 28),

                        _infoRow(
                          'Evaluate potential fatty liver and cholesterol '
                              'risk based on your responses.',
                          isDarkMode,
                        ),

                        const SizedBox(height: 12),

                        _infoRow(
                          'Receive lifestyle suggestions based on your '
                              'assessment results.',
                          isDarkMode,
                        ),

                        const SizedBox(height: 12),

                        _infoRowRichText(isDarkMode),

                        const SizedBox(height: 25),

                        // =================================================
                        // DARK MODE SWITCH
                        // =================================================

                        Row(
                          children: [
                            Icon(
                              Icons.dark_mode_outlined,
                              size: 28,
                              color: isDarkMode
                                  ? Colors.white
                                  : _darkText,
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                'Dark mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white
                                      : _darkText,
                                ),
                              ),
                            ),

                            Switch(
                              value: isDarkMode,
                              activeThumbColor: Colors.green,
                              activeTrackColor:
                              Colors.green.withOpacity(0.35),
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor:
                              Colors.grey.withOpacity(0.25),
                              onChanged: (value) async {
                                await ThemeController.setDarkMode(
                                  value,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.white70
                              : _grayText,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '© 2026 HappyLiver',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.white70
                              : _grayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar:
          _buildBottomNavBar(context, isDarkMode),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1B3B1F)
            : _lightGreenHeader,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? Colors.white
                    : Colors.black87,
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            'About us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOGO + APP NAME
  // ================================================================

  Widget _buildLogo(bool isDarkMode) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo-wrap.png',
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 10),

        Text(
          'HappyLiver',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDarkMode
                ? Colors.white
                : _darkText,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          'Your Health, Your Awareness',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDarkMode
                ? Colors.white
                : _darkText,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // INFO ROW
  // ================================================================

  Widget _infoRow(
      String text,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: isDarkMode
              ? Colors.white12
              : _borderColor,
        ),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.description_outlined,
            size: 18,
            color: isDarkMode
                ? Colors.white
                : _darkText,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? Colors.white
                    : _darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // INFO ROW WITH RICH TEXT
  // ================================================================

  Widget _infoRowRichText(bool isDarkMode) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: isDarkMode
              ? Colors.white12
              : _borderColor,
        ),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.description_outlined,
            size: 18,
            color: isDarkMode
                ? Colors.white
                : _darkText,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.white
                      : _darkText,
                ),

                children: const [
                  TextSpan(
                    text:
                    'HappyLiver is an educational risk assessment '
                        'tool and ',
                  ),

                  TextSpan(
                    text:
                    'does not provide medical diagnosis or '
                        'treatment.',
                    style: TextStyle(
                      color: Color(0xFFE3453A),
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
  // BOTTOM NAVIGATION BAR
  // ================================================================

  Widget _buildBottomNavBar(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,

        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white12
                : Colors.black.withOpacity(0.06),
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,

            children: [
              _bottomItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },
              ),

              _bottomItem(
                icon: Icons.calendar_today_outlined,
                label: 'Daily Routine',
                selected: false,
                isDarkMode: isDarkMode,
                onTap: () {
                  // Navigate to Daily Routine
                },
              ),

              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                isDarkMode: isDarkMode,
                onTap: () {
                  // Navigate to Profile
                },
              ),

              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: true,
                isDarkMode: isDarkMode,
                onTap: () {
                  // Navigate to Settings
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BOTTOM NAV ITEM
  // ================================================================

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            size: 22,

            color: selected
                ? _green
                : isDarkMode
                ? Colors.white60
                : _grayNav,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,

              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w700,

              color: selected
                  ? _green
                  : isDarkMode
                  ? Colors.white60
                  : _grayNav,
            ),
          ),
        ],
      ),
    );
  }
}