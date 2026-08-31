import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Member 1
import 'package:happy_liver/screens/splash/splash_screen.dart';

// Member 3 screens
import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/exercise_timer_screen.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/workout_plan_details.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/workout_plan_screen.dart';
import 'package:happy_liver/services/user_service.dart';
import 'package:happy_liver/settings.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/daily_routine_screen.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/diet_plan_screen.dart';
import 'package:happy_liver/screens/dashboard/profile_screen.dart';
import 'package:happy_liver/screens/profile/change_password_screen.dart';
import 'package:happy_liver/screens/profile/edit_profile_screen.dart';
import 'package:happy_liver/screens/settings/notification_screen.dart';
import 'package:happy_liver/screens/settings/help_feedback_submitted_screen.dart';
import 'package:happy_liver/screens/settings/about_us_screen.dart';

import 'models/app_settings_model.dart';
import 'services/app_settings_service.dart';
import 'services/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Load saved dark mode setting from Firestore
  Future<void> _loadTheme() async {
    try {
      final settings =
      await _appSettingsService.getAppSettings();

      if (!mounted) return;

      setState(() {
        _isDarkMode = settings.darkMode;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDarkMode = false;
        _isLoading = false;
      });
    }
  }

  // Change theme and save it to Firestore
  Future<void> changeTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    try {
      final settings = AppSettingsModel(
        darkMode: value,
      );

      await _appSettingsService.updateAppSettings(settings);
    } catch (e) {
      debugPrint(
        'Failed to save dark mode setting: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loading screen while reading
    // the user's saved theme preference.
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Happy Liver',
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3FBE6B),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happy Liver',

      // LIGHT THEME
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

      // DARK THEME
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

      // Member 1's SplashScreen
      home: SplashScreen(),
    );
  }
}