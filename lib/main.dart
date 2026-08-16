import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/exercise_timer_screen.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/workout_plan_details.dart';
import 'firebase_options.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/daily_routine_screen.dart';
import 'package:happy_liver/screens/dashboard/daily%20routine/diet_plan_screen.dart';
import 'package:happy_liver/screens/dashboard/profile_screen.dart';
import 'package:happy_liver/screens/profile/change_password_screen.dart';
import 'package:happy_liver/screens/profile/edit_profile_screen.dart';
import 'package:happy_liver/screens/settings/notification_screen.dart';
import 'package:happy_liver/screens/settings/help_feedback_submitted_screen.dart';
import 'package:happy_liver/screens/settings/about_us_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HappyLiverApp());
}

class HappyLiverApp extends StatelessWidget {
  const HappyLiverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const UserProfileScreen()
    );
  }
}