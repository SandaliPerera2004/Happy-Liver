class AppSettingsModel {
  final bool darkMode;

  AppSettingsModel({
    required this.darkMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      darkMode: map['darkMode'] ?? false,
    );
  }
}