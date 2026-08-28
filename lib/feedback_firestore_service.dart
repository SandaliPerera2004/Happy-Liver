import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================================
  // SAVE USER FEEDBACK
  // =========================================================
  /// Saves user feedback to `users/{userId}/feedback/{feedbackId}`
  /// and also to top-level `feedbacks/{feedbackId}` collection.
  static Future<String> submitFeedback({
    required int rating,
    required String feedbackText,
  }) async {
    final user = _auth.currentUser;
    final userId = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final userEmail = user?.email ?? 'guest@happyliver.com';

    final feedbackData = {
      'userId': userId,
      'userEmail': userEmail,
      'rating': rating,
      'feedback': feedbackText.trim(),
      'type': 'app_feedback',
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 1. Add to users/{userId}/feedback subcollection
    final userFeedbackRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('feedback')
        .doc();

    feedbackData['feedbackId'] = userFeedbackRef.id;

    await userFeedbackRef.set(feedbackData);

    // 2. Also save to root 'feedbacks' collection for centralized admin access
    try {
      await _firestore
          .collection('feedbacks')
          .doc(userFeedbackRef.id)
          .set(feedbackData);
    } catch (_) {}

    // 3. Update last feedback timestamp on user doc
    try {
      await _firestore.collection('users').doc(userId).set({
        'lastFeedbackAt': FieldValue.serverTimestamp(),
        'lastRating': rating,
      }, SetOptions(merge: true));
    } catch (_) {}

    return userFeedbackRef.id;
  }

  // =========================================================
  // SUBMIT PROBLEM REPORT
  // =========================================================
  /// Saves a problem report under `users/{userId}/reports/{reportId}`
  /// and top-level `reports/{reportId}`.
  static Future<String> submitProblemReport({
    required String problemDescription,
  }) async {
    final user = _auth.currentUser;
    final userId = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final userEmail = user?.email ?? 'guest@happyliver.com';

    final reportData = {
      'userId': userId,
      'userEmail': userEmail,
      'description': problemDescription.trim(),
      'type': 'problem_report',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 1. Add to users/{userId}/reports subcollection
    final userReportRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('reports')
        .doc();

    reportData['reportId'] = userReportRef.id;

    await userReportRef.set(reportData);

    // 2. Also save to root 'reports' collection
    try {
      await _firestore
          .collection('reports')
          .doc(userReportRef.id)
          .set(reportData);
    } catch (_) {}

    return userReportRef.id;
  }

  // =========================================================
  // GET USER FEEDBACK HISTORY
  // =========================================================
  static Future<List<Map<String, dynamic>>> getUserFeedbackHistory() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      return [];
    }
  }
}
