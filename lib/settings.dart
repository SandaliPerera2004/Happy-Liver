import 'package:flutter/material.dart';
import 'screens/settings/notification_screen.dart';
import 'language.dart';
import 'help_feedback.dart';
import 'screens/settings/about_us_screen.dart';

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

      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),

            const SizedBox(height: 30),

            // =========================
            // DARK MODE
            // =========================
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
                      await widget.onThemeChanged(value);
                    },
                  ),
                ],
              ),
            ),

            // =========================
            // NOTIFICATIONS
            // =========================
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

            // =========================
            // LANGUAGE
            // =========================
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

            // =========================
            // HELP & FEEDBACK
            // =========================
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

            // =========================
            // ABOUT US
            // =========================
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

      bottomNavigationBar:
      _buildBottomNavBar(context),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      // IMPORTANT:
      // Keep the green header in both light and dark mode.
      decoration: const BoxDecoration(
        color: Color(0xFFE5F8D8),
      ),

      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            "Settings",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SETTING TILE
  // =========================================================

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

  // =========================================================
  // BOTTOM NAVIGATION BAR
  // =========================================================

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,

        border: Border(
          top: BorderSide(
            color: widget.isDarkMode
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
                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BOTTOM NAV ITEM
  // =========================================================

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

        children: [
          Icon(
            icon,
            size: 22,

            // Selected item stays green.
            // Unselected items become grey.
            color: selected
                ? Colors.green
                : Colors.grey,
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
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}