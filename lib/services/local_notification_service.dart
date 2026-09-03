import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final LocalNotificationService _instance =
  LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // =========================================================
  // INITIALIZE
  // =========================================================

  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Use Sri Lanka time
    tz.setLocalLocation(
      tz.getLocation('Asia/Colombo'),
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );

    // Android 13+ notification permission
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // =========================================================
  // ROUTINE REMINDER
  // 7:00 AM EVERY DAY
  // =========================================================

  Future<void> scheduleRoutineReminder() async {
    await _notifications.zonedSchedule(
      id: 1001,
      title: '🏃 Routine Reminder',
      body:
      'Good morning! It\'s time to follow your daily routine and workout plan.',
      scheduledDate: _nextInstanceOfTime(
        hour: 7,
        minute: 0,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'routine_reminder_channel',
          'Routine Reminders',
          channelDescription:
          'Daily reminders for your meal and workout routine.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }

  // =========================================================
  // HEALTH TIP
  // 11:00 AM EVERY DAY
  // =========================================================

  Future<void> scheduleHealthTip() async {
    await _notifications.zonedSchedule(
      id: 1002,
      title: '💚 Health Tip',
      body:
      'Choose healthy foods and stay active to support your liver health.',
      scheduledDate: _nextInstanceOfTime(
        hour: 11,
        minute: 0,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'health_tip_channel',
          'Health Tips',
          channelDescription:
          'Daily health tips and lifestyle recommendations.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }


  // =========================================================
  // CANCEL ROUTINE REMINDER
  // =========================================================

  Future<void> cancelRoutineReminder() async {
    await _notifications.cancel(
      id: 1001,
    );
  }

  // =========================================================
  // CANCEL HEALTH TIP
  // =========================================================

  Future<void> cancelHealthTip() async {
    await _notifications.cancel(
      id: 1002,
    );
  }

  // =========================================================
  // CANCEL ALL
  // =========================================================

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // =========================================================
  // GET NEXT OCCURRENCE
  // =========================================================

  tz.TZDateTime _nextInstanceOfTime({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(
      tz.local,
    );

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time has already passed,
    // schedule for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    return scheduledDate;
  }
}