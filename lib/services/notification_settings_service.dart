import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_settings_model.dart';
import 'local_notification_service.dart';

class NotificationSettingsService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final LocalNotificationService _localNotificationService =
  LocalNotificationService();

  // =========================================================
  // GET CURRENT USER ID
  // =========================================================

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // =========================================================
  // GET NOTIFICATION SETTINGS
  // =========================================================

  Future<NotificationSettingsModel>
  getNotificationSettings() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    NotificationSettingsModel settings;

    // -------------------------------------------------------
    // DEFAULT SETTINGS
    // -------------------------------------------------------

    if (data == null ||
        data['notificationSettings'] == null) {
      settings = NotificationSettingsModel(
        allowNotifications: true,
        healthTips: true,
        routineReminder: true,
      );
    } else {
      // -----------------------------------------------------
      // LOAD SAVED SETTINGS
      // -----------------------------------------------------

      settings = NotificationSettingsModel.fromMap(
        Map<String, dynamic>.from(
          data['notificationSettings'],
        ),
      );
    }

    // -------------------------------------------------------
    // SYNCHRONIZE LOCAL NOTIFICATIONS
    // -------------------------------------------------------

    await _syncLocalNotifications(settings);

    return settings;
  }

  // =========================================================
  // UPDATE NOTIFICATION SETTINGS
  // =========================================================

  Future<void> updateNotificationSettings(
      NotificationSettingsModel settings,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    // -------------------------------------------------------
    // SAVE SETTINGS TO FIRESTORE
    // -------------------------------------------------------

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'notificationSettings': settings.toMap(),
      },
      SetOptions(merge: true),
    );

    // -------------------------------------------------------
    // UPDATE LOCAL NOTIFICATIONS
    // -------------------------------------------------------

    await _syncLocalNotifications(settings);
  }

  // =========================================================
  // SYNCHRONIZE LOCAL NOTIFICATIONS
  // =========================================================

  Future<void> _syncLocalNotifications(
      NotificationSettingsModel settings,
      ) async {
    // -------------------------------------------------------
    // MASTER SWITCH OFF
    // -------------------------------------------------------

    if (!settings.allowNotifications) {
      await _localNotificationService
          .cancelAllNotifications();

      return;
    }

    // -------------------------------------------------------
    // HEALTH TIPS
    // -------------------------------------------------------

    if (settings.healthTips) {
      await _localNotificationService
          .scheduleHealthTip();
    } else {
      await _localNotificationService
          .cancelHealthTip();
    }

    // -------------------------------------------------------
    // ROUTINE REMINDER
    // -------------------------------------------------------

    if (settings.routineReminder) {
      await _localNotificationService
          .scheduleRoutineReminder();
    } else {
      await _localNotificationService
          .cancelRoutineReminder();
    }
  }
}