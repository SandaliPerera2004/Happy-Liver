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

    // =========================================================
    // CHECK FIREBASE AUTHENTICATION
    // =========================================================

    final User? user = FirebaseAuth.instance.currentUser;

    // =========================================================
    // NO LOGGED-IN USER
    // =========================================================

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const LanguageSelectionScreen(),
        ),
      );

      return;
    }

    // =========================================================
    // RETURNING LOGGED-IN USER
    // =========================================================

    debugPrint('====================================');
    debugPrint('RETURNING USER DETECTED');
    debugPrint('UID: ${user.uid}');
    debugPrint('EMAIL: ${user.email}');
    debugPrint('CHECKING ASSESSMENT STATUS...');
    debugPrint('====================================');

    await _routeLoggedInUser(user);
  }

  // =========================================================
  // ROUTE LOGGED-IN USER
  // =========================================================
  // KEPT FOR LATER
  // This is temporarily not called while testing
  // the complete first-time user flow.
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