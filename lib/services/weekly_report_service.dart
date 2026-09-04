import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// ============================================================
// WEEKLY REPORT SERVICE
// ============================================================

class WeeklyReportService {
  final String baseUrl;
  final http.Client client;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WeeklyReportService({
    String? baseUrl,
    http.Client? client,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : baseUrl = baseUrl ?? '',
        client = client ?? http.Client(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ============================================================
  // GET WEEKLY REPORT
  // ============================================================

  Future<WeeklyReport> getWeeklyReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No logged-in user found. Please login again.',
      );
    }

    final cleanStart = _dateOnly(startDate);
    final cleanEnd = _dateOnly(endDate);

    try {
      final userWeight = await _loadUserWeight(user.uid);

      final workoutDefinitions =
      await _loadWorkoutDefinitions();

      final currentDays = await _loadWeek(
        user.uid,
        cleanStart,
        cleanEnd,
        userWeight,
        workoutDefinitions,
      );

      final previousStart = cleanStart.subtract(
        const Duration(days: 7),
      );

      final previousEnd = cleanStart.subtract(
        const Duration(days: 1),
      );

      final previousDays = await _loadWeek(
        user.uid,
        previousStart,
        previousEnd,
        userWeight,
        workoutDefinitions,
      );

      final progress = _calculateWeeklyProgress(
        currentDays,
        previousDays,
      );

      final dietChats = await _loadChats(
        user.uid,
        'diet_chat',
        cleanStart,
        cleanEnd,
      );

      final workoutChats = await _loadChats(
        user.uid,
        'workout_chat',
        cleanStart,
        cleanEnd,
      );

      final calendar = _buildCalendar(currentDays);

      return WeeklyReport(
        startDate: cleanStart,
        endDate: cleanEnd,
        days: currentDays,
        dietChats: dietChats,
        workoutChats: workoutChats,
        calendar: calendar,
        progressComparedToLastWeek: progress,
      );
    } catch (e) {
      throw Exception(
        'Unable to load weekly report: $e',
      );
    }
  }

  // ============================================================
  // LOAD USER WEIGHT
  // ============================================================

  Future<double?> _loadUserWeight(
      String userId,
      ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      final weight = _toDouble(data['weight']);

      if (weight <= 0) {
        return null;
      }

      return weight;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // LOAD WORKOUT DEFINITIONS
  // ============================================================

  Future<Map<String, Map<String, dynamic>>>
  _loadWorkoutDefinitions() async {
    final definitions = <String, Map<String, dynamic>>{};

    const levels = [
      'low',
      'moderate',
      'high',
    ];

    for (final level in levels) {
      try {
        final snapshot = await _firestore
            .collection('workoutPlans')
            .doc(level)
            .collection('exercises')
            .get();

        for (final document in snapshot.docs) {
          definitions['$level:${document.id}'] =
              document.data();
        }
      } catch (_) {
        // Continue if one level cannot be loaded.
      }
    }

    return definitions;
  }

  // ============================================================
  // FIND WORKOUT DEFINITION
  // ============================================================

  Map<String, dynamic>? _findWorkoutDefinition(
      String workoutId,
      Map<String, Map<String, dynamic>> definitions,
      ) {
    const levels = [
      'low',
      'moderate',
      'high',
    ];

    for (final level in levels) {
      final definition =
      definitions['$level:$workoutId'];

      if (definition != null) {
        return definition;
      }
    }

    return null;
  }

  // ============================================================
  // LOAD 7 DAYS
  // ============================================================

  Future<List<DailyReport>> _loadWeek(
      String userId,
      DateTime startDate,
      DateTime endDate,
      double? userWeight,
      Map<String, Map<String, dynamic>>
      workoutDefinitions,
      ) async {
    final days = <DailyReport>[];

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(
        Duration(days: i),
      );

      if (date.isAfter(endDate)) {
        break;
      }

      final day = await _loadDailyReport(
        userId,
        date,
        userWeight,
        workoutDefinitions,
      );

      days.add(day);
    }

    while (days.length < 7) {
      final date = startDate.add(
        Duration(days: days.length),
      );

      days.add(
        DailyReport.empty(date),
      );
    }

    return days;
  }

  // ============================================================
  // LOAD ONE DAY
  // ============================================================

  Future<DailyReport> _loadDailyReport(
      String userId,
      DateTime date,
      double? userWeight,
      Map<String, Map<String, dynamic>>
      workoutDefinitions,
      ) async {
    final dateKey = _formatDate(date);

    final dietData = await _loadDietDay(
      userId,
      dateKey,
    );

    final workoutData = await _loadWorkoutDay(
      userId,
      dateKey,
      userWeight,
      workoutDefinitions,
    );

    return DailyReport(
      date: date,

      workoutCompleted:
      workoutData['completed'] as bool? ?? false,

      workoutDuration:
      (workoutData['durationMinutes'] as num?)
          ?.toDouble() ??
          0,

      workoutCalories:
      (workoutData['calories'] as num?)
          ?.toDouble() ??
          0,

      workoutIntensity:
      workoutData['intensity']?.toString() ??
          'Moderate',

      workoutCount:
      (workoutData['workoutCount'] as int?) ??
          0,

      healthyChoices:
      (dietData['healthyChoicesPercent'] as num?)
          ?.toDouble() ??
          0,

      dietFollowed:
      dietData['completed'] as bool? ?? false,

      calories:
      (dietData['calories'] as num?)
          ?.toDouble() ??
          0,

      dietPlanExists:
      dietData['exists'] as bool? ?? false,

      workoutPlanExists:
      workoutData['exists'] as bool? ?? false,

      dietChatCount: 0,
      workoutChatCount: 0,

      dietMealsCompleted:
      (dietData['mealsCompleted'] as int?) ??
          0,

      dietMealsTarget:
      (dietData['mealsTarget'] as int?) ??
          0,
    );
  }

  // ============================================================
  // DIET FIRESTORE
  // ============================================================

  Future<Map<String, dynamic>> _loadDietDay(
      String userId,
      String dateKey,
      ) async {
    final ref = _firestore
        .collection('dietplans')
        .doc(userId)
        .collection('dailyProgress')
        .doc(dateKey);

    final snapshot = await ref.get();

    if (!snapshot.exists) {
      return {
        'exists': false,
        'completed': false,
        'healthyChoicesPercent': 0.0,
        'calories': 0.0,
        'mealsCompleted': 0,
        'mealsTarget': 0,
      };
    }

    return _parseDietData(
      snapshot.data() ?? {},
    );
  }

  // ============================================================
  // PARSE DIET DATA
  // ============================================================

  Map<String, dynamic> _parseDietData(
      Map<String, dynamic> data,
      ) {
    final mealsCompleted = _toInt(
      data['mealsCompleted'] ??
          data['meals_completed'],
    );

    final mealsTarget = _toInt(
      data['mealsTarget'] ??
          data['meals_target'],
    );

    final healthyChoicesRaw = _toDouble(
      data['healthyChoices'] ??
          data['healthy_choices'],
    );

    double healthyPercentage = 0;

    if (healthyChoicesRaw > 100) {
      healthyPercentage = 100;
    } else if (healthyChoicesRaw > 0) {
      if (mealsTarget > 0 &&
          healthyChoicesRaw <= mealsTarget) {
        healthyPercentage =
            (healthyChoicesRaw / mealsTarget) * 100;
      } else {
        healthyPercentage =
            healthyChoicesRaw;
      }
    }

    return {
      'exists': true,

      'completed': _toBool(
        data['completed'] ??
            data['dailyGoalCompleted'] ??
            data['daily_goal_completed'],
      ),

      'healthyChoicesPercent':
      healthyPercentage.clamp(0, 100),

      // REAL DAILY CALORIES
      'calories': _toDouble(
        data['calories'] ??
            data['dailyCalories'] ??
            data['totalCalories'],
      ),

      'mealsCompleted': mealsCompleted,
      'mealsTarget': mealsTarget,
    };
  }

  // ============================================================
  // WORKOUT FIRESTORE
  // ============================================================

  Future<Map<String, dynamic>> _loadWorkoutDay(
      String userId,
      String dateKey,
      double? userWeight,
      Map<String, Map<String, dynamic>>
      workoutDefinitions,
      ) async {
    final workoutsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutProgress')
        .doc(dateKey)
        .collection('workouts');

    final snapshot = await workoutsRef.get();

    if (snapshot.docs.isEmpty) {
      return {
        'exists': workoutDefinitions.isNotEmpty,
        'completed': false,
        'durationMinutes': 0.0,
        'calories': 0.0,
        'intensity': 'Moderate',
        'workoutCount': 0,
      };
    }

    bool completed = false;

    double totalDurationSeconds = 0;

    double totalCalories = 0;

    final intensities = <String>[];

    int completedWorkoutCount = 0;

    for (final document in snapshot.docs) {
      final data = document.data();

      final workoutId =
          data['workoutId']?.toString() ??
              document.id;

      final isCompleted = _toBool(
        data['completed'],
      );

      if (isCompleted) {
        completed = true;
        completedWorkoutCount++;
      }

      final durationSeconds = _toDouble(
        data['completedDurationSeconds'],
      );

      totalDurationSeconds +=
          durationSeconds;

      final workoutDefinition =
      _findWorkoutDefinition(
        workoutId,
        workoutDefinitions,
      );

      final workoutName =
          workoutDefinition?['name']
              ?.toString() ??
              data['workoutName']?.toString() ??
              data['name']?.toString() ??
              'Workout';

      final storedCalories = _toDouble(
        data['calories'] ??
            data['caloriesBurned'] ??
            data['calories_burned'],
      );

      double workoutCalories = 0;

      if (storedCalories > 0) {
        workoutCalories = storedCalories;
      } else if (userWeight != null &&
          userWeight > 0 &&
          durationSeconds > 0) {
        workoutCalories =
            _calculateExerciseCalories(
              workoutName: workoutName,
              weightKg: userWeight,
              durationSeconds:
              durationSeconds,
              workoutDefinition:
              workoutDefinition,
            );
      }

      totalCalories += workoutCalories;

      final storedIntensity =
          data['intensity'] ??
              data['workoutIntensity'] ??
              data['workout_intensity'];

      if (storedIntensity != null &&
          storedIntensity
              .toString()
              .trim()
              .isNotEmpty) {
        intensities.add(
          storedIntensity.toString(),
        );
      } else {
        final estimatedIntensity =
        _calculateWorkoutIntensity(
          workoutName,
          workoutDefinition,
        );

        intensities.add(
          estimatedIntensity,
        );
      }
    }

    return {
      'exists': true,
      'completed': completed,
      'durationMinutes':
      totalDurationSeconds / 60,
      'calories': totalCalories,
      'intensity':
      _calculateIntensity(intensities),
      'workoutCount':
      completedWorkoutCount,
    };
  }

  // ============================================================
  // CALCULATE EXERCISE CALORIES
  // ============================================================

  double _calculateExerciseCalories({
    required String workoutName,
    required double weightKg,
    required double durationSeconds,
    Map<String, dynamic>? workoutDefinition,
  }) {
    if (weightKg <= 0 ||
        durationSeconds <= 0) {
      return 0;
    }

    final durationMinutes =
        durationSeconds / 60;

    final met = _getMet(
      workoutName,
      workoutDefinition,
    );

    final calories =
        met *
            3.5 *
            weightKg /
            200 *
            durationMinutes;

    return calories;
  }

  // ============================================================
  // GET MET VALUE
  // ============================================================

  double _getMet(
      String workoutName,
      Map<String, dynamic>? definition,
      ) {
    final name =
    workoutName.toLowerCase();

    final riskLevel =
        definition?['riskLevel']
            ?.toString()
            .toLowerCase() ??
            definition?['risklevel']
                ?.toString()
                .toLowerCase() ??
            '';

    if (name.contains('stretch')) {
      return 2.3;
    }

    if (name.contains('march')) {
      if (name.contains('high')) {
        return 4.5;
      }

      if (name.contains('middle') ||
          name.contains('moderate') ||
          name.contains('medium')) {
        return 3.5;
      }

      if (name.contains('low')) {
        return 2.8;
      }

      return 3.2;
    }

    if (name.contains('brisk')) {
      return 4.3;
    }

    if (name.contains('walk')) {
      return 3.0;
    }

    if (name.contains('chair squat') ||
        name.contains('squat')) {
      return 4.5;
    }

    if (name.contains('knee raise') ||
        name.contains('knee lift')) {
      return 3.8;
    }

    if (name.contains('wall push') ||
        name.contains('push-up') ||
        name.contains('push up')) {
      return 3.5;
    }

    if (riskLevel.contains('high')) {
      return 4.5;
    }

    if (riskLevel.contains('low')) {
      return 2.8;
    }

    return 3.5;
  }

  // ============================================================
  // CALCULATE WORKOUT INTENSITY
  // ============================================================

  String _calculateWorkoutIntensity(
      String workoutName,
      Map<String, dynamic>? definition,
      ) {
    final name =
    workoutName.toLowerCase();

    if (name.contains('high') ||
        name.contains('brisk')) {
      return 'High';
    }

    if (name.contains('low') ||
        name.contains('gentle') ||
        name.contains('stretch')) {
      return 'Low';
    }

    final met = _getMet(
      workoutName,
      definition,
    );

    if (met >= 4.3) {
      return 'High';
    }

    if (met >= 3.2) {
      return 'Moderate';
    }

    return 'Low';
  }

  // ============================================================
  // CHAT DATA
  // ============================================================

  Future<List<ChatReport>> _loadChats(
      String userId,
      String collectionName,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection(collectionName);

      final snapshot = await ref.get();

      final chats = <ChatReport>[];

      for (final document in snapshot.docs) {
        final data = document.data();

        final timestamp = _timestampToDate(
          data['timestamp'] ??
              data['createdAt'] ??
              data['created_at'],
        );

        if (timestamp == null) {
          continue;
        }

        final cleanDate =
        _dateOnly(timestamp);

        if (cleanDate.isBefore(startDate) ||
            cleanDate.isAfter(endDate)) {
          continue;
        }

        chats.add(
          ChatReport(
            id: document.id,
            message:
            data['message']?.toString() ??
                data['text']?.toString() ??
                data['content']?.toString() ??
                '',
            sender:
            data['sender']?.toString() ??
                data['role']?.toString() ??
                'user',
            timestamp: timestamp,
          ),
        );
      }

      return chats;
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // CALENDAR
  // ============================================================

  List<CalendarReport> _buildCalendar(
      List<DailyReport> days,
      ) {
    final result = <CalendarReport>[];

    for (final day in days) {
      if (day.workoutPlanExists) {
        result.add(
          CalendarReport(
            date: day.date,
            completed:
            day.workoutCompleted,
            type: 'workout',
            title: 'Workout',
          ),
        );
      }

      if (day.dietPlanExists) {
        result.add(
          CalendarReport(
            date: day.date,
            completed:
            day.dietFollowed,
            type: 'diet',
            title: 'Diet',
          ),
        );
      }
    }

    return result;
  }

  // ============================================================
  // WEEKLY PROGRESS
  // ============================================================

  int _calculateWeeklyProgress(
      List<DailyReport> current,
      List<DailyReport> previous,
      ) {
    if (current.isEmpty ||
        previous.isEmpty) {
      return 0;
    }

    final currentDiet = _percentage(
      current
          .where(
            (e) => e.dietPlanExists,
      )
          .where(
            (e) => e.dietFollowed,
      )
          .length,
      current
          .where(
            (e) => e.dietPlanExists,
      )
          .length,
    );

    final currentWorkout = _percentage(
      current
          .where(
            (e) => e.workoutPlanExists,
      )
          .where(
            (e) => e.workoutCompleted,
      )
          .length,
      current
          .where(
            (e) => e.workoutPlanExists,
      )
          .length,
    );

    final previousDiet = _percentage(
      previous
          .where(
            (e) => e.dietPlanExists,
      )
          .where(
            (e) => e.dietFollowed,
      )
          .length,
      previous
          .where(
            (e) => e.dietPlanExists,
      )
          .length,
    );

    final previousWorkout = _percentage(
      previous
          .where(
            (e) => e.workoutPlanExists,
      )
          .where(
            (e) => e.workoutCompleted,
      )
          .length,
      previous
          .where(
            (e) => e.workoutPlanExists,
      )
          .length,
    );

    final currentScore =
        (currentDiet + currentWorkout) / 2;

    final previousScore =
        (previousDiet + previousWorkout) / 2;

    if (previousScore == 0) {
      if (currentScore > 0) {
        return currentScore.round();
      }

      return 0;
    }

    final difference =
        currentScore - previousScore;

    return difference.round();
  }

  int _percentage(
      int completed,
      int total,
      ) {
    if (total <= 0) {
      return 0;
    }

    return ((completed / total) * 100)
        .round()
        .clamp(0, 100);
  }

  // ============================================================
  // INTENSITY
  // ============================================================

  String _calculateIntensity(
      List<String> values,
      ) {
    if (values.isEmpty) {
      return 'Moderate';
    }

    double total = 0;

    for (final value in values) {
      final text =
      value.toLowerCase();

      if (text.contains('high')) {
        total += 3;
      } else if (text.contains('low')) {
        total += 1;
      } else {
        total += 2;
      }
    }

    final average =
        total / values.length;

    if (average >= 2.5) {
      return 'High';
    }

    if (average >= 1.5) {
      return 'Moderate';
    }

    return 'Low';
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  String _formatDate(DateTime date) {
    final y =
    date.year.toString().padLeft(4, '0');

    final m =
    date.month.toString().padLeft(2, '0');

    final d =
    date.day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }

  DateTime? _timestampToDate(
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
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ============================================================
  // VALUE HELPERS
  // ============================================================

  bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final text =
      value.toLowerCase().trim();

      return text == 'true' ||
          text == '1' ||
          text == 'yes' ||
          text == 'completed' ||
          text == 'done';
    }

    return false;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.round();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}

// ============================================================
// WEEKLY REPORT
// ============================================================

class WeeklyReport {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyReport> days;

  final List<ChatReport> dietChats;
  final List<ChatReport> workoutChats;

  final List<CalendarReport> calendar;

  final int progressComparedToLastWeek;

  const WeeklyReport({
    required this.startDate,
    required this.endDate,
    required this.days,
    this.dietChats = const [],
    this.workoutChats = const [],
    this.calendar = const [],
    this.progressComparedToLastWeek = 0,
  });

  // ==========================================================
  // DIET
  // ==========================================================

  int get dietFollowedDays {
    return days
        .where(
          (day) => day.dietFollowed,
    )
        .length;
  }

  int get dietPercentage {
    final plannedDays = days
        .where(
          (day) => day.dietPlanExists,
    )
        .length;

    if (plannedDays == 0) {
      return 0;
    }

    return ((dietFollowedDays /
        plannedDays) *
        100)
        .round()
        .clamp(0, 100);
  }

  double get healthyChoices {
    final values = days
        .where(
          (day) => day.dietPlanExists,
    )
        .map(
          (day) => day.healthyChoices,
    )
        .where(
          (value) => value > 0,
    )
        .toList();

    if (values.isEmpty) {
      return 0;
    }

    return values.reduce(
          (a, b) => a + b,
    ) /
        values.length;
  }

  // ==========================================================
  // WORKOUT
  // ==========================================================

  int get workoutCompletedDays {
    return days
        .where(
          (day) => day.workoutCompleted,
    )
        .length;
  }

  int get workoutPercentage {
    final plannedDays = days
        .where(
          (day) => day.workoutPlanExists,
    )
        .length;

    if (plannedDays == 0) {
      return 0;
    }

    return ((workoutCompletedDays /
        plannedDays) *
        100)
        .round()
        .clamp(0, 100);
  }

  int get totalWorkout {
    return days.fold(
      0,
          (sum, day) =>
      sum + day.workoutCount,
    );
  }

  int get totalDuration {
    return days.fold(
      0,
          (sum, day) =>
      sum + day.workoutDuration.round(),
    );
  }

  int get totalCalories {
    return days.fold(
      0,
          (sum, day) =>
      sum + day.workoutCalories.round(),
    );
  }

  // ==========================================================
  // CALORIES
  // ==========================================================

  int get averageCalories {
    final values = days
        .map(
          (day) => day.calories,
    )
        .where(
          (value) => value > 0,
    )
        .toList();

    if (values.isEmpty) {
      return 0;
    }

    return (values.reduce(
          (a, b) => a + b,
    ) /
        values.length)
        .round();
  }

  // ==========================================================
  // NEW:
  // DAILY CALORIES FOR DIET CHART
  // ==========================================================

  List<double> get dailyCalories {
    return days
        .map(
          (day) => day.calories,
    )
        .toList();
  }

  // ==========================================================
  // INTENSITY
  // ==========================================================

  double get averageIntensity {
    final completed = days
        .where(
          (day) => day.workoutCompleted,
    )
        .toList();

    if (completed.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final day in completed) {
      final intensity =
      day.workoutIntensity.toLowerCase();

      if (intensity.contains('high')) {
        total += 3;
      } else if (intensity.contains('low')) {
        total += 1;
      } else {
        total += 2;
      }
    }

    return total / completed.length;
  }

  String get intensityText {
    if (averageIntensity >= 2.5) {
      return 'High';
    }

    if (averageIntensity >= 1.5) {
      return 'Moderate';
    }

    return 'Low';
  }

  // ==========================================================
  // TIP OF THE WEEK
  // ==========================================================

  String get tipOfWeek {
    final dietRate = dietPercentage;
    final workoutRate = workoutPercentage;
    final intensity = averageIntensity;

    if (dietRate >= 80 &&
        workoutRate >= 80) {
      return 'Excellent work! Stay consistent with your diet and workouts to maintain your progress.';
    }

    if (dietRate >= 80 &&
        workoutRate < 80) {
      return 'Your diet progress is great. Try to complete your workouts more consistently this week.';
    }

    if (workoutRate >= 80 &&
        dietRate < 80) {
      return 'Your workout progress is great. Focus on following your diet plan more consistently.';
    }

    if (dietRate < 50 &&
        workoutRate < 50) {
      return 'Try to build a consistent routine this week by following your diet plan and completing your workouts.';
    }

    if (intensity >= 2.5) {
      return 'You are doing well with your workouts. Remember to balance exercise with a healthy diet and enough rest.';
    }

    if (workoutCompletedDays == 0 &&
        dietFollowedDays > 0) {
      return 'You are doing well with your diet. Start with gentle workouts and gradually build your routine.';
    }

    if (dietFollowedDays == 0 &&
        workoutCompletedDays > 0) {
      return 'You are staying active. Try to follow your diet plan consistently to support your overall progress.';
    }

    return 'Stay consistent with your diet and workouts. Small improvements each day can make a big difference.';
  }

  // ==========================================================
  // CHAT
  // ==========================================================

  int get dietChatCount {
    return dietChats.length;
  }

  int get workoutChatCount {
    return workoutChats.length;
  }

  // ==========================================================
  // CALENDAR
  // ==========================================================

  int get calendarCompletedDays {
    return calendar
        .where(
          (item) => item.completed,
    )
        .length;
  }

  // ==========================================================
  // JSON
  // ==========================================================

  factory WeeklyReport.fromJson(
      dynamic json, {
        required DateTime startDate,
        required DateTime endDate,
      }) {
    if (json is! Map) {
      return WeeklyReport.empty(
        startDate: startDate,
        endDate: endDate,
      );
    }

    final map =
    Map<String, dynamic>.from(json);

    final rawData = map['data'];

    final data = rawData is Map
        ? Map<String, dynamic>.from(
      rawData,
    )
        : map;

    final rawDays = data['days'];

    final days = <DailyReport>[];

    if (rawDays is List) {
      for (int i = 0;
      i < rawDays.length;
      i++) {
        final item = rawDays[i];

        if (item is Map) {
          days.add(
            DailyReport.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
              fallbackDate:
              startDate.add(
                Duration(days: i),
              ),
            ),
          );
        }
      }
    }

    while (days.length < 7) {
      days.add(
        DailyReport.empty(
          startDate.add(
            Duration(days: days.length),
          ),
        ),
      );
    }

    return WeeklyReport(
      startDate: startDate,
      endDate: endDate,
      days: days.take(7).toList(),
      progressComparedToLastWeek:
      _jsonInt(
        data['progressComparedToLastWeek'] ??
            data['progress'] ??
            0,
      ),
    );
  }

  factory WeeklyReport.empty({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return WeeklyReport(
      startDate: startDate,
      endDate: endDate,
      days: List.generate(
        7,
            (index) => DailyReport.empty(
          startDate.add(
            Duration(days: index),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DAILY REPORT
// ============================================================

class DailyReport {
  final DateTime date;

  final bool workoutCompleted;
  final double workoutDuration;
  final double workoutCalories;
  final String workoutIntensity;

  final double healthyChoices;
  final bool dietFollowed;
  final double calories;

  final bool dietPlanExists;
  final bool workoutPlanExists;

  final int dietChatCount;
  final int workoutChatCount;

  final int workoutCount;

  final int dietMealsCompleted;
  final int dietMealsTarget;

  const DailyReport({
    required this.date,
    required this.workoutCompleted,
    required this.workoutDuration,
    required this.workoutCalories,
    required this.workoutIntensity,
    required this.healthyChoices,
    required this.dietFollowed,
    required this.calories,
    this.dietPlanExists = false,
    this.workoutPlanExists = false,
    this.dietChatCount = 0,
    this.workoutChatCount = 0,
    this.workoutCount = 0,
    this.dietMealsCompleted = 0,
    this.dietMealsTarget = 0,
  });

  factory DailyReport.empty(
      DateTime date,
      ) {
    return DailyReport(
      date: DateTime(
        date.year,
        date.month,
        date.day,
      ),
      workoutCompleted: false,
      workoutDuration: 0,
      workoutCalories: 0,
      workoutIntensity: 'Moderate',
      healthyChoices: 0,
      dietFollowed: false,
      calories: 0,
    );
  }

  factory DailyReport.fromJson(
      Map<String, dynamic> json, {
        required DateTime fallbackDate,
      }) {
    final workout =
    _jsonMap(json['workout']);

    final diet =
    _jsonMap(json['diet']);

    return DailyReport(
      date: _jsonDate(
        json['date'] ??
            json['day'] ??
            json['activityDate'],
        fallbackDate,
      ),

      workoutCompleted:
      _jsonBool(
        json['workoutCompleted'] ??
            json['workout_completed'] ??
            workout['completed'],
      ),

      workoutDuration:
      _jsonDouble(
        json['workoutDuration'] ??
            json['workout_duration'] ??
            workout['duration'] ??
            workout['durationMinutes'],
      ),

      workoutCalories:
      _jsonDouble(
        json['workoutCalories'] ??
            json['workout_calories'] ??
            workout['calories'],
      ),

      workoutIntensity:
      _jsonString(
        json['workoutIntensity'] ??
            json['workout_intensity'] ??
            workout['intensity'],
        'Moderate',
      ),

      healthyChoices:
      _jsonDouble(
        json['healthyChoices'] ??
            json['healthy_choices'] ??
            diet['healthyChoices'] ??
            diet['healthy_choices'],
      ),

      dietFollowed:
      _jsonBool(
        json['dietFollowed'] ??
            json['diet_followed'] ??
            diet['followed'] ??
            diet['completed'],
      ),

      calories:
      _jsonDouble(
        json['calories'] ??
            json['dailyCalories'] ??
            diet['calories'] ??
            diet['totalCalories'],
      ),

      dietPlanExists:
      json['dietPlanExists'] != null
          ? _jsonBool(
        json['dietPlanExists'],
      )
          : diet.isNotEmpty,

      workoutPlanExists:
      json['workoutPlanExists'] != null
          ? _jsonBool(
        json['workoutPlanExists'],
      )
          : workout.isNotEmpty,

      workoutCount:
      _jsonInt(
        json['workoutCount'],
      ),
    );
  }
}

// ============================================================
// CHAT REPORT
// ============================================================

class ChatReport {
  final String id;
  final String message;
  final String sender;
  final DateTime? timestamp;

  const ChatReport({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
  });
}

// ============================================================
// CALENDAR REPORT
// ============================================================

class CalendarReport {
  final DateTime date;
  final bool completed;
  final String type;
  final String title;

  const CalendarReport({
    required this.date,
    required this.completed,
    required this.type,
    required this.title,
  });
}

// ============================================================
// JSON HELPERS
// ============================================================

Map<String, dynamic> _jsonMap(
    dynamic value,
    ) {
  if (value is Map) {
    return Map<String, dynamic>.from(
      value,
    );
  }

  return {};
}

String _jsonString(
    dynamic value,
    String fallback,
    ) {
  if (value == null) {
    return fallback;
  }

  return value.toString();
}

bool _jsonBool(
    dynamic value,
    ) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final text =
    value.toLowerCase().trim();

    return text == 'true' ||
        text == '1' ||
        text == 'yes' ||
        text == 'completed' ||
        text == 'done';
  }

  return false;
}

double _jsonDouble(
    dynamic value,
    ) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}

int _jsonInt(
    dynamic value,
    ) {
  if (value is num) {
    return value.round();
  }

  if (value is String) {
    return int.tryParse(value) ?? 0;
  }

  return 0;
}

DateTime _jsonDate(
    dynamic value,
    DateTime fallback,
    ) {
  if (value is DateTime) {
    return value;
  }

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is String) {
    final parsed =
    DateTime.tryParse(value);

    if (parsed != null) {
      return DateTime(
        parsed.year,
        parsed.month,
        parsed.day,
      );
    }
  }

  return DateTime(
    fallback.year,
    fallback.month,
    fallback.day,
  );
}