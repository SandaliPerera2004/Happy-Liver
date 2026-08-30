import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyReportService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER ID
  // ============================================================

  String get userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  // ============================================================
  // WEEK START
  // ============================================================

  DateTime getWeekStart(DateTime date) {
    final day = DateTime(
      date.year,
      date.month,
      date.day,
    );

    return day.subtract(
      Duration(
        days: day.weekday - DateTime.monday,
      ),
    );
  }

  // ============================================================
  // WEEK END
  // ============================================================

  DateTime getWeekEnd(DateTime date) {
    return getWeekStart(date).add(
      const Duration(days: 6),
    );
  }

  // ============================================================
  // DATE ONLY
  // ============================================================

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  // ============================================================
  // GET DIET DATA
  // ============================================================

  Future<List<Map<String, dynamic>>> getDietData(
      DateTime selectedDate,
      ) async {
    final weekStart = getWeekStart(selectedDate);
    final weekEnd = getWeekEnd(selectedDate);

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diet_logs')
        .get();

    final List<Map<String, dynamic>> result = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final dateValue = data['date'];

      if (dateValue is! Timestamp) {
        continue;
      }

      final date = _dateOnly(
        dateValue.toDate(),
      );

      if (!date.isBefore(weekStart) &&
          !date.isAfter(weekEnd)) {
        result.add({
          'id': doc.id,
          ...data,
        });
      }
    }

    result.sort(
          (a, b) {
        final aDate =
        (a['date'] as Timestamp).toDate();

        final bDate =
        (b['date'] as Timestamp).toDate();

        return aDate.compareTo(bDate);
      },
    );

    return result;
  }

  // ============================================================
  // GET WORKOUT DATA
  // ============================================================

  Future<List<Map<String, dynamic>>> getWorkoutData(
      DateTime selectedDate,
      ) async {
    final weekStart = getWeekStart(selectedDate);
    final weekEnd = getWeekEnd(selectedDate);

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_logs')
        .get();

    final List<Map<String, dynamic>> result = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final dateValue = data['date'];

      if (dateValue is! Timestamp) {
        continue;
      }

      final date = _dateOnly(
        dateValue.toDate(),
      );

      if (!date.isBefore(weekStart) &&
          !date.isAfter(weekEnd)) {
        result.add({
          'id': doc.id,
          ...data,
        });
      }
    }

    result.sort(
          (a, b) {
        final aDate =
        (a['date'] as Timestamp).toDate();

        final bDate =
        (b['date'] as Timestamp).toDate();

        return aDate.compareTo(bDate);
      },
    );

    return result;
  }

  // ============================================================
  // GENERATE WEEKLY REPORT
  // ============================================================

  Future<Map<String, dynamic>> generateWeeklyReport(
      DateTime selectedDate,
      ) async {
    final diet =
    await getDietData(selectedDate);

    final workout =
    await getWorkoutData(selectedDate);

    // ==========================================================
    // DIET CALCULATIONS
    // ==========================================================

    int dietCompleted = 0;
    int healthyChoices = 0;
    double totalCalories = 0;

    for (final item in diet) {
      if (item['followed'] == true) {
        dietCompleted++;
      }

      if (item['healthy'] == true) {
        healthyChoices++;
      }

      final calories = item['calories'];

      if (calories is num) {
        totalCalories +=
            calories.toDouble();
      }
    }

    final int dietPercentage =
    ((dietCompleted / 7) * 100)
        .round()
        .clamp(0, 100);

    final int healthyPercentage =
    diet.isEmpty
        ? 0
        : ((healthyChoices / diet.length) * 100)
        .round()
        .clamp(0, 100);

    final int averageCalories =
    diet.isEmpty
        ? 0
        : (totalCalories / diet.length)
        .round();

    // ==========================================================
    // WORKOUT CALCULATIONS
    // ==========================================================

    int workoutCompleted = 0;
    int totalDuration = 0;
    double totalWorkoutCalories = 0;

    final List<String> intensities = [];

    for (final item in workout) {
      if (item['completed'] == true) {
        workoutCompleted++;
      }

      final duration =
      item['durationMinutes'];

      if (duration is num) {
        totalDuration += duration.toInt();
      }

      final calories =
      item['caloriesBurned'];

      if (calories is num) {
        totalWorkoutCalories +=
            calories.toDouble();
      }

      if (item['intensity'] != null) {
        intensities.add(
          item['intensity'].toString(),
        );
      }
    }

    final int workoutPercentage =
    ((workoutCompleted / 7) * 100)
        .round()
        .clamp(0, 100);

    final String averageIntensity =
    calculateAverageIntensity(
      intensities,
    );

    // ==========================================================
    // DAILY DATA
    //
    // Used by:
    // 1. Calendar
    // 2. Calories Chart
    // 3. Workout Chart
    // ==========================================================

    final List<Map<String, dynamic>>
    dailyData = [];

    final weekStart =
    getWeekStart(selectedDate);

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(
        Duration(days: i),
      );

      final dayDiet = diet.where(
            (item) {
          final date =
          (item['date'] as Timestamp)
              .toDate();

          return _dateOnly(date)
              .isAtSameMomentAs(day);
        },
      ).toList();

      final dayWorkout = workout.where(
            (item) {
          final date =
          (item['date'] as Timestamp)
              .toDate();

          return _dateOnly(date)
              .isAtSameMomentAs(day);
        },
      ).toList();

      // --------------------------------------------------------
      // DAILY DIET CALORIES
      // --------------------------------------------------------

      double dayCalories = 0;

      for (final item in dayDiet) {
        final calories =
        item['calories'];

        if (calories is num) {
          dayCalories +=
              calories.toDouble();
        }
      }

      // --------------------------------------------------------
      // DAILY WORKOUT DURATION
      // --------------------------------------------------------

      int dayWorkoutDuration = 0;

      for (final item in dayWorkout) {
        final duration =
        item['durationMinutes'];

        if (duration is num) {
          dayWorkoutDuration +=
              duration.toInt();
        }
      }

      // --------------------------------------------------------
      // DAILY WORKOUT CALORIES
      // --------------------------------------------------------

      int dayWorkoutCalories = 0;

      for (final item in dayWorkout) {
        final calories =
        item['caloriesBurned'];

        if (calories is num) {
          dayWorkoutCalories +=
              calories.toInt();
        }
      }

      // --------------------------------------------------------
      // DAILY STATUS
      // --------------------------------------------------------

      final bool dietDone =
      dayDiet.any(
            (item) =>
        item['followed'] == true,
      );

      final bool workoutDone =
      dayWorkout.any(
            (item) =>
        item['completed'] == true,
      );

      // --------------------------------------------------------
      // STORE DAILY DATA
      // --------------------------------------------------------

      dailyData.add({
        'date': day,
        'dietCalories':
        dayCalories.round(),
        'workoutCalories':
        dayWorkoutCalories,
        'workoutDuration':
        dayWorkoutDuration,
        'dietDone': dietDone,
        'workoutDone': workoutDone,
        'dietData': dayDiet,
        'workoutData': dayWorkout,
      });
    }

    // ==========================================================
    // WEEKLY PROGRESS
    // ==========================================================

    int weeklyProgress = 0;

    try {
      final previousWeek =
      selectedDate.subtract(
        const Duration(days: 7),
      );

      final previous =
      await generateWeeklyReport(
        previousWeek,
      );

      final double currentScore =
          (dietPercentage +
              workoutPercentage) /
              2;

      final int previousDiet =
      previous['dietPercentage']
      as int;

      final int previousWorkout =
      previous['workoutPercentage']
      as int;

      final double previousScore =
          (previousDiet +
              previousWorkout) /
              2;

      if (previousScore == 0) {
        weeklyProgress =
            currentScore.round();
      } else {
        weeklyProgress =
            (((currentScore -
                previousScore) /
                previousScore) *
                100)
                .round();
      }
    } catch (e) {
      weeklyProgress = 0;
    }

    // ==========================================================
    // DAILY CALORIES LIST
    // ==========================================================

    final List<int> dailyCalories =
    dailyData.map<int>(
          (day) {
        return day['dietCalories']
        as int;
      },
    ).toList();

    // ==========================================================
    // DAILY WORKOUT DURATION LIST
    // ==========================================================

    final List<int> dailyWorkoutDuration =
    dailyData.map<int>(
          (day) {
        return day['workoutDuration']
        as int;
      },
    ).toList();

    // ==========================================================
    // FINAL REPORT
    // ==========================================================

    return {
      // --------------------------------------------------------
      // WEEK
      // --------------------------------------------------------

      'weekStart': weekStart,

      'weekEnd':
      getWeekEnd(selectedDate),

      // --------------------------------------------------------
      // DIET
      // --------------------------------------------------------

      'dietCompleted':
      dietCompleted,

      'dietPercentage':
      dietPercentage,

      'healthyChoices':
      healthyChoices,

      'healthyPercentage':
      healthyPercentage,

      'averageCalories':
      averageCalories,

      // --------------------------------------------------------
      // WORKOUT
      // --------------------------------------------------------

      'workoutCompleted':
      workoutCompleted,

      'workoutPercentage':
      workoutPercentage,

      'totalWorkouts':
      workoutCompleted,

      'totalDuration':
      totalDuration,

      'totalWorkoutCalories':
      totalWorkoutCalories.round(),

      'averageIntensity':
      averageIntensity,

      // --------------------------------------------------------
      // CHART DATA
      // --------------------------------------------------------

      'dailyCalories':
      dailyCalories,

      'dailyWorkoutDuration':
      dailyWorkoutDuration,

      // --------------------------------------------------------
      // CALENDAR DATA
      // --------------------------------------------------------

      'dailyData':
      dailyData,

      // --------------------------------------------------------
      // WEEKLY PROGRESS
      // --------------------------------------------------------

      'weeklyProgress':
      weeklyProgress,

      // --------------------------------------------------------
      // RAW DATA
      // --------------------------------------------------------

      'diet': diet,

      'workout': workout,

      // --------------------------------------------------------
      // TIP
      // --------------------------------------------------------

      'weeklyTip': _generateTip(
        dietPercentage,
        workoutPercentage,
      ),
    };
  }

  // ============================================================
  // AVERAGE INTENSITY
  // ============================================================

  String calculateAverageIntensity(
      List<String> intensities,
      ) {
    if (intensities.isEmpty) {
      return 'No data';
    }

    int low = 0;
    int moderate = 0;
    int high = 0;

    for (final value in intensities) {
      final intensity =
      value.toLowerCase().trim();

      if (intensity == 'low') {
        low++;
      } else if (intensity == 'moderate') {
        moderate++;
      } else if (intensity == 'high') {
        high++;
      }
    }

    if (high >= moderate &&
        high >= low) {
      return 'High';
    }

    if (moderate >= low) {
      return 'Moderate';
    }

    return 'Low';
  }

  // ============================================================
  // WEEKLY TIP
  // ============================================================

  String _generateTip(
      int dietPercentage,
      int workoutPercentage,
      ) {
    if (dietPercentage >= 80 &&
        workoutPercentage >= 80) {
      return "Excellent work! you're consistent this week\n"
          "Keep maintaining your healthy diet and workout routine";
    }

    if (dietPercentage >= 70) {
      return "Great job! you're doing well with your diet\n"
          "Try to stay consistent with your workouts";
    }

    if (workoutPercentage >= 70) {
      return "Great workout progress this week!\n"
          "Try to maintain healthy food choices every day";
    }

    return "Keep going! every small step counts\n"
        "Try to improve your diet and workout consistency next week";
  }

  // ============================================================
  // PREVIOUS WEEK
  // ============================================================

  Future<Map<String, dynamic>> getPreviousWeekReport(
      DateTime selectedDate,
      ) async {
    final previousWeek =
    selectedDate.subtract(
      const Duration(days: 7),
    );

    return generateWeeklyReport(
      previousWeek,
    );
  }

  // ============================================================
  // WEEKLY PROGRESS
  // ============================================================

  Future<int> calculateWeeklyProgress(
      DateTime selectedDate,
      ) async {
    final current =
    await generateWeeklyReport(
      selectedDate,
    );

    final previous =
    await getPreviousWeekReport(
      selectedDate,
    );

    final double currentScore =
        ((current['dietPercentage']
        as int) +
            (current['workoutPercentage']
            as int)) /
            2;

    final double previousScore =
        ((previous['dietPercentage']
        as int) +
            (previous['workoutPercentage']
            as int)) /
            2;

    if (previousScore == 0) {
      return currentScore.round();
    }

    return (((currentScore -
        previousScore) /
        previousScore) *
        100).round();
  }
}