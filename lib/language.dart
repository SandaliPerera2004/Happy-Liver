import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
                    ),

                    const SizedBox(height: 18),

                    // Sinhala
                    languageOption(
                      language: "Sinhala",
                      value: "Sinhala",
                    ),

                    const SizedBox(height: 18),

                    // Tamil
                    languageOption(
                      language: "Tamil",
                      value: "Tamil",
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
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // =========================
  // HEADER
  // =========================
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
            child: const Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.black,
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
            color: const Color(0xFF55B85A),
          ),

          const SizedBox(width: 12),

          Text(
            language,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // BOTTOM NAVIGATION
  // =========================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.06),
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

  // =========================
  // BOTTOM NAV ITEM
  // =========================
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
            color:
            selected ? Colors.green : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w700,
              color:
              selected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}