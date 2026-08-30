import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() =>
      _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  bool isLoading = true;

  // ============================================================
  // DIET DATA
  // ============================================================

  int dietFollowedDays = 0;
  int healthyDays = 0;
  int dietPercentage = 0;
  int healthyPercentage = 0;
  int averageCalories = 0;

  List<Map<String, dynamic>> dietData = [];

  // ============================================================
  // WORKOUT DATA
  // ============================================================

  int totalWorkout = 0;
  int totalDuration = 0;
  int totalCalories = 0;
  int workoutPercentage = 0;

  String averageIntensity = 'No Data';

  List<Map<String, dynamic>> workoutData = [];

  // ============================================================
  // WEEKLY PROGRESS
  // ============================================================

  int weeklyProgress = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadWeeklyReport();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadWeeklyReport() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final now = DateTime.now();

      // Monday 00:00
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        Duration(days: now.weekday - 1),
      );

      // Next Monday 00:00
      final endOfWeek = startOfWeek.add(
        const Duration(days: 7),
      );

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      // ========================================================
      // DIET LOGS
      // ========================================================

      final dietSnapshot =
      await userRef.collection('diet_logs').get();

      int followedCount = 0;
      int healthyCount = 0;
      int caloriesTotal = 0;
      int dietDays = 0;

      final List<Map<String, dynamic>> loadedDietData = [];

      for (final doc in dietSnapshot.docs) {
        final data = doc.data();

        final DateTime? date =
        _getDate(data['date']);

        if (date == null) continue;

        if (date.isBefore(startOfWeek) ||
            !date.isBefore(endOfWeek)) {
          continue;
        }

        final bool followed =
            data['followed'] == true;

        final bool healthy =
            data['healthy'] == true;

        final int calories =
        _toInt(data['calories']);

        if (followed) {
          followedCount++;
        }

        if (healthy) {
          healthyCount++;
        }

        caloriesTotal += calories;
        dietDays++;

        loadedDietData.add({
          'date': date,
          'calories': calories,
          'followed': followed,
          'healthy': healthy,
        });
      }

      int calculatedDietPercentage = 0;
      int calculatedHealthyPercentage = 0;
      int calculatedAverageCalories = 0;

      if (dietDays > 0) {
        calculatedDietPercentage =
            ((followedCount / 7) * 100).round();

        calculatedHealthyPercentage =
            ((healthyCount / dietDays) * 100).round();

        calculatedAverageCalories =
            (caloriesTotal / dietDays).round();
      }

      // ========================================================
      // WORKOUT LOGS
      // ========================================================

      final workoutSnapshot =
      await userRef.collection('workout_logs').get();

      int workoutCount = 0;
      int durationTotal = 0;
      int workoutCaloriesTotal = 0;

      final List<String> intensities = [];

      final List<Map<String, dynamic>> loadedWorkoutData = [];

      for (final doc in workoutSnapshot.docs) {
        final data = doc.data();

        final DateTime? date =
        _getDate(data['date']);

        if (date == null) continue;

        if (date.isBefore(startOfWeek) ||
            !date.isBefore(endOfWeek)) {
          continue;
        }

        final int calories =
        _toInt(data['calories']);

        final int duration =
        _toInt(data['duration']);

        final String intensity =
            data['intensity']?.toString().trim() ??
                'Moderate';

        workoutCount++;
        durationTotal += duration;
        workoutCaloriesTotal += calories;

        if (intensity.isNotEmpty) {
          intensities.add(intensity);
        }

        loadedWorkoutData.add({
          'date': date,
          'calories': calories,
          'duration': duration,
          'intensity': intensity,
        });
      }

      int calculatedWorkoutPercentage =
      ((workoutCount / 7) * 100).round();

      if (calculatedWorkoutPercentage > 100) {
        calculatedWorkoutPercentage = 100;
      }

      // ========================================================
      // AVERAGE INTENSITY
      // ========================================================

      String calculatedIntensity = 'No Data';

      if (intensities.isNotEmpty) {
        int low = 0;
        int moderate = 0;
        int high = 0;

        for (final item in intensities) {
          switch (item.toLowerCase()) {
            case 'low':
              low++;
              break;

            case 'high':
              high++;
              break;

            case 'moderate':
              moderate++;
              break;

            default:
              moderate++;
          }
        }

        if (high >= moderate && high >= low) {
          calculatedIntensity = 'High';
        } else if (moderate >= low) {
          calculatedIntensity = 'Moderate';
        } else {
          calculatedIntensity = 'Low';
        }
      }

      // ========================================================
      // WEEKLY PROGRESS
      // ========================================================

      int calculatedWeeklyProgress = 0;

      if (calculatedDietPercentage > 0 ||
          calculatedWorkoutPercentage > 0) {
        calculatedWeeklyProgress =
            ((calculatedDietPercentage +
                calculatedWorkoutPercentage) /
                2)
                .round();
      }

      // ========================================================
      // UPDATE UI
      // ========================================================

      if (!mounted) return;

      setState(() {
        // Diet
        dietFollowedDays = followedCount;
        healthyDays = healthyCount;
        dietPercentage = calculatedDietPercentage;
        healthyPercentage = calculatedHealthyPercentage;
        averageCalories = calculatedAverageCalories;
        dietData = loadedDietData;

        // Workout
        totalWorkout = workoutCount;
        totalDuration = durationTotal;
        totalCalories = workoutCaloriesTotal;
        workoutPercentage = calculatedWorkoutPercentage;
        averageIntensity = calculatedIntensity;
        workoutData = loadedWorkoutData;

        // Progress
        weeklyProgress = calculatedWeeklyProgress;

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Weekly Report Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // DATE CONVERTER
  // ============================================================

  DateTime? _getDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ============================================================
  // NUMBER CONVERTER
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              height: 55,
              color: const Color(0xFFDFF7D5),
              padding:
              const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Text(
                    'Weekly Report',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.download,
                    size: 28,
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF22C55E),
                ),
              )
                  : RefreshIndicator(
                onRefresh: loadWeeklyReport,
                child: SingleChildScrollView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _dateSelector(),

                      const SizedBox(height: 10),

                      _weekOverview(),

                      const SizedBox(height: 12),

                      // ==============================
                      // DIET SUMMARY
                      // ==============================

                      _dietSummary(),

                      const SizedBox(height: 12),

                      // ==============================
                      // DIET CHART
                      // ==============================

                      _dietChart(),

                      const SizedBox(height: 12),

                      // ==============================
                      // WORKOUT SUMMARY
                      // ==============================

                      _workoutSummary(),

                      const SizedBox(height: 12),

                      // ==============================
                      // WORKOUT CHART
                      // ==============================

                      _workoutChart(),

                      const SizedBox(height: 12),

                      _weeklyProgress(),

                      const SizedBox(height: 12),

                      _tipOfWeek(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE SELECTOR
  // ============================================================

  Widget _dateSelector() {
    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(days: now.weekday - 1),
    );

    final end = start.add(
      const Duration(days: 6),
    );

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceAround,
      children: [
        const Text(
          '<',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          '${months[start.month - 1]} ${start.day} – '
              '${months[end.month - 1]} ${end.day}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const Text(
          '>',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WEEK OVERVIEW
  // ============================================================

  Widget _weekOverview() {
    final now = DateTime.now();

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(days: now.weekday - 1),
    );

    const dayNames = [
      'MON',
      'TUE',
      'WED',
      'THU',
      'FRI',
      'SAT',
      'SUN',
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFFA),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE8F4E8),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 180,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFD7F8E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '▣  Week Overview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: List.generate(
              7,
                  (index) {
                final date = monday.add(
                  Duration(days: index),
                );

                final hasWorkout =
                workoutData.any((workout) {
                  final workoutDate =
                  workout['date'] as DateTime;

                  return workoutDate.year ==
                      date.year &&
                      workoutDate.month ==
                          date.month &&
                      workoutDate.day ==
                          date.day;
                });

                final hasDiet =
                dietData.any((diet) {
                  final dietDate =
                  diet['date'] as DateTime;

                  return dietDate.year ==
                      date.year &&
                      dietDate.month ==
                          date.month &&
                      dietDate.day ==
                          date.day;
                });

                return Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Icon(
                      Icons.fitness_center,
                      size: 19,
                      color: hasWorkout
                          ? const Color(0xFF22C55E)
                          : Colors.grey,
                    ),

                    const SizedBox(height: 2),

                    Icon(
                      Icons.restaurant,
                      size: 17,
                      color: hasDiet
                          ? const Color(0xFF22C55E)
                          : Colors.grey,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIET SUMMARY
  // ============================================================

  Widget _dietSummary() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE6F0E8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _sectionTitle(
            '🥗',
            'Diet Summary',
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _smallStat(
                  'Plan Followed',
                  '$dietPercentage%',
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _smallStat(
                  'Healthy Choices',
                  '$healthyPercentage%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: _smallStat(
                  'Average Calories',
                  '$averageCalories kcal',
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _smallStat(
                  'Days Recorded',
                  '$dietFollowedDays',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIET CHART
  // ============================================================

  Widget _dietChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🥗',
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(width: 5),
              Text(
                'Diet Weekly Chart',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Daily calories',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 190,
            child: _buildDietBars(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIET BARS
  // ============================================================

  Widget _buildDietBars() {
    final now = DateTime.now();

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(days: now.weekday - 1),
    );

    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    int maxCalories = 0;

    for (final diet in dietData) {
      final calories =
      _toInt(diet['calories']);

      if (calories > maxCalories) {
        maxCalories = calories;
      }
    }

    if (maxCalories == 0) {
      maxCalories = 2000;
    }

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      mainAxisAlignment:
      MainAxisAlignment.spaceAround,
      children: List.generate(
        7,
            (index) {
          final date = monday.add(
            Duration(days: index),
          );

          Map<String, dynamic>? diet;

          for (final item in dietData) {
            final itemDate =
            item['date'] as DateTime;

            if (itemDate.year == date.year &&
                itemDate.month == date.month &&
                itemDate.day == date.day) {
              diet = item;
              break;
            }
          }

          double height = 8;
          int calories = 0;

          if (diet != null) {
            calories =
                _toInt(diet['calories']);

            if (calories > 0) {
              height =
                  (calories / maxCalories * 130)
                      .clamp(15, 130)
                      .toDouble();
            }
          }

          return Column(
            mainAxisAlignment:
            MainAxisAlignment.end,
            children: [
              if (diet != null)
                Text(
                  '$calories',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),

              const SizedBox(height: 3),

              Container(
                width: 25,
                height: height,
                decoration: BoxDecoration(
                  color: diet != null &&
                      diet['healthy'] == true
                      ? const Color(0xFF22C55E)
                      : diet != null
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFE5E7EB),
                  borderRadius:
                  BorderRadius.circular(7),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // WORKOUT SUMMARY
  // ============================================================

  Widget _workoutSummary() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE6F0E8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _sectionTitle(
            '📋',
            'Workout Summary',
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F8E9),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workouts',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                _progressCircle(
                  workoutPercentage,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _smallStat(
                  'Total workout',
                  '$totalWorkout',
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _smallStat(
                  'Total Duration',
                  '${totalDuration}min',
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: _smallStat(
                  'Total calories',
                  '$totalCalories kcal',
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _smallStat(
                  'Avg. Intensity',
                  averageIntensity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKOUT CHART
  // ============================================================

  Widget _workoutChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🏋️',
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(width: 5),
              Text(
                'Workout Weekly Chart',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Daily workout duration (minutes)',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 190,
            child: _buildWorkoutBars(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORKOUT BARS
  // ============================================================

  Widget _buildWorkoutBars() {
    final now = DateTime.now();

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(days: now.weekday - 1),
    );

    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    int maxDuration = 0;

    for (final workout in workoutData) {
      final duration =
      _toInt(workout['duration']);

      if (duration > maxDuration) {
        maxDuration = duration;
      }
    }

    if (maxDuration == 0) {
      maxDuration = 60;
    }

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.end,
      mainAxisAlignment:
      MainAxisAlignment.spaceAround,
      children: List.generate(
        7,
            (index) {
          final date = monday.add(
            Duration(days: index),
          );

          Map<String, dynamic>? workout;

          for (final item in workoutData) {
            final itemDate =
            item['date'] as DateTime;

            if (itemDate.year == date.year &&
                itemDate.month == date.month &&
                itemDate.day == date.day) {
              workout = item;
              break;
            }
          }

          double height = 8;
          int duration = 0;

          if (workout != null) {
            duration =
                _toInt(workout['duration']);

            if (duration > 0) {
              height =
                  (duration / maxDuration * 130)
                      .clamp(15, 130)
                      .toDouble();
            }
          }

          return Column(
            mainAxisAlignment:
            MainAxisAlignment.end,
            children: [
              if (workout != null)
                Text(
                  '${duration}m',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),

              const SizedBox(height: 3),

              Container(
                width: 25,
                height: height,
                decoration: BoxDecoration(
                  color: workout != null
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFE5E7EB),
                  borderRadius:
                  BorderRadius.circular(7),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String icon,
      String title,
      ) {
    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFB7F2CB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(width: 5),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS CIRCLE
  // ============================================================

  Widget _progressCircle(int percentage) {
    return SizedBox(
      width: 55,
      height: 55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 6,
            backgroundColor:
            const Color(0xFFD5D5D5),
            valueColor:
            const AlwaysStoppedAnimation(
              Color(0xFF2CBD59),
            ),
          ),

          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF258847),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL STAT
  // ============================================================

  Widget _smallStat(
      String title,
      String value,
      ) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F9E9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKLY PROGRESS
  // ============================================================

  Widget _weeklyProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                '📊',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),

              SizedBox(width: 5),

              Text(
                'Weekly Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            '$weeklyProgress% overall weekly progress',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Diet: $dietPercentage%  •  '
                'Workout: $workoutPercentage%',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIP OF THE WEEK
  // ============================================================

  Widget _tipOfWeek() {
    String message;

    if (totalWorkout == 0 &&
        dietFollowedDays == 0) {
      message =
      'Start with healthy meals and a workout this week to build your routine!';
    } else if (totalWorkout < 3) {
      message =
      'Good start! Try to stay consistent with your workouts and healthy meals.';
    } else if (dietPercentage >= 70 &&
        workoutPercentage >= 70) {
      message =
      'Excellent work! You are maintaining a strong healthy routine this week.';
    } else {
      message =
      'Keep going! Small consistent healthy choices can make a big difference.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🏅',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),

              SizedBox(width: 5),

              Text(
                'Tip of the week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Padding(
            padding:
            const EdgeInsets.only(left: 20),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}