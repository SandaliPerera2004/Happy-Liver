import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyReportData {
  final DateTime weekStart;
  final DateTime weekEnd;

  // Diet
  final int dietFollowedDays;
  final int dietPercentage;
  final int healthyChoices;
  final int averageCalories;

  // Workout
  final int workoutsCompleted;
  final int workoutPercentage;
  final int totalDuration;
  final int totalCalories;
  final String averageIntensity;

  // Progress
  final int currentScore;
  final int previousScore;
  final int improvement;

  // Daily status
  final List<bool> workoutDays;
  final List<bool> dietDays;

  // Tip
  final String tip;

  WeeklyReportData({
    required this.weekStart,
    required this.weekEnd,
    required this.dietFollowedDays,
    required this.dietPercentage,
    required this.healthyChoices,
    required this.averageCalories,
    required this.workoutsCompleted,
    required this.workoutPercentage,
    required this.totalDuration,
    required this.totalCalories,
    required this.averageIntensity,
    required this.currentScore,
    required this.previousScore,
    required this.improvement,
    required this.workoutDays,
    required this.dietDays,
    required this.tip,
  });
}

class WeeklyReportService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // GET CURRENT WEEK
  // Monday -> Sunday
  // ============================================================

  DateTime getCurrentMonday() {
    final now = DateTime.now();

    final difference =
        now.weekday - DateTime.monday;

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(days: difference),
    );

    return monday;
  }

  DateTime getSunday(DateTime monday) {
    return monday.add(
      const Duration(days: 6),
    );
  }

  // ============================================================
  // MAIN REPORT FUNCTION
  // ============================================================

  Future<WeeklyReportData> getWeeklyReport({
    DateTime? selectedWeekStart,
  }) async {

    final userId = currentUserId;

    if (userId == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final weekStart =
        selectedWeekStart ??
            getCurrentMonday();

    final weekEnd =
    getSunday(weekStart);

    // Current week data
    final workoutDocuments =
    await _getWorkoutDocuments(
      userId,
      weekStart,
      weekEnd,
    );

    final dietDocuments =
    await _getDietDocuments(
      userId,
      weekStart,
      weekEnd,
    );

    // Previous week
    final previousWeekStart =
    weekStart.subtract(
      const Duration(days: 7),
    );

    final previousWeekEnd =
    weekStart.subtract(
      const Duration(days: 1),
    );

    final previousWorkoutDocuments =
    await _getWorkoutDocuments(
      userId,
      previousWeekStart,
      previousWeekEnd,
    );

    final previousDietDocuments =
    await _getDietDocuments(
      userId,
      previousWeekStart,
      previousWeekEnd,
    );

    // ==========================================================
    // WORKOUT CALCULATIONS
    // ==========================================================

    int workoutsCompleted = 0;
    int totalDuration = 0;
    int totalCalories = 0;

    final workoutDays =
    List<bool>.filled(7, false);

    final intensityValues =
    <int>[];

    for (final document
    in workoutDocuments) {

      final data = document.data();

      final date =
      _getDate(data['date']);

      if (date == null) {
        continue;
      }

      final dayIndex =
      _getDayIndex(
        date,
        weekStart,
      );

      if (dayIndex < 0 ||
          dayIndex > 6) {
        continue;
      }

      final completed =
      _getBool(
        data['completed'],
        defaultValue: true,
      );

      if (completed) {
        workoutDays[dayIndex] = true;
        workoutsCompleted++;
      }

      totalDuration +=
          _getInt(
            data['duration'],
          );

      totalCalories +=
          _getInt(
            data['caloriesBurned'],
          );

      intensityValues.add(
        _intensityToNumber(
          data['intensity'],
        ),
      );
    }

    final workoutPercentage =
    ((workoutsCompleted / 7) * 100)
        .round();

    final averageIntensity =
    _calculateIntensity(
      intensityValues,
    );

    // ==========================================================
    // DIET CALCULATIONS
    // ==========================================================

    int dietFollowedDays = 0;
    int totalDietCalories = 0;
    int totalHealthyChoices = 0;
    int dietCount = 0;

    final dietDays =
    List<bool>.filled(7, false);

    for (final document
    in dietDocuments) {

      final data = document.data();

      final date =
      _getDate(data['date']);

      if (date == null) {
        continue;
      }

      final dayIndex =
      _getDayIndex(
        date,
        weekStart,
      );

      if (dayIndex < 0 ||
          dayIndex > 6) {
        continue;
      }

      final followed =
      _getBool(
        data['followedPlan'],
        defaultValue: false,
      );

      if (followed) {
        dietDays[dayIndex] = true;
        dietFollowedDays++;
      }

      totalDietCalories +=
          _getInt(
            data['calories'],
          );

      totalHealthyChoices +=
          _getInt(
            data['healthyChoices'],
          );

      dietCount++;
    }

    final dietPercentage =
    ((dietFollowedDays / 7) * 100)
        .round();

    final averageCalories =
    dietCount > 0
        ? (totalDietCalories /
        dietCount)
        .round()
        : 0;

    final healthyChoices =
    dietCount > 0
        ? (totalHealthyChoices /
        dietCount)
        .round()
        : 0;

    // ==========================================================
    // CURRENT SCORE
    // ==========================================================

    final currentScore =
        (
            workoutPercentage +
                dietPercentage +
                healthyChoices
        ) ~/
            3;

    // ==========================================================
    // PREVIOUS WEEK SCORE
    // ==========================================================

    final previousScore =
    _calculatePreviousScore(
      previousWorkoutDocuments,
      previousDietDocuments,
    );

    final improvement =
        currentScore - previousScore;

    // ==========================================================
    // WEEKLY TIP
    // ==========================================================

    final tip =
    _generateTip(
      workoutPercentage:
      workoutPercentage,
      dietPercentage:
      dietPercentage,
      totalDuration:
      totalDuration,
      healthyChoices:
      healthyChoices,
    );

    return WeeklyReportData(
      weekStart: weekStart,
      weekEnd: weekEnd,

      dietFollowedDays:
      dietFollowedDays,

      dietPercentage:
      dietPercentage,

      healthyChoices:
      healthyChoices,

      averageCalories:
      averageCalories,

      workoutsCompleted:
      workoutsCompleted,

      workoutPercentage:
      workoutPercentage,

      totalDuration:
      totalDuration,

      totalCalories:
      totalCalories,

      averageIntensity:
      averageIntensity,

      currentScore:
      currentScore,

      previousScore:
      previousScore,

      improvement:
      improvement,

      workoutDays:
      workoutDays,

      dietDays:
      dietDays,

      tip:
      tip,
    );
  }

  // ============================================================
  // GET WORKOUT DATA
  // ============================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _getWorkoutDocuments(
      String userId,
      DateTime start,
      DateTime end,
      ) async {

    final snapshot =
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .get();

    return snapshot.docs.where((doc) {

      final date =
      _getDate(
        doc.data()['date'],
      );

      if (date == null) {
        return false;
      }

      final cleanDate =
      DateTime(
        date.year,
        date.month,
        date.day,
      );

      return !cleanDate.isBefore(
        DateTime(
          start.year,
          start.month,
          start.day,
        ),
      ) &&
          !cleanDate.isAfter(
            DateTime(
              end.year,
              end.month,
              end.day,
            ),
          );

    }).toList();
  }

  // ============================================================
  // GET DIET DATA
  // ============================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _getDietDocuments(
      String userId,
      DateTime start,
      DateTime end,
      ) async {

    final snapshot =
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('diets')
        .get();

    return snapshot.docs.where((doc) {

      final date =
      _getDate(
        doc.data()['date'],
      );

      if (date == null) {
        return false;
      }

      final cleanDate =
      DateTime(
        date.year,
        date.month,
        date.day,
      );

      return !cleanDate.isBefore(
        DateTime(
          start.year,
          start.month,
          start.day,
        ),
      ) &&
          !cleanDate.isAfter(
            DateTime(
              end.year,
              end.month,
              end.day,
            ),
          );

    }).toList();
  }

  // ============================================================
  // PREVIOUS SCORE
  // ============================================================

  int _calculatePreviousScore(
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
      workouts,
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
      diets,
      ) {

    int completed =
    0;

    for (final doc in workouts) {

      final completedValue =
      _getBool(
        doc.data()['completed'],
        defaultValue: true,
      );

      if (completedValue) {
        completed++;
      }
    }

    final workoutPercentage =
    ((completed / 7) * 100)
        .round();

    int followed =
    0;

    int calories =
    0;

    int healthy =
    0;

    for (final doc in diets) {

      final data =
      doc.data();

      if (_getBool(
        data['followedPlan'],
        defaultValue: false,
      )) {
        followed++;
      }

      calories +=
          _getInt(
            data['calories'],
          );

      healthy +=
          _getInt(
            data['healthyChoices'],
          );
    }

    final dietPercentage =
    ((followed / 7) * 100)
        .round();

    final healthyPercentage =
    diets.isNotEmpty
        ? (healthy / diets.length)
        .round()
        : 0;

    return (
        workoutPercentage +
            dietPercentage +
            healthyPercentage
    ) ~/
        3;
  }

  // ============================================================
  // INTENSITY
  // ============================================================

  int _intensityToNumber(
      dynamic value,
      ) {

    final text =
    value
        ?.toString()
        .toLowerCase()
        .trim();

    if (text == 'high') {
      return 3;
    }

    if (text == 'moderate') {
      return 2;
    }

    return 1;
  }

  String _calculateIntensity(
      List<int> values,
      ) {

    if (values.isEmpty) {
      return 'Moderate';
    }

    final average =
        values.reduce(
              (a, b) => a + b,
        ) /
            values.length;

    if (average >= 2.5) {
      return 'High';
    }

    if (average >= 1.5) {
      return 'Moderate';
    }

    return 'Low';
  }

  // ============================================================
  // TIP
  // ============================================================

  String _generateTip({
    required int workoutPercentage,
    required int dietPercentage,
    required int totalDuration,
    required int healthyChoices,
  }) {

    if (workoutPercentage < 50) {
      return
        'Try to complete more workouts next week.';
    }

    if (dietPercentage < 50) {
      return
        'Try to follow your diet plan more consistently.';
    }

    if (totalDuration < 180) {
      return
        'Try to increase your workout time on the weekend.';
    }

    if (healthyChoices < 70) {
      return
        'Try to make healthier food choices this week.';
    }

    return
      "Great job! You're consistent this week.\n"
          "Try to increase your workout time on weekend.";
  }

  // ============================================================
  // DATE
  // ============================================================

  DateTime? _getDate(
      dynamic value,
      ) {

    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {

      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // ============================================================
  // INTEGER
  // ============================================================

  int _getInt(
      dynamic value,
      ) {

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

    return int.tryParse(
      value.toString(),
    ) ??
        0;
  }

  // ============================================================
  // BOOLEAN
  // ============================================================

  bool _getBool(
      dynamic value, {
        required bool defaultValue,
      }) {

    if (value == null) {
      return defaultValue;
    }

    if (value is bool) {
      return value;
    }

    if (value is String) {

      return value.toLowerCase() ==
          'true';
    }

    return defaultValue;
  }

  // ============================================================
  // DAY INDEX
  // Monday = 0
  // Sunday = 6
  // ============================================================

  int _getDayIndex(
      DateTime date,
      DateTime weekStart,
      ) {

    final cleanDate =
    DateTime(
      date.year,
      date.month,
      date.day,
    );

    final cleanStart =
    DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    return cleanDate
        .difference(cleanStart)
        .inDays;
  }
}
