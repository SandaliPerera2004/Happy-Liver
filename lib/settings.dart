import 'package:flutter/material.dart';

import 'screens/settings/notification_screen.dart';
import 'language.dart';
import 'help_feedback.dart';
import 'screens/settings/about_us_screen.dart';
import 'widgets/bottom_navigation_bar.dart';
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
  // =========================================================
  // LOCAL DARK MODE STATE
  // =========================================================

  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _isDarkMode = widget.isDarkMode;
    }
  }

  // =========================================================
  // DARK MODE CHANGE
  // =========================================================

  Future<void> _changeDarkMode(bool value) async {
    // Update UI immediately
    setState(() {
      _isDarkMode = value;
    });

    try {
      // Save dark mode preference
      await ThemeController.setDarkMode(value);

      // Update the rest of the application
      await widget.onThemeChanged(value);
    } catch (e) {
      debugPrint('DARK MODE ERROR: $e');

      // Revert if saving/updating fails
      if (mounted) {
        setState(() {
          _isDarkMode = !value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode
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
                    color: _isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Text(
                      "Dark mode",
                      style: TextStyle(
                        fontSize: 17,
                        color: _isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),

                  Switch(
                    value: _isDarkMode,
                    activeThumbColor: Colors.green,
                    onChanged: _changeDarkMode,
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
                    builder: (context) => NotificationSettingsScreen(
                      isDarkMode: _isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
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
                    builder: (context) => const LanguageScreen(),
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
                color: _isDarkMode
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

      bottomNavigationBar: HappyLiverBottomNavBar(
        selectedIndex: 3,
        isDarkMode: _isDarkMode,
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
      child: const Row(
        children: [
          Text(
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
              color: _isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: _isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: _isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}