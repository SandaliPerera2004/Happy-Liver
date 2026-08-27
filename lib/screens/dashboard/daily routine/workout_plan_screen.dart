import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/custom_bottom_nav.dart';
import '../../assessment/assessment_result_screen.dart';
import '../profile_screen.dart';
import '../../settings/settings.dart';
import 'daily_routine_screen.dart';
import 'workout plan/workout_plan_details.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  static const Color _green = Color(0xFF2DCB59);
  static const Color _lightGreenHeader = Color(0xFFDFF3D8);
  static const Color _lightGreenChip = Color(0xFFE9F9EE);
  static const Color _darkText = Color(0xFF1B1F1D);
  static const Color _grayText = Color(0xFF8A948E);
  static const Color _grayNav = Color(0xFF9AA29D);

  static const List<String> _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  int _selectedDayIndex = 3; // Thu

  final List<_WorkoutItem> _workouts = const [
    _WorkoutItem(
      imageAsset: 'assets/images/march in place.png',
      title: 'March in Place',
      duration: '30 min',
    ),
    _WorkoutItem(
      imageAsset: 'assets/images/Bodyweight_squats.png',
      title: 'Body weight Squats',
      duration: '20 min',
    ),
    _WorkoutItem(
      imageAsset: 'assets/images/yoga_stretches.png',
      title: 'Yoga Stretches',
      duration: '15 min',
    ),
    _WorkoutItem(
      imageAsset: 'assets/images/brisk_walking.png',
      title: 'Brisk Walking',
      duration: '25 min',
    ),
  ];

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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good Morning, Shehani!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildDaySelector(),
                    const SizedBox(height: 20),
                    _buildWeeklyProgressCard(),
                    const SizedBox(height: 22),
                    const Text(
                      "Today's Workouts",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWorkoutGrid(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
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
            'Workout Plan',
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
  // DAY SELECTOR
  // ================================================================
  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_days.length, (index) {
        final bool selected = index == _selectedDayIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedDayIndex = index),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _green : _lightGreenChip,
              shape: BoxShape.circle,
            ),
            child: Text(
              _days[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _darkText,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ================================================================
  // WEEKLY PROGRESS CARD
  // ================================================================
  Widget _buildWeeklyProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              const Spacer(),
              const Text(
                '3/5 completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: 0.6,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: _lightGreenChip,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          _green,
                        ),
                      ),
                    ),
                    const Text(
                      '60%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "You're on track. Keep it up - every session supports "
                      'liver health and cholesterol balance.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _grayText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TODAY'S WORKOUTS — 2x2 GRID
  // ================================================================
  Widget _buildWorkoutGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _workouts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final workout = _workouts[index];
        return _workoutCard(context, workout);
      },
    );
  }

  Widget _workoutCard(BuildContext context, _WorkoutItem workout) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WorkoutDetailScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      workout.imageAsset,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    workout.duration,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _grayText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DailyRoutineScreen()),
      );
      return;
    }

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

  Widget _buildBottomNavBar(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: 1,
      onTap: _onBottomNavTapped,
    );
  }
}

class _WorkoutItem {
  final String imageAsset;
  final String title;
  final String duration;

  const _WorkoutItem({
    required this.imageAsset,
    required this.title,
    required this.duration,
  });
}