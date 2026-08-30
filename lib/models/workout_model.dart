class WorkoutModel {
  final String id;
  final String name;
  final int duration;
  final String riskLevel;
  final String support;
  final String imageUrl;
  final String videoUrl;
  final List<String> instructions;
  final List<String> benefits;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.riskLevel,
    required this.support,
    required this.imageUrl,
    required this.videoUrl,
    required this.instructions,
    required this.benefits,
  });

  factory WorkoutModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return WorkoutModel(
      id: id,

      // Name
      name: data['name']?.toString() ?? '',

      // Duration
      duration: data['duration'] is int
          ? data['duration']
          : int.tryParse(
        data['duration']?.toString() ?? '0',
      ) ??
          0,

      // Accept both riskLevel and risklevel
      riskLevel: (
          data['riskLevel'] ??
              data['risklevel'] ??
              ''
      ).toString(),

      // Support
      support: data['support']?.toString() ?? '',

      // Image URL
      imageUrl: data['imageUrl']?.toString() ?? '',

      // Video URL
      videoUrl: data['videoUrl']?.toString() ?? '',

      // Instructions
      instructions: _convertToList(
        data['instructions'],
      ),

      // Benefits
      benefits: _convertToList(
        data['benefits'],
      ),
    );
  }

  static List<String> _convertToList(dynamic value) {
    // If Firestore contains a proper array
    if (value is List) {
      return value
          .map((item) => item.toString())
          .toList();
    }

    // If Firestore contains a string representation
    // such as:
    // ["Stand tall", "Lift one knee", "Keep breathing"]
    if (value is String && value.trim().isNotEmpty) {
      String text = value.trim();

      // Remove [ and ]
      if (text.startsWith('[') && text.endsWith(']')) {
        text = text.substring(1, text.length - 1);
      }

      if (text.isEmpty) {
        return [];
      }

      return text
          .split('", "')
          .map(
            (item) => item
            .replaceAll('"', '')
            .trim(),
      )
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [];
  }
}