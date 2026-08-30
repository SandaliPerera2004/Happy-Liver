import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutProgressService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==============================================================
  // GET CURRENT USER ID
  // ==============================================================

  String? get _userId {
    return _auth.currentUser?.uid;
  }

  // ==============================================================
  // GET DATE AS YYYY-MM-DD
  // ==============================================================

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ==============================================================
  // GET TODAY'S DATE
  // ==============================================================

  String _getTodayDate() {
    return _formatDate(DateTime.now());
  }

  // ==============================================================
  // GET START OF CURRENT WEEK
  // ==============================================================
  //
  // Monday = first day of the workout week.
  //
  // Monday -> 0
  // Tuesday -> 1
  // Wednesday -> 2
  // Thursday -> 3
  // Friday -> 4
  // Saturday -> 5
  // Sunday -> 6
  //
  // Your workout plan has 6 days:
  // Monday - Saturday
  //
  // ==============================================================

  DateTime _getStartOfWeek() {
    final now = DateTime.now();

    final monday = now.subtract(
      Duration(days: now.weekday - DateTime.monday),
    );

    return DateTime(
      monday.year,
      monday.month,
      monday.day,
    );
  }

  // ==============================================================
  // SAVE PARTIAL WORKOUT PROGRESS
  // ==============================================================

  Future<void> saveWorkoutProgress({
    required String workoutId,
    required int totalDurationSeconds,
    required int completedDurationSeconds,
  }) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    final today = _getTodayDate();

    // Prevent invalid values
    final safeCompletedSeconds =
    completedDurationSeconds.clamp(
      0,
      totalDurationSeconds,
    );

    // Calculate progress between 0.0 and 1.0
    final double progress =
    totalDurationSeconds > 0
        ? safeCompletedSeconds /
        totalDurationSeconds
        : 0.0;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutProgress')
        .doc(today)
        .collection('workouts')
        .doc(workoutId)
        .set({
      'workoutId': workoutId,

      // Example:
      // 0.35 = 35%
      'progress': progress,

      'completed': progress >= 1.0,

      'totalDurationSeconds':
      totalDurationSeconds,

      'completedDurationSeconds':
      safeCompletedSeconds,

      'updatedAt':
      FieldValue.serverTimestamp(),

      // Only added when the document doesn't already
      // contain startedAt.
      'startedAt':
      FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ==============================================================
  // MARK WORKOUT AS COMPLETED
  // ==============================================================
  //
  // This should ONLY be called when the timer reaches 00:00.
  //
  // ==============================================================

  Future<void> markWorkoutCompleted({
    required String workoutId,
    required int totalDurationSeconds,
  }) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    final today = _getTodayDate();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutProgress')
        .doc(today)
        .collection('workouts')
        .doc(workoutId)
        .set({
      'workoutId': workoutId,

      // FULL completion
      'progress': 1.0,

      'completed': true,

      'totalDurationSeconds':
      totalDurationSeconds,

      'completedDurationSeconds':
      totalDurationSeconds,

      'completedAt':
      FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ==============================================================
  // CHECK WHETHER A WORKOUT IS COMPLETED TODAY
  // ==============================================================

  Future<bool> isWorkoutCompletedToday(
      String workoutId,
      ) async {
    final userId = _userId;

    if (userId == null) {
      return false;
    }

    final today = _getTodayDate();

    final document = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutProgress')
        .doc(today)
        .collection('workouts')
        .doc(workoutId)
        .get();

    if (!document.exists) {
      return false;
    }

    final data = document.data();

    return data?['completed'] == true;
  }

  // ==============================================================
  // GET WORKOUT PROGRESS TODAY
  // ==============================================================

  Future<double> getWorkoutProgressToday(
      String workoutId,
      ) async {
    final userId = _userId;

    if (userId == null) {
      return 0.0;
    }

    final today = _getTodayDate();

    final document = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutProgress')
        .doc(today)
        .collection('workouts')
        .doc(workoutId)
        .get();

    if (!document.exists) {
      return 0.0;
    }

    final data = document.data();

    final progress = data?['progress'];

    if (progress is num) {
      return progress
          .toDouble()
          .clamp(0.0, 1.0);
    }

    return 0.0;
  }

  // ==============================================================
  // GET TODAY'S COMPLETED WORKOUT IDS
  // ==============================================================

  Future<Set<String>> getTodayCompletedWorkoutIds() async {
    final userId = _userId;

    if (userId == null) {
      return {};
    }

    final today = _getTodayDate();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutProgress')
        .doc(today)
        .collection('workouts')
        .where(
      'completed',
      isEqualTo: true,
    )
        .get();

    return snapshot.docs
        .map((doc) => doc.id)
        .toSet();
  }

  // ==============================================================
  // GET ALL TODAY'S WORKOUT PROGRESS
  // ==============================================================

  Future<Map<String, double>>
  getTodayWorkoutProgress() async {
    final userId = _userId;

    if (userId == null) {
      return {};
    }

    final today = _getTodayDate();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutProgress')
        .doc(today)
        .collection('workouts')
        .get();

    final Map<String, double> progressMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final progress = data['progress'];

      if (progress is num) {
        progressMap[doc.id] =
            progress.toDouble().clamp(0.0, 1.0);
      }
    }

    return progressMap;
  }

  // ==============================================================
  // GET WEEKLY COMPLETED WORKOUT DAYS
  // ==============================================================
  //
  // Your workout plan has 6 workout days:
  //
  // Monday
  // Tuesday
  // Wednesday
  // Thursday
  // Friday
  // Saturday
  //
  // Sunday is NOT included.
  //
  // Returns the number of days completed.
  //
  // Example:
  //
  // Monday     = completed
  // Tuesday    = completed
  // Wednesday  = not completed
  // Thursday   = completed
  // Friday     = not completed
  // Saturday   = not completed
  //
  // Result:
  //
  // 3 / 6
  //
  // ==============================================================

  Future<int> getWeeklyCompletedDays() async {
    final userId = _userId;

    if (userId == null) {
      return 0;
    }

    final monday = _getStartOfWeek();

    int completedDays = 0;

    // Monday -> Saturday
    for (int i = 0; i < 6; i++) {
      final date = monday.add(
        Duration(days: i),
      );

      final dateString = _formatDate(date);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutProgress')
          .doc(dateString)
          .collection('workouts')
          .where(
        'completed',
        isEqualTo: true,
      )
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        completedDays++;
      }
    }

    return completedDays;
  }

  // ==============================================================
  // GET WEEKLY PROGRESS
  // ==============================================================
  //
  // Returns a value between 0.0 and 1.0.
  //
  // Example:
  //
  // 3 completed days / 6 days
  //
  // = 0.5
  //
  // = 50%
  //
  // ==============================================================

  Future<double> getWeeklyProgress() async {
    const int totalWorkoutDays = 6;

    final completedDays =
    await getWeeklyCompletedDays();

    return (completedDays / totalWorkoutDays)
        .clamp(0.0, 1.0);
  }

  // ==============================================================
  // GET TODAY'S OVERALL COMPLETION
  // ==============================================================

  Future<double> getTodayOverallProgress({
    required List<String> workoutIds,
  }) async {
    if (workoutIds.isEmpty) {
      return 0.0;
    }

    final progressMap =
    await getTodayWorkoutProgress();

    double totalProgress = 0.0;

    for (final workoutId in workoutIds) {
      totalProgress +=
          progressMap[workoutId] ?? 0.0;
    }

    return totalProgress /
        workoutIds.length;
  }
}