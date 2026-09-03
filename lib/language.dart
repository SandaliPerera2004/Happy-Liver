import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:happy_liver/services/language_controller.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = "English";

  final LanguageController _languageController =
  LanguageController();

  @override
  void initState() {
    super.initState();

    _loadSelectedLanguage();
  }

  // =========================================================
  // LOAD SAVED LANGUAGE
  // =========================================================

  Future<void> _loadSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final languageCode =
          prefs.getString('selectedLanguage') ?? 'en';

      String languageName;

      switch (languageCode) {
        case 'si':
          languageName = 'Sinhala';
          break;

        case 'ta':
          languageName = 'Tamil';
          break;

        case 'en':
        default:
          languageName = 'English';
          break;
      }

      if (!mounted) return;

      setState(() {
        selectedLanguage = languageName;
      });
    } catch (e) {
      debugPrint(
        'Failed to load selected language: $e',
      );
    }
  }

  // =========================================================
  // CHANGE LANGUAGE
  // =========================================================

  Future<void> _changeLanguage(
      String language,
      String languageCode,
      ) async {
    try {
      // Change language through LanguageController.
      //
      // This will:
      // 1. Change the Locale
      // 2. Notify main.dart
      // 3. Rebuild MaterialApp
      // 4. Save the language preference

      await _languageController.changeLanguage(
        languageCode,
      );

      if (!mounted) return;

      setState(() {
        selectedLanguage = language;
      });

      debugPrint(
        'Language changed to: $language',
      );

      debugPrint(
        'Language code: $languageCode',
      );
    } catch (e) {
      debugPrint(
        'Failed to change language: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to change language',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : Colors.white,

      // =======================================================
      // BODY
      // =======================================================

      body: SafeArea(
        top: true,
        bottom: false,

        child: Column(
          children: [
            _buildHeader(
              context,
              isDarkMode,
            ),

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
                    // =================================================
                    // ENGLISH
                    // =================================================

                    languageOption(
                      language: "English",
                      value: "English",
                      languageCode: "en",
                      isDarkMode: isDarkMode,
                    ),

                    const SizedBox(
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================================================
      // BOTTOM NAVIGATION
      // =========================================================

      bottomNavigationBar:
      _buildBottomNavBar(
        context,
        isDarkMode,
      ),
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

          const SizedBox(
            width: 12,
          ),

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

  // =========================================================
  // LANGUAGE OPTION
  // =========================================================

  Widget languageOption({
    required String language,
    required String value,
    required String languageCode,
    required bool isDarkMode,
  }) {
    final bool isSelected =
        selectedLanguage == value;

    return GestureDetector(
      onTap: () {
        _changeLanguage(
          language,
          languageCode,
        );
      },

      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,

            size: 22,

            color:
            const Color(0xFF55B85A),
          ),

          const SizedBox(
            width: 12,
          ),

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

  // =========================================================
  // BOTTOM NAVIGATION
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
                icon:
                Icons.calendar_today_outlined,
                label: 'Daily Routine',
                selected: false,
                isDarkMode: isDarkMode,

                onTap: () {},
              ),

              _bottomItem(
                icon:
                Icons.person_outline,
                label: 'Profile',
                selected: false,
                isDarkMode: isDarkMode,

                onTap: () {},
              ),

              _bottomItem(
                icon:
                Icons.settings_outlined,
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

          const SizedBox(
            height: 4,
          ),

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