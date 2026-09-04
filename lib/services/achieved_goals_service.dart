import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievedGoalsData {
  final int waterGlasses;
  final int waterTargetGlasses;
  final int waterPercentage;

  final int workoutCompletedDays;
  final int workoutPercentage;

  final int dietCompletedDays;
  final int dietPercentage;

  AchievedGoalsData({
    required this.waterGlasses,
    required this.waterTargetGlasses,
    required this.waterPercentage,
    required this.workoutCompletedDays,
    required this.workoutPercentage,
    required this.dietCompletedDays,
    required this.dietPercentage,
  });
}

class AchievedGoalsService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  Future<AchievedGoalsData> getWeeklyGoals() async {
    // =========================================================
    // CHECK LOGGED-IN USER
    // =========================================================

    final user = auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final uid = user.uid;

    print('========================================');
    print('Achieved Goals - Firestore Test');
    print('USER UID: $uid');
    print('========================================');

    // =========================================================
    // FIRESTORE CONNECTION TEST
    // =========================================================

    try {
      final testDocument = await firestore
          .collection('users')
          .doc(uid)
          .get();

      print(
        'FIRESTORE CONNECTED: ${testDocument.exists}',
      );
    } catch (e) {
      print('FIRESTORE ERROR: $e');
      rethrow;
    }

    // =========================================================
    // CURRENT DATE
    // =========================================================

    final today = DateTime.now();

    // Find Monday of current week
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(
      Duration(days: today.weekday - 1),
    );

    print('TODAY: $today');
    print('WEEK START: $monday');

    // =========================================================
    // VARIABLES
    // =========================================================

    int dietDays = 0;
    int workoutDays = 0;

    double water = 0;
    double waterTarget = 0;

    // =========================================================
    // GET 7 DAYS DATA
    // =========================================================

    for (int i = 0; i < 7; i++) {
      final date = monday.add(
        Duration(days: i),
      );

      // YYYY-MM-DD
      final dateKey =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      print('----------------------------------------');
      print('DATE: $dateKey');

      // =======================================================
      // DIET + WATER
      // =======================================================

      try {
        final diet = await firestore
            .collection('dietPlans')
            .doc(uid)
            .collection('dailyProgress')
            .doc(dateKey)
            .get();

        if (diet.exists) {
          final data = diet.data();

          if (data != null) {
            // -------------------------------------------------
            // DIET COMPLETION
            // -------------------------------------------------

            final bool completed =
                data['completed'] == true;

            final bool goalCompleted =
                data['dailyGoalCompleted'] == true;

            final int mealsCompleted =
            data['mealsCompleted'] is num
                ? (data['mealsCompleted'] as num).toInt()
                : 0;

            final int mealsTarget =
            data['mealsTarget'] is num
                ? (data['mealsTarget'] as num).toInt()
                : 0;

            if (completed ||
                goalCompleted ||
                (mealsTarget > 0 &&
                    mealsCompleted >= mealsTarget)) {
              dietDays++;
            }

            // -------------------------------------------------
            // WATER CONSUMED
            // -------------------------------------------------

            if (data['waterConsumed'] is num) {
              water +=
                  (data['waterConsumed'] as num).toDouble();
            }

            // -------------------------------------------------
            // WATER TARGET
            // -------------------------------------------------

            if (data['waterTarget'] is num) {
              waterTarget +=
                  (data['waterTarget'] as num).toDouble();
            }

            print(
              'Diet document found: $dateKey',
            );
          }
        } else {
          print(
            'No diet document: $dateKey',
          );
        }
      } catch (e) {
        print(
          'DIET FIRESTORE ERROR ($dateKey): $e',
        );

        rethrow;
      }

      // =======================================================
      // WORKOUT
      // =======================================================

      bool workoutCompleted = false;

      // -------------------------------------------------------
      // WORKOUT DAY DOCUMENT
      // -------------------------------------------------------

      try {
        final workoutDay = await firestore
            .collection('users')
            .doc(uid)
            .collection('workoutProgress')
            .doc(dateKey)
            .get();

        if (workoutDay.exists) {
          final data = workoutDay.data();

          if (data != null &&
              data['completed'] == true) {
            workoutCompleted = true;
          }

          print(
            'Workout day document found: $dateKey',
          );
        } else {
          print(
            'No workout day document: $dateKey',
          );
        }
      } catch (e) {
        print(
          'WORKOUT DAY ERROR ($dateKey): $e',
        );

        rethrow;
      }

      // -------------------------------------------------------
      // WORKOUTS SUBCOLLECTION
      // -------------------------------------------------------

      try {
        final workouts = await firestore
            .collection('users')
            .doc(uid)
            .collection('workoutProgress')
            .doc(dateKey)
            .collection('workouts')
            .get();

        for (final doc in workouts.docs) {
          final data = doc.data();

          if (data['completed'] == true) {
            workoutCompleted = true;
            break;
          }
        }

        print(
          'Workout records found: ${workouts.docs.length}',
        );
      } catch (e) {
        print(
          'WORKOUTS SUBCOLLECTION ERROR ($dateKey): $e',
        );

        rethrow;
      }

      // -------------------------------------------------------
      // COUNT WORKOUT DAY
      // -------------------------------------------------------

      if (workoutCompleted) {
        workoutDays++;
      }
    }

    // =========================================================
    // WATER CALCULATION
    // =========================================================

    final int waterGlasses =
    (water / 250).round();

    final int waterTargetGlasses =
    (waterTarget / 250).round();

    int waterPercentage = 0;

    if (waterTarget > 0) {
      waterPercentage =
          ((water / waterTarget) * 100)
              .round()
              .clamp(0, 100);
    }

    // =========================================================
    // WORKOUT PERCENTAGE
    // =========================================================

    final int workoutPercentage =
    ((workoutDays / 7) * 100)
        .round()
        .clamp(0, 100);

    // =========================================================
    // DIET PERCENTAGE
    // =========================================================

    final int dietPercentage =
    ((dietDays / 7) * 100)
        .round()
        .clamp(0, 100);

    // =========================================================
    // FINAL RESULT
    // =========================================================

    print('========================================');
    print('ACHIEVED GOALS RESULT');
    print('Water: $waterGlasses / $waterTargetGlasses');
    print('Water %: $waterPercentage');
    print('Workout days: $workoutDays / 7');
    print('Workout %: $workoutPercentage');
    print('Diet days: $dietDays / 7');
    print('Diet %: $dietPercentage');
    print('========================================');

    return AchievedGoalsData(
      waterGlasses: waterGlasses,
      waterTargetGlasses: waterTargetGlasses,
      waterPercentage: waterPercentage,
      workoutCompletedDays: workoutDays,
      workoutPercentage: workoutPercentage,
      dietCompletedDays: dietDays,
      dietPercentage: dietPercentage,
    );
  }
}