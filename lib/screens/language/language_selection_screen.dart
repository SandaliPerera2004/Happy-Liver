import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:happy_liver/screens/authentication/login_screen.dart';
import 'package:happy_liver/l10n/app_localizations.dart';
import 'package:happy_liver/services/language_controller.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {

  String? selectedLanguageCode;

  // =========================================================
  // SELECT LANGUAGE
  // =========================================================

  Future<void> selectLanguage(String languageCode) async {
    setState(() {
      selectedLanguageCode = languageCode;
    });

    // Change the app language and save it locally
    await LanguageController().changeLanguage(
      languageCode,
    );
  }

  // =========================================================
  // CONTINUE
  // =========================================================

  Future<void> continueNext() async {
    if (selectedLanguageCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseSelectLanguage,
          ),
        ),
      );

      return;
    }

    // =======================================================
    // SAVE LANGUAGE SELECTION
    // =======================================================

    final prefs = await SharedPreferences.getInstance();

    // Mark that language selection has been completed
    await prefs.setBool(
      'languageSelected',
      true,
    );

    // Save language code
    //
    // en = English
    // si = Sinhala
    // ta = Tamil
    await prefs.setString(
      'selectedLanguage',
      selectedLanguageCode!,
    );

    if (!mounted) return;

    // =======================================================
    // GO TO LOGIN
    // =======================================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final localizations =
    AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              // =================================================
              // TITLE
              // =================================================

              Text(
                localizations.chooseYourLanguage,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const SizedBox(height: 40),

              // =================================================
              // ENGLISH
              // =================================================

              languageOption(
                language: 'English',
                languageCode: 'en',
              ),

              // =================================================
              // SINHALA
              // =================================================

              languageOption(
                language: 'සිංහල',
                languageCode: 'si',
              ),

              // =================================================
              // TAMIL
              // =================================================

              languageOption(
                language: 'தமிழ்',
                languageCode: 'ta',
              ),

              const SizedBox(height: 40),

              // =================================================
              // CONTINUE BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: continueNext,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900],
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),

                  child: Text(
                    localizations.continueButton,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LANGUAGE OPTION
  // =========================================================

  Widget languageOption({
    required String language,
    required String languageCode,
  }) {
    final bool isSelected =
        selectedLanguageCode == languageCode;

    return GestureDetector(
      onTap: () async {
        await selectLanguage(languageCode);
      },

      child: Container(
        width: double.infinity,

        margin: const EdgeInsets.only(
          bottom: 15,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withValues(
            alpha: 0.1,
          )
              : Colors.white,

          borderRadius:
          BorderRadius.circular(15),

          border: Border.all(
            width: 2,

            color: isSelected
                ? Colors.green
                : Colors.grey.shade300,
          ),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

          children: [

            Text(
              language,

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}