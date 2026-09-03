class NotificationSettingsModel {
  final bool allowNotifications;
  final bool healthTips;
  final bool routineReminder;

  NotificationSettingsModel({
    required this.allowNotifications,
    required this.healthTips,
    required this.routineReminder,
  });

  Map<String, dynamic> toMap() {
    return {
      'allowNotifications': allowNotifications,
      'healthTips': healthTips,
      'routineReminder': routineReminder,
    };
  }

  factory NotificationSettingsModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return NotificationSettingsModel(
      allowNotifications:
      map['allowNotifications'] ?? true,
      healthTips:
      map['healthTips'] ?? true,
      routineReminder:
      map['routineReminder'] ?? true,
    );
  }
}