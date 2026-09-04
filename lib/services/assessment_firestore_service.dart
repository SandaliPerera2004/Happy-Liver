import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/risk_level.dart';
import 'assessment_service.dart';

class AssessmentFirestoreService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // =========================================================
  // CURRENT USER ID
  // =========================================================

  static String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // =========================================================
  // CURRENT USER
  // =========================================================

  static User? get currentUser {
    return _auth.currentUser;
  }

  // =========================================================
  // GET USER DISPLAY NAME
  // =========================================================

  static Future<String> getUserDisplayName() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return 'user';
      }

      // -------------------------------------------------------
      // FIRST: Firebase Authentication display name
      // -------------------------------------------------------

      if (user.displayName != null &&
          user.displayName!.trim().isNotEmpty) {
        return user.displayName!.trim();
      }

      // -------------------------------------------------------
      // SECOND: Firestore users collection
      // -------------------------------------------------------

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();

        final name =
            data?['name'] ??
                data?['fullName'] ??
                data?['username'];

        if (name is String && name.trim().isNotEmpty) {
          return name.trim();
        }
      }
    } catch (e) {
      // Use default name if anything fails.
    }

    return 'user';
  }

  // =========================================================
  // SAVE COMPLETED ASSESSMENT
  // =========================================================

  static Future<String> saveAssessment({
    required Map<int, List<int>> answers,
    required AssessmentResult result,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final userId = user.uid;

    // -------------------------------------------------------
    // Convert answers into readable format
    // -------------------------------------------------------

    final answerSummary =
    AssessmentService.buildAnswerSummary(answers);

    // -------------------------------------------------------
    // Create new assessment document
    // -------------------------------------------------------

    final assessmentRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('assessments')
        .doc();

    // -------------------------------------------------------
    // Save assessment
    // -------------------------------------------------------

    await assessmentRef.set({
      'assessmentId': assessmentRef.id,

      'userId': userId,

      // Answers
      'answers': answerSummary,

      // Fatty liver
      'fattyLiverScore': result.fattyLiverScore,
      'fattyLiverMaxScore': result.fattyLiverMaxScore,
      'fattyLiverRisk': result.fattyLiverRisk.name,

      // Cholesterol
      'cholesterolScore': result.cholesterolScore,
      'cholesterolMaxScore': result.cholesterolMaxScore,
      'cholesterolRisk': result.cholesterolRisk.name,

      // Date
      'completedAt': FieldValue.serverTimestamp(),
    });

    // =======================================================
    // SAVE OVERALL RISK FOR DIET PLAN
    // =======================================================

    final overallRisk =
    result.fattyLiverRisk == RiskLevel.high ||
        result.cholesterolRisk == RiskLevel.high
        ? RiskLevel.high
        : result.fattyLiverRisk == RiskLevel.moderate ||
        result.cholesterolRisk == RiskLevel.moderate
        ? RiskLevel.moderate
        : RiskLevel.low;

    await _firestore
        .collection('dietPlans')
        .doc(userId)
        .set(
      {
        'riskLevel': overallRisk.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // =======================================================
    // MARK USER ASSESSMENT COMPLETED
    // =======================================================

    await _firestore
        .collection('users')
        .doc(userId)
        .set(
      {
        'assessmentCompleted': true,
      },
      SetOptions(merge: true),
    );

    return assessmentRef.id;
  }

  // =========================================================
  // GET LATEST ASSESSMENT
  // =========================================================

  static Future<DocumentSnapshot<Map<String, dynamic>>?>
  getLatestAssessment() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .orderBy(
      'completedAt',
      descending: true,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first;
  }

  // =========================================================
  // GET LATEST ASSESSMENT RESULT
  // =========================================================

  static Future<AssessmentResult?>
  getLatestAssessmentResult() async {
    try {
      final document = await getLatestAssessment();

      if (document == null) {
        return null;
      }

      final data = document.data();

      if (data == null) {
        return null;
      }

      return _mapToAssessmentResult(data);
    } catch (e) {
      return null;
    }
  }

  // =========================================================
  // CONVERT FIRESTORE RISK STRING
  // =========================================================

  static RiskLevel _riskLevelFromString(dynamic value) {
    if (value == null) {
      return RiskLevel.low;
    }

    final text = value
        .toString()
        .trim()
        .toLowerCase();

    switch (text) {
      case 'high':
        return RiskLevel.high;

      case 'moderate':
        return RiskLevel.moderate;

      case 'low':
      default:
        return RiskLevel.low;
    }
  }

  // =========================================================
  // MAP FIRESTORE DATA TO ASSESSMENT RESULT
  // =========================================================

  static AssessmentResult _mapToAssessmentResult(
      Map<String, dynamic> data,
      ) {
    // -------------------------------------------------------
    // Fatty liver
    // -------------------------------------------------------

    final fattyScore =
        (data['fattyLiverScore'] as num?)?.toInt() ?? 0;

    final fattyMaxScore =
        (data['fattyLiverMaxScore'] as num?)?.toInt() ?? 0;

    // -------------------------------------------------------
    // Cholesterol
    // -------------------------------------------------------

    final cholesterolScore =
        (data['cholesterolScore'] as num?)?.toInt() ?? 0;

    final cholesterolMaxScore =
        (data['cholesterolMaxScore'] as num?)?.toInt() ?? 0;

    // -------------------------------------------------------
    // Risk
    // -------------------------------------------------------

    final fattyRisk =
    _riskLevelFromString(
      data['fattyLiverRisk'],
    );

    final cholesterolRisk =
    _riskLevelFromString(
      data['cholesterolRisk'],
    );

    // -------------------------------------------------------
    // Return result
    // -------------------------------------------------------

    return AssessmentResult(
      fattyLiverScore: fattyScore,
      fattyLiverMaxScore: fattyMaxScore,
      cholesterolScore: cholesterolScore,
      cholesterolMaxScore: cholesterolMaxScore,
      fattyLiverRisk: fattyRisk,
      cholesterolRisk: cholesterolRisk,
    );
  }

  // =========================================================
  // GET ASSESSMENT HISTORY
  // =========================================================

  static Future<
      List<DocumentSnapshot<Map<String, dynamic>>>>
  getAssessmentHistory() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .orderBy(
      'completedAt',
      descending: true,
    )
        .get();

    return snapshot.docs;
  }

  // =========================================================
  // CONVERT DOCUMENT TO ASSESSMENT RESULT
  // =========================================================

  static AssessmentResult?
  assessmentResultFromDocument(
      DocumentSnapshot<Map<String, dynamic>>? document,
      ) {
    if (document == null) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return _mapToAssessmentResult(data);
  }

  // =========================================================
  // GENERATE INSIGHT
  // =========================================================

  static String generateInsight(
      AssessmentResult result,
      ) {
    final fattyRisk = result.fattyLiverRisk;
    final cholesterolRisk = result.cholesterolRisk;

    // -------------------------------------------------------
    // HIGH + HIGH
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.high &&
        cholesterolRisk == RiskLevel.high) {
      return 'High risk detected for both fatty liver and cholesterol. '
          'Focus on healthy lifestyle changes and consider consulting '
          'a qualified healthcare professional.';
    }

    // -------------------------------------------------------
    // HIGH FATTY LIVER
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.high) {
      return 'Elevated fatty liver risk detected. '
          'Focus on reducing refined sugars, choosing healthier foods, '
          'and maintaining regular physical activity.';
    }

    // -------------------------------------------------------
    // HIGH CHOLESTEROL
    // -------------------------------------------------------

    if (cholesterolRisk == RiskLevel.high) {
      return 'Elevated cholesterol risk detected. '
          'Prioritize high-fiber foods, lean proteins, and healthier '
          'fats while reducing saturated fats.';
    }

    // -------------------------------------------------------
    // MODERATE FATTY + LOW CHOLESTEROL
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.moderate &&
        cholesterolRisk == RiskLevel.low) {
      return 'Focus on improving your lifestyle to reduce fatty liver '
          'risk while maintaining your low cholesterol risk.';
    }

    // -------------------------------------------------------
    // LOW FATTY + MODERATE CHOLESTEROL
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.low &&
        cholesterolRisk == RiskLevel.moderate) {
      return 'Your liver risk is low. Consider increasing physical '
          'activity and choosing more fiber-rich foods to help '
          'keep cholesterol under control.';
    }

    // -------------------------------------------------------
    // MODERATE + MODERATE
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.moderate &&
        cholesterolRisk == RiskLevel.moderate) {
      return 'Both risk factors are moderate. Simple improvements '
          'to your daily diet, physical activity, sleep, and other '
          'healthy habits can help reduce your risk.';
    }

    // -------------------------------------------------------
    // LOW + LOW
    // -------------------------------------------------------

    return 'Great job! Your liver and cholesterol risk levels are low. '
        'Keep maintaining healthy daily habits and a balanced diet.';
  }
}