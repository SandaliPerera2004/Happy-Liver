import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../assessment/assessment_intro_screen.dart';
import '../assessment/assessment_result_screen.dart';
import '../educational_video/educational_video_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color backgroundColor = Color(0xFFF8FBF7);
  static const Color darkGreen = Color(0xFF1B6B1A);

  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final name = data['username'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            if (mounted) {
              setState(() {
                _username = name.trim();
              });
            }
            return;
          }
        }

        if (mounted) {
          setState(() {
            _username = user.displayName ?? 'User';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _username = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _username.isNotEmpty ? _username : 'User';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header Row with Greeting & Home Icon Shortcut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Hello $displayName,',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF252A25),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.home_rounded,
                      color: darkGreen,
                      size: 32,
                    ),
                    tooltip: 'Go to Home / Results',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AssessmentResultScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'Where would you like to begin ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF303530),
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 20),

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

              const SizedBox(height: 24),

              // Prominent Button to go to Home (Assessment Results)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AssessmentResultScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.assessment_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: const Text(
                    'Go to Home (Assessment Results)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
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
      constraints: const BoxConstraints(minHeight: 170),
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
            color: Colors.black.withValues(alpha: 0.12),
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
                    fontSize: 20,
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
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
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
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      'assets/icons/arrow.svg',
                      width: 16,
                      height: 16,
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