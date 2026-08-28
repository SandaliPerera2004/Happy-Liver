import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/risk_level.dart';

class AssessmentFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================================
  // GET CURRENT USER ID (OR NULL)
  // =========================================================
  static String? get currentUserId => _auth.currentUser?.uid;

  // =========================================================
  // GET USER DISPLAY NAME
  // =========================================================
  static Future<String> getUserDisplayName() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Shehani';
      }

      if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        return user.displayName!.trim();
      }

      // Check Firestore user doc
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final name = data?['name'] ?? data?['fullName'] ?? data?['username'];
        if (name is String && name.trim().isNotEmpty) {
          return name.trim();
        }
      }
    } catch (_) {}
    return 'Shehani';
  }

  // =========================================================
  // SAVE COMPLETED ASSESSMENT
  // =========================================================
  static Future<String> saveAssessment({
    required AssessmentResult result,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final userId = user.uid;

    final assessmentRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('assessments')
        .doc();

    final data = {
      'assessmentId': assessmentRef.id,
      'userId': userId,
      'fattyLiverScore': result.fattyLiverScore,
      'fattyLiverMaxScore': result.fattyLiverMaxScore,
      'fattyLiverRisk': result.fattyLiverRisk.name,
      'fattyLiverPercentage': result.fattyLiverPercentage,
      'cholesterolScore': result.cholesterolScore,
      'cholesterolMaxScore': result.cholesterolMaxScore,
      'cholesterolRisk': result.cholesterolRisk.name,
      'cholesterolPercentage': result.cholesterolPercentage,
      'overallRiskScore': result.overallPercentage,
      'overallRisk': result.overallRisk.name,
      'completedAt': FieldValue.serverTimestamp(),
    };

    await assessmentRef.set(data);

    // Also cache the latest assessment summary on the main user document
    try {
      await _firestore.collection('users').doc(userId).set({
        'latestAssessment': data,
        'lastAssessmentAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}

    return assessmentRef.id;
  }

  // =========================================================
  // GET LATEST ASSESSMENT (FUTURE)
  // =========================================================
  static Future<AssessmentResult?> getLatestAssessment() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Look in demo / public latest if exists or return default
        return _fetchFallbackPublicOrDemoAssessment();
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return _mapToAssessmentResult(data);
      }

      // Check if user has 'latestAssessment' map field directly
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final latest = userDoc.data()?['latestAssessment'];
        if (latest is Map<String, dynamic>) {
          return _mapToAssessmentResult(latest);
        }
      }

      return _fetchFallbackPublicOrDemoAssessment();
    } catch (e) {
      return _fetchFallbackPublicOrDemoAssessment();
    }
  }

  // =========================================================
  // STREAM LATEST ASSESSMENT (STREAM)
  // =========================================================
  static Stream<AssessmentResult?> getLatestAssessmentStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.fromFuture(getLatestAssessment());
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('assessments')
        .orderBy('completedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return _mapToAssessmentResult(data);
      }
      return null;
    });
  }

  // =========================================================
  // MAP FIRESTORE DATA TO AssessmentResult
  // =========================================================
  static AssessmentResult _mapToAssessmentResult(Map<String, dynamic> data) {
    final fattyScore = (data['fattyLiverScore'] as num?)?.toInt() ?? 0;
    final fattyMax = (data['fattyLiverMaxScore'] as num?)?.toInt() ?? 0;
    final chScore = (data['cholesterolScore'] as num?)?.toInt() ?? 0;
    final chMax = (data['cholesterolMaxScore'] as num?)?.toInt() ?? 0;

    final fattyPercentage = (data['fattyLiverPercentage'] as num?)?.toInt();
    final chPercentage = (data['cholesterolPercentage'] as num?)?.toInt();
    final overallScore = (data['overallRiskScore'] as num?)?.toInt() ??
        (data['overallScore'] as num?)?.toInt();

    final fattyRisk = RiskLevel.fromString(data['fattyLiverRisk'] as String?);
    final chRisk = RiskLevel.fromString(data['cholesterolRisk'] as String?);
    final overallRisk = data['overallRisk'] != null
        ? RiskLevel.fromString(data['overallRisk'] as String?)
        : null;

    DateTime? completedAt;
    if (data['completedAt'] != null) {
      final dynamic ts = data['completedAt'];
      if (ts is Timestamp) {
        completedAt = ts.toDate();
      } else if (ts is DateTime) {
        completedAt = ts;
      } else if (ts is String) {
        completedAt = DateTime.tryParse(ts);
      }
    }

    return AssessmentResult(
      fattyLiverScore: fattyScore,
      fattyLiverMaxScore: fattyMax,
      cholesterolScore: chScore,
      cholesterolMaxScore: chMax,
      fattyLiverRisk: fattyRisk,
      cholesterolRisk: chRisk,
      customFattyLiverPercentage: fattyPercentage,
      customCholesterolPercentage: chPercentage,
      customOverallRiskScore: overallScore,
      customOverallRisk: overallRisk,
      completedAt: completedAt,
    );
  }

  // Fallback demo/mock result when no firestore record is yet created
  static Future<AssessmentResult?> _fetchFallbackPublicOrDemoAssessment() async {
    try {
      // Check top-level assessments collection as backup
      final snapshot = await _firestore
          .collection('assessments')
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _mapToAssessmentResult(snapshot.docs.first.data());
      }
    } catch (_) {}

    // Default reference assessment result
    return const AssessmentResult(
      fattyLiverScore: 13,
      fattyLiverMaxScore: 20,
      cholesterolScore: 5,
      cholesterolMaxScore: 20,
      fattyLiverRisk: RiskLevel.moderate,
      cholesterolRisk: RiskLevel.low,
      customOverallRiskScore: 70,
      customFattyLiverPercentage: 65,
      customCholesterolPercentage: 25,
    );
  }

  // =========================================================
  // DYNAMIC INSIGHT MESSAGE BUILDER
  // =========================================================
  static String generateInsight(AssessmentResult result) {
    final flRisk = result.fattyLiverRisk;
    final chRisk = result.cholesterolRisk;

    if (flRisk == RiskLevel.high && chRisk == RiskLevel.high) {
      return 'High risk detected for both fatty liver and cholesterol. We recommend consulting a healthcare specialist and switching to a nutrient-rich, low-fat diet.';
    } else if (flRisk == RiskLevel.high) {
      return 'Elevated fatty liver risk detected. Focus on reducing refined sugars, avoiding alcohol, and engaging in daily aerobic exercise.';
    } else if (chRisk == RiskLevel.high) {
      return 'Elevated cholesterol risk detected. Prioritize whole grains, soluble fiber, lean proteins, and reducing saturated fats.';
    } else if (flRisk == RiskLevel.moderate && chRisk == RiskLevel.low) {
      return 'Focus on improving your lifestyle to reduce fatty liver risk and maintain low cholesterol!';
    } else if (flRisk == RiskLevel.low && chRisk == RiskLevel.moderate) {
      return 'Your liver habits are good! Consider incorporating more cardio and leafy greens to keep cholesterol in check.';
    } else if (flRisk == RiskLevel.moderate && chRisk == RiskLevel.moderate) {
      return 'Both risk factors are moderate. Simple daily lifestyle and dietary improvements can help you reach the low risk zone.';
    } else {
      return 'Great job! Your liver and cholesterol risk levels are low. Keep maintaining your healthy daily habits and balanced diet.';
    }
  }
}
