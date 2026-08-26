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
  // SAVE COMPLETED ASSESSMENT
  // =========================================================

  static Future<String> saveAssessment({
    required Map<int, List<int>> answers,
    required AssessmentResult result,
  }) async {
    final user = _auth.currentUser;

    // Make sure a user is logged in
    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    final userId = user.uid;

    // Convert answers into readable format
    final answerSummary =
    AssessmentService.buildAnswerSummary(answers);

    // Create a new assessment document
    final assessmentRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('assessments')
        .doc();

    await assessmentRef.set({
      'assessmentId': assessmentRef.id,
      'userId': userId,

      // Answers
      'answers': answerSummary,

      // Fatty liver result
      'fattyLiverScore': result.fattyLiverScore,
      'fattyLiverMaxScore': result.fattyLiverMaxScore,
      'fattyLiverRisk':
      result.fattyLiverRisk.name,

      // Cholesterol result
      'cholesterolScore': result.cholesterolScore,
      'cholesterolMaxScore': result.cholesterolMaxScore,
      'cholesterolRisk':
      result.cholesterolRisk.name,

      // Date/time
      'completedAt':
      FieldValue.serverTimestamp(),
    });

    return assessmentRef.id;
  }

  // =========================================================
  // GET LATEST ASSESSMENT
  // =========================================================

  static Future<DocumentSnapshot<Map<String, dynamic>>?>
  getLatestAssessment() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
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
  // GET ALL ASSESSMENTS
  // =========================================================

  static Future<
      List<DocumentSnapshot<Map<String, dynamic>>>>
  getAssessmentHistory() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
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
}