import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../splash/splash_screen.dart';
import '../language/language_selection_screen.dart';
import 'package:happy_liver/screens/authentication/login_screen.dart';
import '../assessment/assessment_intro_screen.dart';
import '../assessment/assessment_result_screen.dart';
import '../../services/assessment_firestore_service.dart';
import '../../models/risk_level.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  // =========================================================
  // START APP
  // =========================================================

  Future<void> _startApp() async {
    // Small startup delay
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    // =========================================================
    // RETURNING LOGGED-IN USER
    // =========================================================

    if (user != null) {
      await _routeLoggedInUser(user);
      return;
    }

    // =========================================================
    // USER IS NOT LOGGED IN
    // =========================================================

    final prefs =
    await SharedPreferences.getInstance();

    final languageSelected =
        prefs.getBool('languageSelected') ?? false;

    if (!mounted) return;

    // =========================================================
    // LANGUAGE NOT SELECTED
    // =========================================================

    if (!languageSelected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const LanguageSelectionScreen(),
        ),
      );
    }

    // =========================================================
    // LANGUAGE ALREADY SELECTED
    // =========================================================

    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const LoginScreen(),
        ),
      );
    }
  }

  // =========================================================
  // ROUTE LOGGED-IN USER
  // =========================================================

  Future<void> _routeLoggedInUser(User user) async {
    try {
      // =======================================================
      // GET USER DOCUMENT
      // =======================================================

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      bool assessmentCompleted = false;

      if (userDoc.exists) {
        final data = userDoc.data();

        assessmentCompleted =
            data?['assessmentCompleted'] == true;
      }

      // =======================================================
      // FALLBACK:
      // CHECK ASSESSMENTS COLLECTION
      // =======================================================

      if (!assessmentCompleted) {
        final assessmentSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('assessments')
            .limit(1)
            .get();

        if (assessmentSnapshot.docs.isNotEmpty) {
          assessmentCompleted = true;
        }
      }

      if (!mounted) return;

      // =======================================================
      // ASSESSMENT COMPLETED
      // =======================================================
      //
      // IMPORTANT:
      // Do NOT go to DashboardScreen here.
      //
      // Get the latest assessment result and open
      // AssessmentResultScreen directly.
      // =======================================================

      if (assessmentCompleted) {
        final result =
        await AssessmentFirestoreService
            .getLatestAssessmentResult();

        if (!mounted) return;

        // =====================================================
        // LATEST RESULT FOUND
        // =====================================================

        if (result != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AssessmentResultScreen(
                    result: result,

                    // Change these if you already have a
                    // different theme controller.
                    isDarkMode: false,

                    onThemeChanged:
                        (bool value) async {
                      // Theme callback
                    },
                  ),
            ),
                (route) => false,
          );

          return;
        }

        // =====================================================
        // ASSESSMENT FLAG EXISTS BUT RESULT NOT FOUND
        // =====================================================

        // This protects the app from getting stuck if the
        // user document says completed but the assessment
        // document is missing.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const AssessmentIntroScreen(),
          ),
              (route) => false,
        );

        return;
      }

      // =======================================================
      // ASSESSMENT NOT COMPLETED
      // =======================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const AssessmentIntroScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      debugPrint(
        'Error checking returning user: $e',
      );

      if (!mounted) return;

      // =======================================================
      // FALLBACK
      // =======================================================
      //
      // If Firestore fails, send the user to assessment
      // instead of incorrectly showing an old dashboard.
      // =======================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const AssessmentIntroScreen(),
        ),
            (route) => false,
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}