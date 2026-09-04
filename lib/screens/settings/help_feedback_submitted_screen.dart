import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';

class FeedbackSubmittedScreen extends StatelessWidget {
  const FeedbackSubmittedScreen({super.key});

  static const Color _green = Color(0xFF10A518);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _lightGreenIconBg = Color(0xFFE9F9EE);
  static const Color _grayNav = Color(0xFF9AA29D);

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
              ? const Color(0xFF121212)
              : const Color(0xFFF5F6F8),

          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      40,
                      80,
                      40,
                      40,
                    ),
                    child: _buildConfirmationCard(
                      context,
                      isDarkMode,
                    ),
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar:
          _buildBottomNavBar(
            context,
            isDarkMode,
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
            'Help & Feedback',
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
  // CONFIRMATION CARD
  // ================================================================

  Widget _buildConfirmationCard(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),

      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: isDarkMode
              ? Colors.white12
              : const Color(0xFFE5EAE7),
        ),
      ),

      child: Column(
        children: [
          // ======================================================
          // CHECK ICON
          // ======================================================

          Container(
            width: 72,
            height: 72,

            decoration: const BoxDecoration(
              color: _lightGreenIconBg,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.check_box_outlined,
              size: 34,
              color: _green,
            ),
          ),

          const SizedBox(height: 18),

          // ======================================================
          // SUBMITTED
          // ======================================================

          const Text(
            'Submitted!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _green,
            ),
          ),

          const SizedBox(height: 10),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          Text(
            'Thank you for helping us improve Happy Liver. '
                'Your feedback is invaluable to our team.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? Colors.white70
                  : const Color(0xFF8A948E),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // ======================================================
          // BACK TO HOME BUTTON
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                      (route) => route.isFirst,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              child: const Text(
                'Back to Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // DARK MODE SWITCH
          // ======================================================

          Row(
            children: [
              Icon(
                Icons.dark_mode_outlined,
                size: 28,
                color: isDarkMode
                    ? Colors.white
                    : Colors.black,
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
                        : Colors.black,
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
            ? const Color(0xFF1E1E1E)
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
                  // Navigate to Daily Routine screen
                },
              ),

              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                isDarkMode: isDarkMode,
                onTap: () {
                  // Navigate to Profile screen
                },
              ),

              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: true,
                isDarkMode: isDarkMode,
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
        mainAxisAlignment: MainAxisAlignment.center,

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