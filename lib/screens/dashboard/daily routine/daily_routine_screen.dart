import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/custom_bottom_nav.dart';
import '../../assessment/assessment_result_screen.dart';
import '../profile_screen.dart';
import '../../settings/settings.dart';
import 'diet_plan_screen.dart';
import 'workout_plan_screen.dart';

class DailyRoutineScreen extends StatelessWidget {
  const DailyRoutineScreen({super.key});

  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _cardBg = Color(0xFFEAF7E9);
  static const Color _darkText = Color(0xFF1B3B1F);
  static const Color _grayText = Color(0xFF6B756E);

  void _onBottomNavTapped(BuildContext context, int index) {
    if (index == 1) return; // Already on Daily Routine

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AssessmentResultScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(),
                    const SizedBox(height: 24),
                    _routineCard(
                      context: context,
                      imageAsset: 'assets/images/Food bowl 1.png',
                      title: 'Diet Plan',
                      description:
                      'Explore healthy meal plans tailored for you.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DietPlanScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _routineCard(
                      context: context,
                      imageAsset: 'assets/images/watter bottle 1.png',
                      title: 'Workout Plan',
                      description:
                      'Discover effective workouts to keep you active.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkoutPlanScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) => _onBottomNavTapped(context, index),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: _lightGreenHeader,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Daily Routine',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HERO — tagline + illustration
  // ================================================================
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Daily Routine',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Small daily steps lead to lasting liver health. Follow your plan consistently.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _grayText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/daily.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.calendar_month_rounded,
              size: 60,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ROUTINE CARD — Diet Plan / Workout Plan
  // ================================================================
  Widget _routineCard({
    required BuildContext context,
    required String imageAsset,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: _green,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: _grayText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF9E9E9E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}