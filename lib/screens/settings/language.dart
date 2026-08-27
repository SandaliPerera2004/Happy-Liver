import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../assessment/assessment_result_screen.dart';
import '../dashboard/daily%20routine/daily_routine_screen.dart';
import '../dashboard/profile_screen.dart';
import 'settings.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String subtitle;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.subtitle,
  });
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguageCode = 'en';

  final List<LanguageOption> _languages = const [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      subtitle: 'English (US / UK)',
    ),
    LanguageOption(
      code: 'si',
      name: 'Sinhala',
      nativeName: 'සිංහල',
      subtitle: 'Sinhala (ශ්‍රී ලංකා)',
    ),
    LanguageOption(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      subtitle: 'Tamil (இலங்கை / இந்தியா)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('selected_language_code') ?? 'en';
      if (mounted) {
        setState(() {
          _selectedLanguageCode = code;
        });
      }
    } catch (_) {}
  }

  Future<void> _selectLanguage(String code) async {
    setState(() {
      _selectedLanguageCode = code;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language_code', code);
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Language preference saved'),
          duration: Duration(milliseconds: 1500),
          backgroundColor: Color(0xFF146B0B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7FAF7),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                children: [
                  Text(
                    'Choose your preferred language',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF18321F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select the language you want to use throughout the application.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3 Language Radio Cards
                  ..._languages.map((lang) {
                    final isSelected = _selectedLanguageCode == lang.code;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _selectLanguage(lang.code),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF1E2D1E)
                                    : const Color(0xFFEAF7E7))
                                : (isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF146B0B)
                                  : (isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isSelected ? 0.08 : 0.03,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Radio Button Indicator
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF146B0B)
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.grey.shade400),
                                    width: isSelected ? 6.5 : 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.nativeName,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? (isDark
                                                ? const Color(0xFF81C784)
                                                : const Color(0xFF146B0B))
                                            : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${lang.name} • ${lang.subtitle}",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF146B0B),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
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
            "Language",
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

  void _onBottomNavTapped(BuildContext context, int index) {
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      return;
    }

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
      onTap: (index) => _onBottomNavTapped(context, index),
    );
  }
}