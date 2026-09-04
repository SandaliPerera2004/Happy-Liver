import 'package:flutter/material.dart';
import 'send_feedback.dart';
import 'report_problem.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';

class HelpFeedback extends StatelessWidget {
  const HelpFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          // =========================
          // BACKGROUND
          // =========================
          backgroundColor: isDarkMode
              ? const Color(0xFF121212)
              : Colors.white,

          // =========================
          // BODY
          // =========================
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, isDarkMode),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 55),

                        // =========================
                        // TITLE
                        // =========================

                        Text(
                          "How can we help you?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =========================
                        // SEND FEEDBACK
                        // =========================

                        helpItem(
                          title: "Send feedback",
                          isDarkMode: isDarkMode,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const SendFeedback(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // =========================
                        // REPORT PROBLEM
                        // =========================

                        helpItem(
                          title: "Report a problem",
                          isDarkMode: isDarkMode,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ReportProblem(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // =========================
                        // DARK MODE
                        // =========================

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
                                "Dark mode",
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

                        const Spacer(),

                        // =========================
                        // STILL NEED HELP
                        // =========================

                        Text(
                          "Still need help?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =========================
                        // CONTACT US
                        // =========================

                        Text(
                          "Contact us",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Keep contact color unchanged.
                        const Text(
                          "support@happyliver.com",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6FA8DC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 115),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // BOTTOM NAVIGATION
          // =========================

          bottomNavigationBar:
          _buildBottomNavBar(context, isDarkMode),
        );
      },
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

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
            : const Color(0xFFE5F8D8),
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
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            "Help & Feedback",
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white
                  : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HELP ITEM
  // =========================================================

  Widget helpItem({
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: isDarkMode
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
                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                isDarkMode: isDarkMode,
                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: true,
                isDarkMode: isDarkMode,
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
    required bool isDarkMode,
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
            color: selected
                ? Colors.green
                : isDarkMode
                ? Colors.white60
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
                  : isDarkMode
                  ? Colors.white60
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}