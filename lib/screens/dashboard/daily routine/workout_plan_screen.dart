import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/workout_plan_details.dart';
import 'package:happy_liver/models/workout_model.dart';
import 'package:happy_liver/services/workout_service.dart';
import 'package:happy_liver/services/theme_controller.dart';
import 'package:happy_liver/widgets/bottom_navigation_bar.dart';

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

  // Dark mode colors
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);

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
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          // ============================================================
          // BACKGROUND
          // ============================================================

          backgroundColor: isDarkMode
              ? _darkBackground
              : const Color(0xFFF5F6F8),

          // ============================================================
          // BODY
          // ============================================================

          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context, isDarkMode),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // GREETING
                        // ==================================================

                        Text(
                          'Good Morning, Shehani!',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode
                                ? Colors.white
                                : _darkText,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // DAY SELECTOR
                        // ==================================================

                        _buildDaySelector(isDarkMode),

                        const SizedBox(height: 20),

                        // ==================================================
                        // WEEKLY PROGRESS
                        // ==================================================

                        _buildWeeklyProgressCard(isDarkMode),

                        const SizedBox(height: 22),

                        // ==================================================
                        // TODAY'S WORKOUTS TITLE
                        // ==================================================

                        Text(
                          "Today's Workouts",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? Colors.white
                                : _darkText,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // WORKOUTS
                        // ==================================================

                        _buildWorkoutSection(
                          context,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // SHARED BOTTOM NAVIGATION
          // ============================================================
          //
          // 0 = Home
          // 1 = Daily Routine
          // 2 = Profile
          // 3 = Settings
          //
          // Workout Plan belongs to Daily Routine
          // Therefore selectedIndex = 1
          //

          bottomNavigationBar: HappyLiverBottomNavBar(
            selectedIndex: 1,
            isDarkMode: isDarkMode,
            onThemeChanged: (value) async {
              ThemeController.isDarkMode.value = value;
            },
          ),
        );
      },
    );
  }

  // ================================================================
  // LOAD WORKOUTS FROM FIRESTORE
  // ================================================================

  Widget _buildWorkoutSection(
      BuildContext context,
      bool isDarkMode,
      ) {
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

        // ============================================================
        // LOADING
        // ============================================================

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

        // ============================================================
        // ERROR
        // ============================================================

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? _darkCard
                  : Colors.white,
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

                Text(
                  'Unable to load workouts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? Colors.white
                        : _darkText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? Colors.white60
                        : _grayText,
                  ),
                ),
              ],
            ),
          );
        }

        final workouts = snapshot.data ?? [];

        // ============================================================
        // NO WORKOUTS
        // ============================================================

        if (workouts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? _darkCard
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  color: isDarkMode
                      ? Colors.white60
                      : _grayText,
                  size: 35,
                ),

                const SizedBox(height: 10),

                Text(
                  'No workouts available',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? Colors.white
                        : _darkText,
                  ),
                ),
              ],
            ),
          );
        }

        // ============================================================
        // WORKOUT GRID
        // ============================================================

        return _buildWorkoutGrid(
          context,
          workouts,
          isDarkMode,
        );
      },
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader(
      BuildContext context,
      bool isDarkMode,
      ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      color: isDarkMode
          ? const Color(0xFFDFF3D8)
          : _lightGreenHeader,

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

          Text(
            'Workout Plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DAY SELECTOR
  // ================================================================

  Widget _buildDaySelector(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: List.generate(
        _days.length,
            (index) {
          final bool selected =
              index == _selectedDayIndex;

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
                    : isDarkMode
                    ? const Color(0xFF24452B)
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
                      : isDarkMode
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

  Widget _buildWeeklyProgressCard(bool isDarkMode) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? 0.25 : 0.05,
            ),

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
              Text(
                'Weekly Progress',

                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,

                  color: isDarkMode
                      ? Colors.white
                      : _darkText,
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
            crossAxisAlignment:
            CrossAxisAlignment.center,

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

                        backgroundColor: isDarkMode
                            ? const Color(0xFF315238)
                            : _lightGreenChip,

                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          _green,
                        ),
                      ),
                    ),

                    Text(
                      '60%',

                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,

                        color: isDarkMode
                            ? Colors.white
                            : _darkText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  "You're on track. Keep it up - every session "
                      "supports liver health and cholesterol balance.",

                  style: TextStyle(
                    fontSize: 12.5,

                    color: isDarkMode
                        ? Colors.white60
                        : _grayText,

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
      bool isDarkMode,
      ) {
    return GridView.builder(
      shrinkWrap: true,

      physics:
      const NeverScrollableScrollPhysics(),

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
          isDarkMode,
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
      bool isDarkMode,
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
          color: isDarkMode
              ? _darkCard
              : Colors.white,

          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDarkMode ? 0.25 : 0.05,
              ),

              blurRadius: 8,

              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ======================================================
            // IMAGE
            // ======================================================

            AspectRatio(
              aspectRatio: 1.5,

              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),

                child: Stack(
                  alignment: Alignment.center,

                  children: [
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
                          color: isDarkMode
                              ? const Color(0xFF24452B)
                              : _lightGreenChip,

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

                    // ==================================================
                    // PLAY BUTTON
                    // ==================================================

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

            // ======================================================
            // WORKOUT INFORMATION
            // ======================================================

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
                  // ------------------------------------------------
                  // WORKOUT NAME
                  // ------------------------------------------------

                  Text(
                    workout.name,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 15,

                      fontWeight:
                      FontWeight.w800,

                      color: isDarkMode
                          ? Colors.white
                          : _darkText,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // ------------------------------------------------
                  // DURATION
                  // ------------------------------------------------

                  Text(
                    '${workout.duration} min',

                    style: TextStyle(
                      fontSize: 13,

                      color: isDarkMode
                          ? Colors.white60
                          : _grayText,
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
}