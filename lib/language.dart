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
          "Language",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(
          left: 28,
          top: 45,
          right: 20,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget languageOption({
    required String language,
    required String value,
  }) {
    final bool isSelected = selectedLanguage == value;

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
}