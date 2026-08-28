import 'package:flutter/material.dart';
import 'notifications.dart';
import 'language.dart';
import 'help_feedback.dart';
import 'about_us.dart';

class SettingsScreen extends StatefulWidget {
  final bool isTab;

  const SettingsScreen({super.key, this.isTab = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Colored header area ONLY (below phone notification area)
            Container(
              color: const Color(0xFFE5F8D8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  if (canPop && !widget.isTab) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_circle_left_outlined,
                        color: Color(0xFF146B0B),
                        size: 32,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 14),
                  ] else ...[
                    const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF146B0B),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: Color(0xFF18321F),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Dark Mode Switch
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.dark_mode_outlined,
                            size: 28,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Text(
                              "Dark mode",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: isDarkMode,
                            activeThumbColor: const Color(0xFF146B0B),
                            onChanged: (value) {
                              setState(() {
                                isDarkMode = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(indent: 20, endIndent: 20),

                    // Notifications
                    settingTile(
                      icon: Icons.notifications_none,
                      title: "Notifications",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),

                    // Language
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

                    // Help & Feedback
                    settingTile(
                      icon: Icons.chat_bubble_outline,
                      title: "Help & Feedback",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpFeedback(),
                          ),
                        );
                      },
                    ),

                    // About Us
                    settingTile(
                      icon: Icons.info_outline,
                      title: "About us",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutUsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "HappyLiver\nVersion 1.0.0",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: Colors.black87,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}