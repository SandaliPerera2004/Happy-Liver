import 'package:flutter/material.dart';

import 'screens/settings/notification_screen.dart';
import 'language.dart';
import 'help_feedback.dart';
import 'screens/settings/about_us_screen.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Future<void> Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF121212)
          : Colors.white,

      // =========================================================
      // BODY
      // =========================================================

      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),

            const SizedBox(height: 30),

            // =====================================================
            // DARK MODE
            // =====================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode_outlined,
                    size: 30,
                    color: widget.isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Text(
                      "Dark mode",
                      style: TextStyle(
                        fontSize: 17,
                        color: widget.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),

                  Switch(
                    value: widget.isDarkMode,
                    activeThumbColor: Colors.green,
                    onChanged: (value) async {
                      await ThemeController.setDarkMode(value);
                      await widget.onThemeChanged(value);
                    },
                  ),
                ],
              ),
            ),

            // =====================================================
            // NOTIFICATIONS
            // =====================================================

            settingTile(
              icon: Icons.notifications_none,
              title: "Notifications",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const NotificationSettingsScreen(),
                  ),
                );
              },
            ),

            // =====================================================
            // LANGUAGE
            // =====================================================

            settingTile(
              icon: Icons.language,
              title: "Language",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const LanguageScreen(),
                  ),
                );
              },
            ),

            // =====================================================
            // HELP & FEEDBACK
            // =====================================================

            settingTile(
              icon: Icons.chat_bubble_outline,
              title: "Help & Feedback",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const HelpFeedback(),
                  ),
                );
              },
            ),

            // =====================================================
            // ABOUT US
            // =====================================================

            settingTile(
              icon: Icons.phone_android,
              title: "About us",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const AboutUsScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            // =====================================================
            // VERSION
            // =====================================================

            Text(
              "HappyLiver\nVersion 1.0.0",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode
                    ? Colors.white
                    : Colors.black,
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),

      // =========================================================
      // SHARED BOTTOM NAVIGATION
      // =========================================================
      //
      // 0 = Home
      // 1 = Daily Routine
      // 2 = Profile
      // 3 = Settings
      //
      // Settings = selectedIndex: 3
      //

      bottomNavigationBar: HappyLiverBottomNavBar(
        selectedIndex: 3,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    );
  }

  // =============================================================
  // HEADER
  // =============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: const BoxDecoration(
        color: Color(0xFFE5F8D8),
      ),

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            "Settings",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SETTING TILE
  // =============================================================

  Widget settingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: widget.isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: widget.isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: widget.isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}