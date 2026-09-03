import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:happy_liver/screens/dashboard/daily%20routine/workout%20plan/workout_plan_details.dart';
import 'package:happy_liver/models/workout_model.dart';
import 'package:happy_liver/services/workout_service.dart';
import 'package:happy_liver/services/theme_controller.dart';
import 'package:happy_liver/widgets/bottom_navigation_bar.dart';
import 'package:happy_liver/services/workout_progress_service.dart';

class WorkoutPlanScreen extends StatefulWidget {
  // ================================================================
  // RISK LEVEL
  // ================================================================
  //
  // The risk level comes from the assessment result.
  //
  // Valid values:
  //   Low
  //   Moderate
  //   High
  //
  // These are actual risk levels, not workout difficulty levels.
  //
  // Firestore structure:
  //
  // workoutPlans
  //   ├── low
  //   │    └── exercises
  //   ├── moderate
  //   │    └── exercises
  //   └── high
  //        └── exercises
  //
  // ================================================================

  final String riskLevel;

  const WorkoutPlanScreen({
    super.key,
    this.riskLevel = 'Low',
  });

  @override
  State<WorkoutPlanScreen> createState() =>
      _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState
    extends State<WorkoutPlanScreen> {
  // ================================================================
  // COLORS
  // ================================================================

  static const Color _green =
  Color(0xFF2DCB59);

  static const Color _lightGreenHeader =
  Color(0xFFDFF3D8);

  static const Color _lightGreenChip =
  Color(0xFFE9F9EE);

  static const Color _darkText =
  Color(0xFF1B1F1D);

  static const Color _grayText =
  Color(0xFF8A948E);

  // Dark mode colors
  static const Color _darkBackground =
  Color(0xFF121212);

  static const Color _darkCard =
  Color(0xFF1E1E1E);

  // ================================================================
  // SIX WORKOUT DAYS
  // ================================================================

  static const List<String> _days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  // ================================================================
  // SELECTED DAY
  // ================================================================

  int _selectedDayIndex =
  DateTime.now().weekday <= 6
      ? DateTime.now().weekday - 1
      : 0;

  // ================================================================
  // SERVICES
  // ================================================================

  final WorkoutService _workoutService =
  WorkoutService();

  final WorkoutProgressService _progressService =
  WorkoutProgressService();

  // ================================================================
  // DATA
  // ================================================================

  List<WorkoutModel> _workouts = [];

  Map<String, double> _todayProgress = {};

  bool _progressLoading = true;

  // ================================================================
  // INIT STATE
  // ================================================================

  @override
  void initState() {
    super.initState();

    _loadWorkoutProgress();
  }

  // ================================================================
  // LOAD TODAY'S WORKOUT PROGRESS
  // ================================================================

  Future<void> _loadWorkoutProgress() async {
    try {
      final progress =
      await _progressService
          .getTodayWorkoutProgress();

      if (!mounted) return;

      setState(() {
        _todayProgress = progress;
        _progressLoading = false;
      });

      print('====================================');
      print('TODAY WORKOUT PROGRESS');
      print(_todayProgress);
      print('====================================');
    } catch (e) {
      print(
        'ERROR LOADING WORKOUT PROGRESS: $e',
      );

      if (!mounted) return;

      setState(() {
        _progressLoading = false;
      });
    }
  }

  // ================================================================
  // REFRESH WORKOUT PROGRESS
  // ================================================================

  Future<void> _refreshProgress() async {
    await _loadWorkoutProgress();
  }

  // ================================================================
  // NORMALIZE RISK LEVEL
  // ================================================================

  String _normalizedRiskLevel() {
    final level =
    widget.riskLevel.trim().toLowerCase();

    switch (level) {
      case 'high':
        return 'high';

      case 'moderate':
      case 'medium':
        return 'moderate';

      case 'low':
        return 'low';

      default:
        return 'low';
    }
  }

  // ================================================================
  // DISPLAY RISK LEVEL
  // ================================================================

  String _displayRiskLevel() {
    switch (_normalizedRiskLevel()) {
      case 'high':
        return 'High';

      case 'moderate':
        return 'Moderate';

      case 'low':
      default:
        return 'Low';
    }
  }

  // ================================================================
  // TIME-BASED GREETING
  // ================================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // ================================================================
  // GET TODAY'S DAY NAME
  // ================================================================

  String _getTodayName() {
    final weekday = DateTime.now().weekday;

    if (weekday >= 1 && weekday <= 6) {
      return _days[weekday - 1];
    }

    return 'Sun';
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
      ThemeController.isDarkMode,
      builder:
          (context, isDarkMode, child) {
        return Scaffold(
          // ==========================================================
          // BACKGROUND
          // ==========================================================

          backgroundColor: isDarkMode
              ? _darkBackground
              : const Color(0xFFF5F6F8),

          // ==========================================================
          // BODY
          // ==========================================================

          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(
                  context,
                  isDarkMode,
                ),

                Expanded(
                  child: RefreshIndicator(
                    color: _green,
                    onRefresh:
                    _refreshProgress,
                    child:
                    SingleChildScrollView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          // ==================================================
                          // GREETING
                          // ==================================================

                          Text(
                            '${_getGreeting()}, Shehani!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.w800,
                              color: isDarkMode
                                  ? Colors.white
                                  : _darkText,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          // ==================================================
                          // RISK LEVEL
                          // ==================================================

                          Text(
                            '${_displayRiskLevel()} risk workout plan',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight:
                              FontWeight.w500,
                              color: isDarkMode
                                  ? Colors.white60
                                  : _grayText,
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // DAY SELECTOR
                          // ==================================================

                          _buildDaySelector(
                            isDarkMode,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // TODAY'S PROGRESS
                          // ==================================================

                          _buildWeeklyProgressCard(
                            isDarkMode,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          // ==================================================
                          // TODAY'S WORKOUTS TITLE
                          // ==================================================

                          Text(
                            "Today's Workouts",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700,
                              color: isDarkMode
                                  ? Colors.white
                                  : _darkText,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

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
                ),
              ],
            ),
          ),

          // ============================================================
          // SHARED BOTTOM NAVIGATION
          // ============================================================

          bottomNavigationBar:
          HappyLiverBottomNavBar(
            selectedIndex: 1,
            isDarkMode: isDarkMode,
            onThemeChanged:
                (value) async {
              ThemeController
                  .isDarkMode
                  .value = value;
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
    final String riskLevel =
    _normalizedRiskLevel();

    print('====================================');
    print('WORKOUT PLAN');
    print(
      'ORIGINAL RISK LEVEL: ${widget.riskLevel}',
    );
    print(
      'NORMALIZED RISK LEVEL: $riskLevel',
    );
    print(
      'TODAY: ${_getTodayName()}',
    );
    print(
      'FIRESTORE PATH: workoutPlans/$riskLevel/exercises',
    );
    print('====================================');

    return FutureBuilder<List<WorkoutModel>>(
      future:
      _workoutService.getWorkoutsByLevel(
        riskLevel,
      ),
      builder:
          (context, snapshot) {
        print(
          '====================================',
        );

        print(
          'RISK LEVEL: ${widget.riskLevel}',
        );

        print(
          'NORMALIZED LEVEL: $riskLevel',
        );

        print(
          'TODAY: ${_getTodayName()}',
        );

        print(
          'CONNECTION STATE: ${snapshot.connectionState}',
        );

        print(
          'HAS ERROR: ${snapshot.hasError}',
        );

        print(
          'ERROR: ${snapshot.error}',
        );

        print(
          'DATA: ${snapshot.data}',
        );

        print(
          'WORKOUT COUNT: ${snapshot.data?.length}',
        );

        print(
          '====================================',
        );

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding:
              EdgeInsets.all(30),
              child:
              CircularProgressIndicator(
                color: _green,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(20),
            decoration:
            BoxDecoration(
              color: isDarkMode
                  ? _darkCard
                  : Colors.white,
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 35,
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'Unable to load workouts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w700,
                    color: isDarkMode
                        ? Colors.white
                        : _darkText,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  '${snapshot.error}',
                  textAlign:
                  TextAlign.center,
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

        final workouts =
            snapshot.data ?? [];

        if (_workouts.isEmpty &&
            workouts.isNotEmpty) {
          WidgetsBinding.instance
              .addPostFrameCallback(
                (_) {
              if (!mounted) return;

              setState(() {
                _workouts = workouts;
              });
            },
          );
        }

        if (workouts.isEmpty) {
          return Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(25),
            decoration:
            BoxDecoration(
              color: isDarkMode
                  ? _darkCard
                  : Colors.white,
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons
                      .fitness_center_outlined,
                  color: isDarkMode
                      ? Colors.white60
                      : _grayText,
                  size: 35,
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'No workouts available',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w700,
                    color: isDarkMode
                        ? Colors.white
                        : _darkText,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  'No workouts were found for ${_displayRiskLevel()} risk.',
                  textAlign:
                  TextAlign.center,
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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      color: isDarkMode
          ? const Color(0xFFDFF3D8)
          : _lightGreenHeader,
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.maybePop(
                  context,
                ),
            child:
            SvgPicture.asset(
              'assets/icons/Arrow left-circle.svg',
              width: 30,
              height: 30,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Text(
            'Workout Plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.w700,
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
  // DAY SELECTOR — 6 DAYS
  // ================================================================

  Widget _buildDaySelector(
      bool isDarkMode,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: List.generate(
        _days.length,
            (index) {
          final bool selected =
              index ==
                  _selectedDayIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex =
                    index;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                color: selected
                    ? _green
                    : isDarkMode
                    ? const Color(
                  0xFF24452B,
                )
                    : _lightGreenChip,
                shape:
                BoxShape.circle,
              ),
              child: Text(
                _days[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
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
  // PROGRESS CARD
  // ================================================================

  Widget _buildWeeklyProgressCard(
      bool isDarkMode,
      ) {
    double overallProgress =
    0.0;

    int completedCount = 0;

    if (_workouts.isNotEmpty) {
      double totalProgress =
      0.0;

      for (final workout
      in _workouts) {
        final progress =
            _todayProgress[
            workout.id] ??
                0.0;

        totalProgress += progress;

        if (progress >= 1.0) {
          completedCount++;
        }
      }

      overallProgress =
          totalProgress /
              _workouts.length;
    }

    final int percentage =
    (overallProgress * 100)
        .round();

    final int totalWorkouts =
        _workouts.length;

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: isDarkMode
            ? _darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              isDarkMode
                  ? 0.25
                  : 0.05,
            ),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                  color: isDarkMode
                      ? Colors.white
                      : _darkText,
                ),
              ),

              const Spacer(),

              if (_progressLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _green,
                  ),
                )
              else
                Text(
                  totalWorkouts == 0
                      ? '0/0 completed'
                      : '$completedCount/$totalWorkouts completed',
                  style:
                  const TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                    color: _green,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment:
                  Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child:
                      CircularProgressIndicator(
                        value:
                        overallProgress,
                        strokeWidth: 6,
                        strokeCap:
                        StrokeCap.round,
                        backgroundColor:
                        isDarkMode
                            ? const Color(
                          0xFF315238,
                        )
                            : _lightGreenChip,
                        valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                          _green,
                        ),
                      ),
                    ),

                    Text(
                      '$percentage%',
                      style:
                      TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w800,
                        color: isDarkMode
                            ? Colors.white
                            : _darkText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Text(
                  overallProgress >=
                      1.0
                      ? 'Great job! You completed all today\'s workouts. Keep it up!'
                      : overallProgress > 0
                      ? 'You\'re making progress. Complete your remaining workouts to stay on track.'
                      : 'Start your workout today. Every session supports liver health and cholesterol balance.',
                  style:
                  TextStyle(
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
      itemCount:
      workouts.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder:
          (context, index) {
        final workout =
        workouts[index];

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
    final double progress =
        _todayProgress[
        workout.id] ??
            0.0;

    final bool completed =
        progress >= 1.0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                WorkoutDetailScreen(
                  workout: workout,
                ),
          ),
        );

        await _loadWorkoutProgress();
      },

      child: Container(
        decoration:
        BoxDecoration(
          color: isDarkMode
              ? _darkCard
              : Colors.white,
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                isDarkMode
                    ? 0.25
                    : 0.05,
              ),
              blurRadius: 8,
              offset:
              const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius
                    .vertical(
                  top: Radius.circular(
                    16,
                  ),
                ),
                child: Stack(
                  alignment:
                  Alignment.center,
                  children: [
                    Image.network(
                      workout.imageUrl,
                      width:
                      double.infinity,
                      height:
                      double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color: isDarkMode
                              ? const Color(
                            0xFF24452B,
                          )
                              : _lightGreenChip,
                          child:
                          const Center(
                            child: Icon(
                              Icons
                                  .fitness_center,
                              size: 40,
                              color:
                              _green,
                            ),
                          ),
                        );
                      },
                    ),

                    Container(
                      width: 34,
                      height: 34,
                      decoration:
                      BoxDecoration(
                        color: _green,
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          color:
                          Colors.white,
                          width: 2,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons.play_arrow,
                        color:
                        Colors.white,
                        size: 18,
                      ),
                    ),

                    if (completed)
                      Positioned(
                        top: 8,
                        right: 8,
                        child:
                        Container(
                          width: 28,
                          height: 28,
                          decoration:
                          const BoxDecoration(
                            color:
                            _green,
                            shape:
                            BoxShape
                                .circle,
                          ),
                          child:
                          const Icon(
                            Icons.check,
                            color:
                            Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                    if (!completed &&
                        progress > 0)
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child:
                        Container(
                          height: 5,
                          decoration:
                          BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              0.5,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              10,
                            ),
                          ),
                          child:
                          FractionallySizedBox(
                            alignment:
                            Alignment
                                .centerLeft,
                            widthFactor:
                            progress,
                            child:
                            Container(
                              decoration:
                              BoxDecoration(
                                color:
                                _green,
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                10,
                8,
                10,
                8,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    workout.name,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w800,
                      color: isDarkMode
                          ? Colors.white
                          : _darkText,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

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