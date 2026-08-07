import 'dart:async';
import 'package:flutter/material.dart';
import 'package:happy_liver/screens/language/language_selection_screen.dart'; // Change this to your next screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // Move to next screen after 3 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LanguageSelectionScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // Application Logo
            Image.asset(
              'assets/images/logo.png',
              width: 360,
              height: 360,
            ),

            const SizedBox(height: 25),

          ],
        ),
      ),
    );
  }
}

