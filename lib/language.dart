import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
            _buildHeader(context),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 28,
                  top: 45,
                  right: 20,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // English
                    languageOption(
                      language: "English",
                      value: "English",
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 18),

                    // Sinhala
                    languageOption(
                      language: "Sinhala",
                      value: "Sinhala",
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(height: 18),

                    // Tamil
                    languageOption(
                      language: "Tamil",
                      value: "Tamil",
                      isDarkMode: isDarkMode,
                    ),
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
  }

  // =========================
  // HEADER
  // =========================

  Widget _buildHeader(BuildContext context) {
    // Keep the green header in both modes.
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
            "Language",
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

  // =========================
  // LANGUAGE OPTION
  // =========================

  Widget languageOption({
    required String language,
    required String value,
    required bool isDarkMode,
  }) {
    final bool isSelected =
        selectedLanguage == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = value;
        });
      },
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,

            size: 22,

            // Green stays green in dark mode.
            color: const Color(0xFF55B85A),
          ),

          const SizedBox(width: 12),

          Text(
            language,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // BOTTOM NAVIGATION
  // =========================

  Widget _buildBottomNavBar(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      decoration: BoxDecoration(
        // Dark bottom bar in dark mode.
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

  // =========================
  // BOTTOM NAV ITEM
  // =========================

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