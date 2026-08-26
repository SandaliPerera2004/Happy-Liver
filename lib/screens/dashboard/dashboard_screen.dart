import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../assessment/assessment_intro_screen.dart';
import '../educational_video/educational_video_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color backgroundColor = Color(0xFFF8FBF7);
  static const Color cardColor = Color(0xFFE4F6DF);
  static const Color darkGreen = Color(0xFF1B6B1A);
  static const Color borderGreen = Color(0xFFA8D7A0);

  String get userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),

              Text(
                'Hello $userName,',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252A25),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Where would you like to begin ?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF303530),
                ),
              ),

              const SizedBox(height: 40),

              // Learn Card
              _DashboardCard(
                iconPath: 'assets/images/book.png',
                title: 'Learn about fatty liver &\nCholesterol',
                subtitle: '👌 Recommended for new users.',
                buttonText: 'Explore Learning',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const EducationalVideoScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Assessment Card
              _DashboardCard(
                iconPath: 'assets/images/bulb.png',
                title: 'Already familiar with fatty\nliver & Cholesterol ?',
                subtitle: "🔎 Let's assess your risk level.",
                buttonText: 'Start Assessment',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const AssessmentIntroScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const _DashboardCard({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  static const Color cardColor = Color(0xFFE4F6DF);
  static const Color darkGreen = Color(0xFF1B6B1A);
  static const Color borderGreen = Color(0xFFA8D7A0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderGreen,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book/Bulb image and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                iconPath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: Color(0xFF263126),
                  ),
                ),
              ),
            ],
          ),

          // Subtitle
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF536053),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Button
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: Colors.black.withValues(alpha: 1),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                      'assets/icons/arrow.svg',
                      width: 18,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}