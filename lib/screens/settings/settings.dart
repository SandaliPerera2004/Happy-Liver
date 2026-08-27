import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/theme_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../assessment/assessment_result_screen.dart';
import '../dashboard/daily%20routine/daily_routine_screen.dart';
import '../dashboard/profile_screen.dart';
import 'notification_screen.dart';
import 'language.dart';
import 'help_feedback.dart';
import 'about_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = ThemeService.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: 20),

            // Dark Mode Switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                    size: 28,
                    color: iconColor,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "Dark mode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  Switch(
                    value: isDarkMode,
                    activeThumbColor: const Color(0xFF146B0B),
                    activeTrackColor: const Color(0xFFCFF7D3),
                    onChanged: (value) async {
                      setState(() {
                        isDarkMode = value;
                      });
                      await ThemeService.setDarkMode(value);
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, indent: 20, endIndent: 20),

            // Notifications
            settingTile(
              icon: Icons.notifications_none,
              title: "Notifications",
              textColor: textColor,
              iconColor: iconColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),

            // Language
            settingTile(
              icon: Icons.language,
              title: "Language",
              textColor: textColor,
              iconColor: iconColor,
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
              textColor: textColor,
              iconColor: iconColor,
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
              textColor: textColor,
              iconColor: iconColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            Text(
              "HappyLiver\nVersion 1.0.0",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2D1E) : const Color(0xFFDFF3D8),
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
          Text(
            "Settings",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget settingTile({
    required IconData icon,
    required String title,
    required Color textColor,
    required Color iconColor,
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
              color: iconColor,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: iconColor.withAlpha(120),
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 3) return; // Already on Settings

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
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
        );
        break;
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: 3,
      onTap: _onBottomNavTapped,
    );
  }
}