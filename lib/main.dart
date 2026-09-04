import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Member 1
import 'package:happy_liver/screens/splash/splash_screen.dart';

// Member 3 screens
import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/exercise_timer_screen.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/daily_routine_screen.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/workout_plan_screen.dart';
import 'package:happy_liver/services/user_service.dart';
import 'package:happy_liver/settings.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/diet_plan_screen.dart';
import 'package:happy_liver/screens/dashboard/profile_screen.dart';
import 'package:happy_liver/screens/profile/change_password_screen.dart';
import 'package:happy_liver/screens/profile/edit_profile_screen.dart';
import 'package:happy_liver/screens/settings/notification_screen.dart';
import 'package:happy_liver/screens/settings/help_feedback_submitted_screen.dart';
import 'package:happy_liver/screens/settings/about_us_screen.dart';
import 'package:happy_liver/screens/start/app_start_screen.dart';

import 'models/app_settings_model.dart';
import 'services/app_settings_service.dart';
import 'services/theme_controller.dart';
import 'services/local_notification_service.dart';

// Localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// Language
import 'package:happy_liver/services/language_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalNotificationService().initialize();

  runApp(const HappyLiverApp());
}

class HappyLiverApp extends StatefulWidget {
  const HappyLiverApp({super.key});

  @override
  State<HappyLiverApp> createState() => _HappyLiverAppState();
}

class _HappyLiverAppState extends State<HappyLiverApp> {
  final AppSettingsService _appSettingsService =
  AppSettingsService();

  final LanguageController _languageController =
  LanguageController();

  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Listen for language changes
    _languageController.addListener(
      _onLanguageChanged,
    );

    _loadSettings();
  }

  // =========================================================
  // LANGUAGE CHANGE LISTENER
  // =========================================================

  void _onLanguageChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _languageController.removeListener(
      _onLanguageChanged,
    );

    super.dispose();
  }

  // =========================================================
  // LOAD SAVED SETTINGS
  // =========================================================

  Future<void> _loadSettings() async {
    try {
      // Load saved language
      await _languageController.loadLanguage();

      // Load saved dark mode setting
      final settings =
      await _appSettingsService.getAppSettings();

      if (!mounted) return;

      setState(() {
        _isDarkMode = settings.darkMode;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Failed to load app settings: $e',
      );

      if (!mounted) return;

      setState(() {
        _isDarkMode = false;
        _isLoading = false;
      });
    }
  }

  // =========================================================
  // CHANGE LANGUAGE
  // =========================================================

  Future<void> changeLanguage(
      String languageCode) async {
    await _languageController.changeLanguage(
      languageCode,
    );
  }

  // =========================================================
  // CHANGE THEME
  // =========================================================

  Future<void> changeTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    try {
      final settings = AppSettingsModel(
        darkMode: value,
      );

      await _appSettingsService.updateAppSettings(
        settings,
      );
    } catch (e) {
      debugPrint(
        'Failed to save dark mode setting: $e',
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    // =======================================================
    // LOADING
    // =======================================================

    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Happy Liver',

        locale: _languageController.locale,

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        supportedLocales: const [
          Locale('en'),
          Locale('si'),
          Locale('ta'),
        ],

        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3FBE6B),
            ),
          ),
        ),
      );
    }

    // =======================================================
    // MAIN MATERIAL APP
    // =======================================================

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // =====================================================
      // LANGUAGE
      // =====================================================

      locale: _languageController.locale,

      // =====================================================
      // LOCALIZATION
      // =====================================================

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],

      title: 'Happy Liver',

      // =====================================================
      // LIGHT THEME
      // =====================================================

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3FBE6B),
          surface: Colors.white,
          onSurface: Colors.black,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE5F8D8),
          foregroundColor: Colors.black,
        ),

        cardColor: Colors.white,

        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      // =====================================================
      // DARK THEME
      // =====================================================

      themeMode: _isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      darkTheme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor:
        const Color(0xFF121212),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3FBE6B),
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),

        cardColor: const Color(0xFF1E1E1E),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE5F8D8),
          foregroundColor: Colors.black,
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      // =====================================================
      // APP START
      // =====================================================

      home: const AppStartScreen(),
    );
  }
}