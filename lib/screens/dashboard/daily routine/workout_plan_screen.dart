import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/workout_plan_details.dart';
import 'package:happy_liver/models/workout_model.dart';
import 'package:happy_liver/services/workout_service.dart';

class WorkoutPlanScreen extends StatefulWidget {
  // TEMPORARY:
  // Later this will come from the assessment results.
  final String riskLevel;

  const WorkoutPlanScreen({
    super.key,
    this.riskLevel = 'Low',
  });

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

  final WorkoutService _workoutService = WorkoutService();

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

                    _buildWorkoutSection(context),
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
  // LOAD WORKOUTS FROM FIRESTORE
  // ================================================================
  Widget _buildWorkoutSection(BuildContext context) {
    return FutureBuilder<List<WorkoutModel>>(
      future: _workoutService.getWorkoutsByLevel(
        widget.riskLevel,
      ),
      builder: (context, snapshot) {
        print('====================================');
        print('RISK LEVEL: ${widget.riskLevel}');
        print('CONNECTION STATE: ${snapshot.connectionState}');
        print('HAS ERROR: ${snapshot.hasError}');
        print('ERROR: ${snapshot.error}');
        print('DATA: ${snapshot.data}');
        print('WORKOUT COUNT: ${snapshot.data?.length}');
        print('====================================');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(
                color: _green,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 35,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Unable to load workouts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _grayText,
                  ),
                ),
              ],
            ),
          );
        }

        final workouts = snapshot.data ?? [];

        if (workouts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  color: _grayText,
                  size: 35,
                ),
                SizedBox(height: 10),
                Text(
                  'No workouts available',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
              ],
            ),
          );
        }

        return _buildWorkoutGrid(
          context,
          workouts,
        );
      },
    );
  }

  // ================================================================
  // HEADER
  // ================================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
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
      children: List.generate(
        _days.length,
            (index) {
          final bool selected = index == _selectedDayIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },

            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: selected
                    ? _green
                    : _lightGreenChip,
                shape: BoxShape.circle,
              ),

              child: Text(
                _days[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : _darkText,
                ),
              ),
            ),
          );
        },
      ),
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
                '3/4 completed',
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

                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
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
  Widget _buildWorkoutGrid(
      BuildContext context,
      List<WorkoutModel> workouts,
      ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: workouts.length,

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),

      itemBuilder: (context, index) {
        final workout = workouts[index];

        return _workoutCard(
          context,
          workout,
        );
      },
    );
  }

  // ================================================================
  // WORKOUT CARD
  // ================================================================
  Widget _workoutCard(
      BuildContext context,
      WorkoutModel workout,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(
              workout: workout,
            ),
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
                    // ------------------------------------------------
                    // WORKOUT IMAGE
                    // ------------------------------------------------
                    Image.network(
                      workout.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,

                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color: _lightGreenChip,
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center,
                              size: 40,
                              color: _green,
                            ),
                          ),
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // PLAY BUTTON
                    // ------------------------------------------------
                    Container(
                      width: 34,
                      height: 34,

                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,

                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
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
              padding: const EdgeInsets.fromLTRB(
                10,
                8,
                10,
                8,
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // --------------------------------------------------
                  // WORKOUT NAME
                  // --------------------------------------------------
                  Text(
                    workout.name,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // --------------------------------------------------
                  // DURATION
                  // --------------------------------------------------
                  Text(
                    '${workout.duration} min',

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

  // ================================================================
  // BOTTOM NAVIGATION BAR
  // ================================================================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.06),
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,

            children: [
              _bottomItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,

                onTap: () {
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },
              ),

              _bottomItem(
                icon: Icons.calendar_today_outlined,
                label: 'Daily Routine',
                selected: true,

                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,

                onTap: () {},
              ),

              _bottomItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: false,

                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // BOTTOM NAVIGATION ITEM
  // ================================================================
  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            size: 22,
            color: selected
                ? _green
                : _grayNav,
          ),

          const SizedBox(height: 4),

          Text(
            label,

            style: TextStyle(
              fontSize: 10,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w700,
              color: selected
                  ? _green
                  : _grayNav,
            ),
          ),
        ],
      ),
    );
  }
}