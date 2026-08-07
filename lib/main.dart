import 'package:flutter/material.dart';
import 'package:happy_liver/screens/splash/splash_screen.dart';

void main() {
  runApp(const HappyLiverApp());
}

class HappyLiverApp extends StatelessWidget {
  const HappyLiverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Happy Liver",

      home: const SplashScreen(),
    );
  }
}
