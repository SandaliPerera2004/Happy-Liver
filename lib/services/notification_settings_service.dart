import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_settings_model.dart';

class NotificationSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<NotificationSettingsModel> getNotificationSettings() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (data == null || data['notificationSettings'] == null) {
      return NotificationSettingsModel(
        allowNotifications: true,
        healthTips: true,
        routineReminder: true,
      );
    }

    return NotificationSettingsModel.fromMap(
      Map<String, dynamic>.from(data['notificationSettings']),
    );
  }

  Future<void> updateNotificationSettings(
      NotificationSettingsModel settings,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'notificationSettings': settings.toMap(),
      },
      SetOptions(merge: true),
    );
  }
}