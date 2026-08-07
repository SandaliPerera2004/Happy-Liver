import 'package:flutter/material.dart';
import 'package:happy_liver/screens/dashboard/profile_screen.dart';
import 'package:happy_liver/screens/profile/change_password_screen.dart';
import 'package:happy_liver/screens/profile/edit_profile_screen.dart';
import 'package:happy_liver/screens/settings/notification_screen.dart';
import 'package:happy_liver/screens/settings/help_feedback_submitted_screen.dart';
import 'package:happy_liver/screens/settings/about_us_screen.dart';

void main() {
  runApp(const HappyLiverApp());
}

class HappyLiverApp extends StatelessWidget {
  const HappyLiverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const EditProfileScreen(),
    );
  }
}