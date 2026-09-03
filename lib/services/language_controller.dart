import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  // =========================================================
  // SINGLETON
  // =========================================================

  static final LanguageController instance =
  LanguageController._internal();

  factory LanguageController() {
    return instance;
  }

  LanguageController._internal();

  // =========================================================
  // CURRENT LANGUAGE
  // =========================================================

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  // =========================================================
  // LOAD SAVED LANGUAGE
  // =========================================================

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selectedLanguage', 'en');

    _locale = const Locale('en');

    notifyListeners();
  }

  // =========================================================
  // CHANGE LANGUAGE
  // =========================================================

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'selectedLanguage',
      languageCode,
    );

    notifyListeners();
  }
}