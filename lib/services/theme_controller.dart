import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<bool> isDarkMode =
  ValueNotifier<bool>(false);

  static Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
  }
}