import 'package:flutter/material.dart';
import 'screens/settings/help_feedback_submitted_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/services/theme_controller.dart';

class ReportProblem extends StatefulWidget {
  const ReportProblem({super.key});

  @override
  State<ReportProblem> createState() => _ReportProblemState();
}

class _ReportProblemState extends State<ReportProblem> {
  final TextEditingController problemController =
  TextEditingController();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color _green = Color(0xFF16A000);
  static const Color _lightGreenHeader = Color(0xFFE5F8D8);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkInput = Color(0xFF2A2A2A);
  static const Color _darkNav = Color(0xFF1E1E1E);

  @override
  void dispose() {
    problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          // ==========================================================
          // BACKGROUND
          // ==========================================================

          backgroundColor:
          isDarkMode ? _darkBackground : Colors.white,

          // ==========================================================
          // BODY
          // ==========================================================

          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 38),

                          // ==================================================
                          // REPORT A PROBLEM TITLE
                          // ==================================================

                          Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 30,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Report a problem",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // ==================================================
                          // WHAT WENT WRONG?
                          // ==================================================

                          Text(
                            "What went wrong?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ==================================================
                          // PROBLEM TEXT BOX
                          // ==================================================

                          Container(
                            width: double.infinity,
                            height: 116,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? _darkInput
                                  : const Color(0xFFE0E0E0),
                            ),
                            child: TextField(
                              controller: problemController,
                              maxLines: 5,

                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                              ),

                              cursorColor: _green,

                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                "Describe the problem...",
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // ==================================================
                          // SUBMIT REPORT BUTTON
                          // ==================================================

                          Center(
                            child: SizedBox(
                              width: 137,
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (problemController.text
                                      .trim()
                                      .isEmpty) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please describe the problem.",
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const FeedbackSubmittedScreen(),
                                      ),
                                    );
                                  }
                                },

                                style:
                                ElevatedButton.styleFrom(
                                  backgroundColor: _green,
                                  foregroundColor:
                                  Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                ),

                                child: const Text(
                                  "Submit Report",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // DARK MODE SWITCH
                          // ==================================================

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
                                    fontWeight:
                                    FontWeight.w600,
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
                                inactiveThumbColor:
                                Colors.grey,
                                inactiveTrackColor:
                                Colors.grey.withOpacity(0.25),
                                onChanged: (value) async {
                                  await ThemeController
                                      .setDarkMode(value);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // BOTTOM NAVIGATION
          // ============================================================

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
            ? _darkNav
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