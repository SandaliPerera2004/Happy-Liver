import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/risk_level.dart';
import 'assessment_service.dart';

class AssessmentFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================================
  // GET CURRENT USER ID
  // =========================================================

  static String? get currentUserId {
    return _auth.currentUser?.uid;
  }
  static User? get currentUser => _auth.currentUser;
  // =========================================================
  // GET USER DISPLAY NAME
  // =========================================================

  static Future<String> getUserDisplayName() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return 'Shehani';
      }

      // -------------------------------------------------------
      // First check Firebase Authentication display name
      // -------------------------------------------------------

      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        return user.displayName!.trim();
      }

      // -------------------------------------------------------
      // If display name is not available,
      // check Firestore users collection
      // -------------------------------------------------------

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();

        final name = data?['name'] ?? data?['fullName'] ?? data?['username'];

        if (name is String && name.trim().isNotEmpty) {
          return name.trim();
        }
      }
    } catch (_) {
      // If anything fails, use default name.
    }

    return 'Shehani';
  }

  // =========================================================
  // SAVE COMPLETED ASSESSMENT
  // =========================================================

  static Future<String> saveAssessment({
    required Map<int, List<int>> answers,
    required AssessmentResult result,
  }) async {
    final user = _auth.currentUser;

    // Make sure a user is logged in
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final userId = user.uid;

    // -------------------------------------------------------
    // Convert answers into readable format
    // -------------------------------------------------------

    final answerSummary = AssessmentService.buildAnswerSummary(answers);

    // -------------------------------------------------------
    // Create a new assessment document
    // -------------------------------------------------------

    final assessmentRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('assessments')
        .doc();

    await assessmentRef.set({
      'assessmentId': assessmentRef.id,
      'userId': userId,

      // -----------------------------------------------------
      // Answers
      // -----------------------------------------------------
      'answers': answerSummary,

      // -----------------------------------------------------
      // Fatty liver result
      // -----------------------------------------------------
      'fattyLiverScore': result.fattyLiverScore,
      'fattyLiverMaxScore': result.fattyLiverMaxScore,
      'fattyLiverRisk': result.fattyLiverRisk.name,

      // -----------------------------------------------------
      // Cholesterol result
      // -----------------------------------------------------
      'cholesterolScore': result.cholesterolScore,
      'cholesterolMaxScore': result.cholesterolMaxScore,
      'cholesterolRisk': result.cholesterolRisk.name,

      // -----------------------------------------------------
      // Date/time
      // -----------------------------------------------------
      'completedAt': FieldValue.serverTimestamp(),
    });

    return assessmentRef.id;
  }

  // =========================================================
  // GET LATEST ASSESSMENT
  //
  // This is your original method.
  //
  // It returns the Firestore document because other parts
  // of your application may already use it.
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
        .orderBy('completedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first;
  }

  // =========================================================
  // GET LATEST ASSESSMENT AS AssessmentResult
  //
  // This method is used by the Recommendation screen.
  // =========================================================

  static Future<AssessmentResult?> getLatestAssessmentResult() async {
    try {
      final document = await getLatestAssessment();

      if (document == null) {
        return null;
      }

      final data = document.data();

      if (data == null) {
        return null;
      }

      // -----------------------------------------------------
      // Get fatty liver score
      // -----------------------------------------------------

      final fattyScore = (data['fattyLiverScore'] as num?)?.toInt() ?? 0;

      final fattyMaxScore = (data['fattyLiverMaxScore'] as num?)?.toInt() ?? 0;

      // -----------------------------------------------------
      // Get cholesterol score
      // -----------------------------------------------------

      final cholesterolScore = (data['cholesterolScore'] as num?)?.toInt() ?? 0;

      final cholesterolMaxScore =
          (data['cholesterolMaxScore'] as num?)?.toInt() ?? 0;

      // -----------------------------------------------------
      // Convert Firestore risk values to RiskLevel
      // -----------------------------------------------------

      final fattyRisk = _riskLevelFromString(data['fattyLiverRisk']);

      final cholesterolRisk = _riskLevelFromString(data['cholesterolRisk']);

      // -----------------------------------------------------
      // Return AssessmentResult
      // -----------------------------------------------------

      return AssessmentResult(
        fattyLiverScore: fattyScore,
        fattyLiverMaxScore: fattyMaxScore,
        cholesterolScore: cholesterolScore,
        cholesterolMaxScore: cholesterolMaxScore,
        fattyLiverRisk: fattyRisk,
        cholesterolRisk: cholesterolRisk,
      );
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // CONVERT FIRESTORE STRING TO RiskLevel
  //
  // Your RiskLevel class does not have fromString(),
  // so we handle the conversion here.
  // =========================================================

  static RiskLevel _riskLevelFromString(dynamic value) {
    if (value == null) {
      return RiskLevel.low;
    }

    final text = value.toString().trim().toLowerCase();

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
  // GET ALL ASSESSMENTS
  // =========================================================

  static Future<List<DocumentSnapshot<Map<String, dynamic>>>>
  getAssessmentHistory() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs;
  }

  // =========================================================
  // GET ASSESSMENT RESULT FROM A FIRESTORE DOCUMENT
  //
  // This can be useful if another screen already has a
  // DocumentSnapshot and needs an AssessmentResult.
  // =========================================================

  static AssessmentResult? assessmentResultFromDocument(
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
  // MAP FIRESTORE DATA TO AssessmentResult
  // =========================================================

  static AssessmentResult _mapToAssessmentResult(Map<String, dynamic> data) {
    // -------------------------------------------------------
    // Fatty liver score
    // -------------------------------------------------------

    final fattyScore = (data['fattyLiverScore'] as num?)?.toInt() ?? 0;

    final fattyMaxScore = (data['fattyLiverMaxScore'] as num?)?.toInt() ?? 0;

    // -------------------------------------------------------
    // Cholesterol score
    // -------------------------------------------------------

    final cholesterolScore = (data['cholesterolScore'] as num?)?.toInt() ?? 0;

    final cholesterolMaxScore =
        (data['cholesterolMaxScore'] as num?)?.toInt() ?? 0;

    // -------------------------------------------------------
    // Risk levels
    // -------------------------------------------------------

    final fattyRisk = _riskLevelFromString(data['fattyLiverRisk']);

    final cholesterolRisk = _riskLevelFromString(data['cholesterolRisk']);

    // -------------------------------------------------------
    // Return AssessmentResult
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
  // GENERATE INSIGHT MESSAGE
  // =========================================================

  static String generateInsight(AssessmentResult result) {
    final fattyRisk = result.fattyLiverRisk;
    final cholesterolRisk = result.cholesterolRisk;

    // -------------------------------------------------------
    // Both HIGH
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.high && cholesterolRisk == RiskLevel.high) {
      return 'High risk detected for both fatty liver and cholesterol. '
          'Focus on healthy lifestyle changes and consider consulting '
          'a qualified healthcare professional.';
    }

    // -------------------------------------------------------
    // Fatty liver HIGH
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.high) {
      return 'Elevated fatty liver risk detected. '
          'Focus on reducing refined sugars, choosing healthier foods, '
          'and maintaining regular physical activity.';
    }

    // -------------------------------------------------------
    // Cholesterol HIGH
    // -------------------------------------------------------

    if (cholesterolRisk == RiskLevel.high) {
      return 'Elevated cholesterol risk detected. '
          'Prioritize high-fiber foods, lean proteins, and healthier '
          'fats while reducing saturated fats.';
    }

    // -------------------------------------------------------
    // Fatty liver MODERATE + Cholesterol LOW
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.moderate && cholesterolRisk == RiskLevel.low) {
      return 'Focus on improving your lifestyle to reduce fatty liver '
          'risk while maintaining your low cholesterol risk.';
    }

    // -------------------------------------------------------
    // Fatty liver LOW + Cholesterol MODERATE
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.low && cholesterolRisk == RiskLevel.moderate) {
      return 'Your liver risk is low. Consider increasing physical '
          'activity and choosing more fiber-rich foods to help '
          'keep cholesterol under control.';
    }

    // -------------------------------------------------------
    // Both MODERATE
    // -------------------------------------------------------

    if (fattyRisk == RiskLevel.moderate &&
        cholesterolRisk == RiskLevel.moderate) {
      return 'Both risk factors are moderate. Simple improvements '
          'to your daily diet, physical activity, sleep, and other '
          'healthy habits can help reduce your risk.';
    }

    // -------------------------------------------------------
    // Both LOW
    // -------------------------------------------------------

    return 'Great job! Your liver and cholesterol risk levels are low. '
        'Keep maintaining healthy daily habits and a balanced diet.';
  }
}
