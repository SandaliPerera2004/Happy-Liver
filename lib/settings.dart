import 'package:flutter/material.dart';
import 'notifications.dart';
import 'language.dart';
import 'help_feedback.dart';
import 'about_us.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F8D8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 30),

          // Dark Mode Switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.dark_mode_outlined,
                  size: 30,
                  color: Colors.black,
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    "Dark mode",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  activeThumbColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Notifications
          settingTile(
            icon: Icons.notifications_none,
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
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
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
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
                MaterialPageRoute(builder: (context) => const HelpFeedback()),
              );
            },
          ),

          // About Us
          settingTile(
            icon: Icons.phone_android,
            title: "About us",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),

          const Spacer(),

          const Text(
            "HappyLiver\nVersion 1.0.0",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 50),
        ],
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
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.black,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}