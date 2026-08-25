import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/risk_level.dart';
import 'assessment_result_screen.dart';

class AssessmentResultLoadingScreen extends StatefulWidget {
  final AssessmentResult result;

  const AssessmentResultLoadingScreen({
    super.key,
    required this.result,
  });

  @override
  State<AssessmentResultLoadingScreen> createState() =>
      _AssessmentResultLoadingScreenState();
}

class _AssessmentResultLoadingScreenState
    extends State<AssessmentResultLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  static const Color darkGreen = Color(0xFF1C5A3C);
  static const Color backgroundGreen = Color(0xFFEAF6E4);
  static const Color textColor = Color(0xFF314337);

  String get userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'User';
  }

  @override
  void initState() {
    super.initState();

    // Hourglass animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Show loading screen for 3 seconds
    Timer(
      const Duration(seconds: 3),
          () {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AssessmentResultScreen(
              fattyLiverRisk: widget.result.fattyLiverRisk,
              cholesterolRisk: widget.result.cholesterolRisk,
              fattyLiverScore: widget.result.fattyLiverScore,
              cholesterolScore: widget.result.cholesterolScore,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // =====================================================
                // GOOD JOB TEXT
                // =====================================================

                const Text(
                  'Good Job Shehani !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 30),

                // =====================================================
                // ASSESSMENT COMPLETED CARD
                // =====================================================

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxWidth: 320,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD7DED8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      const Text(
                        'Assessment Completed !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // =================================================
                      // SAND CLOCK / HOURGLASS
                      // =================================================

                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 6.28318,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F3),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Image.asset(
                            'assets/images/hourglass.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Please wait',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Generating your results...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF66726A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}