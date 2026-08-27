import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  // Helper to get effective user ID and details
  static Future<Map<String, String>> _getUserDetails() async {
    final user = currentUser;
    String userId = user?.uid ?? 'guest_user';
    String username = user?.displayName ?? 'User';
    String userEmail = user?.email ?? '';

    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          username = userDoc.data()?['username'] as String? ?? username;
          userEmail = userDoc.data()?['email'] as String? ?? userEmail;
        }
      } catch (e) {
        // Fallback to auth details
      }
    }

    return {
      'userId': userId,
      'username': username,
      'userEmail': userEmail,
    };
  }

  // ===========================================================================
  // 1. FEEDBACK SERVICE (Writes to feedback, feedbacks & users/{uid}/feedback)
  // ===========================================================================
  static Future<bool> sendFeedback({
    required int rating,
    required String feedbackText,
    String category = 'General',
  }) async {
    try {
      final userDetails = await _getUserDetails();
      final userId = userDetails['userId']!;
      final username = userDetails['username']!;
      final userEmail = userDetails['userEmail']!;

      final Map<String, dynamic> feedbackData = {
        'userId': userId,
        'username': username,
        'userEmail': userEmail,
        'rating': rating,
        'category': category,
        'feedbackText': feedbackText.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 1. Write to 'feedback' collection (singular)
      await _firestore.collection('feedback').add(feedbackData);

      // 2. Write to 'feedbacks' collection (plural)
      final docRef = await _firestore.collection('feedbacks').add(feedbackData);

      // 3. Write to user subcollection if user is logged in
      final user = currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('feedback')
            .doc(docRef.id)
            .set(feedbackData);

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('feedbacks')
            .doc(docRef.id)
            .set(feedbackData);
      }

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error sending feedback to Firestore: $e');
      return false;
    }
  }

  // ===========================================================================
  // 2. REPORT A PROBLEM SERVICE
  // ===========================================================================
  static Future<bool> reportProblem({
    required String category,
    required String description,
  }) async {
    try {
      final userDetails = await _getUserDetails();
      final userId = userDetails['userId']!;
      final username = userDetails['username']!;
      final userEmail = userDetails['userEmail']!;

      final Map<String, dynamic> problemData = {
        'userId': userId,
        'username': username,
        'userEmail': userEmail,
        'category': category.trim(),
        'description': description.trim(),
        'feedbackText': description.trim(),
        'status': 'Pending', // Pending, Under Review, Resolved
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 1. Write to 'reported_problems'
      final docRef =
          await _firestore.collection('reported_problems').add(problemData);

      // 2. Write to 'problems' collection
      await _firestore.collection('problems').doc(docRef.id).set(problemData);

      // 3. Write to user subcollection
      final user = currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('reported_problems')
            .doc(docRef.id)
            .set(problemData);
      }

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error reporting problem to Firestore: $e');
      return false;
    }
  }

  // Stream of user's reported problems
  static Stream<QuerySnapshot<Map<String, dynamic>>> getReportedProblemsStream() {
    final user = currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reported_problems')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection('reported_problems')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots();
    }
  }

  // ===========================================================================
  // 3. NOTIFICATION PREFERENCES SERVICE (Stores in users/{uid}, notifications)
  // ===========================================================================
  static Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool localAllow = prefs.getBool('allowNotifications') ?? true;
      bool localTips = prefs.getBool('healthTips') ?? true;
      bool localReminder = prefs.getBool('routineReminder') ?? true;

      final user = currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final allow = data['allowNotifications'] as bool? ?? localAllow;
          final tips = data['healthTips'] as bool? ?? localTips;
          final reminder = data['routineReminder'] as bool? ?? localReminder;

          return {
            'allowNotifications': allow,
            'healthTips': tips,
            'routineReminder': reminder,
          };
        } else {
          // Document or fields don't exist yet, write defaults to Firestore right away
          await saveNotificationPreferences(
            allowNotifications: localAllow,
            healthTips: localTips,
            routineReminder: localReminder,
          );
        }
      }

      return {
        'allowNotifications': localAllow,
        'healthTips': localTips,
        'routineReminder': localReminder,
      };
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching notification preferences: $e');
      return {
        'allowNotifications': true,
        'healthTips': true,
        'routineReminder': true,
      };
    }
  }

  static Future<void> saveNotificationPreferences({
    required bool allowNotifications,
    required bool healthTips,
    required bool routineReminder,
  }) async {
    try {
      // 1. Save locally in SharedPreferences for offline speed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('allowNotifications', allowNotifications);
      await prefs.setBool('healthTips', healthTips);
      await prefs.setBool('routineReminder', routineReminder);

      final user = currentUser;
      final userId = user?.uid ?? 'guest_user';

      final Map<String, dynamic> notifData = {
        'userId': userId,
        'allowNotifications': allowNotifications,
        'healthTips': healthTips,
        'routineReminder': routineReminder,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 2. Save directly inside 'users/{userId}' document
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'allowNotifications': allowNotifications,
          'healthTips': healthTips,
          'routineReminder': routineReminder,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 3. Save inside 'users/{userId}/notifications/preferences' subcollection
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc('preferences')
            .set(notifData, SetOptions(merge: true));
      }

      // 4. Save inside top-level 'notifications/{userId}' collection
      await _firestore
          .collection('notifications')
          .doc(userId)
          .set(notifData, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print('Error saving notification preferences to Firestore: $e');
    }
  }
}
