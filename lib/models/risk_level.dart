enum RiskLevel {
  low,
  moderate,
  high;

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.moderate:
        return 'Moderate';
      case RiskLevel.high:
        return 'High';
    }
  }

  static RiskLevel fromString(String? value) {
    if (value == null) return RiskLevel.low;
    switch (value.toLowerCase().trim()) {
      case 'moderate':
        return RiskLevel.moderate;
      case 'high':
        return RiskLevel.high;
      case 'low':
      default:
        return RiskLevel.low;
    }
  }
}

class AssessmentResult {
  final int fattyLiverScore;
  final int fattyLiverMaxScore;

  final int cholesterolScore;
  final int cholesterolMaxScore;

  final RiskLevel fattyLiverRisk;
  final RiskLevel cholesterolRisk;

  // Optional precalculated values
  final int? customFattyLiverPercentage;
  final int? customCholesterolPercentage;
  final int? customOverallRiskScore;
  final RiskLevel? customOverallRisk;
  final DateTime? completedAt;

  const AssessmentResult({
    required this.fattyLiverScore,
    required this.fattyLiverMaxScore,
    required this.cholesterolScore,
    required this.cholesterolMaxScore,
    required this.fattyLiverRisk,
    required this.cholesterolRisk,
    this.customFattyLiverPercentage,
    this.customCholesterolPercentage,
    this.customOverallRiskScore,
    this.customOverallRisk,
    this.completedAt,
  });

  int get fattyLiverPercentage {
    if (customFattyLiverPercentage != null) {
      return customFattyLiverPercentage!;
    }
    if (fattyLiverMaxScore <= 0) return 0;
    return ((fattyLiverScore / fattyLiverMaxScore) * 100).round();
  }

  int get cholesterolPercentage {
    if (customCholesterolPercentage != null) {
      return customCholesterolPercentage!;
    }
    if (cholesterolMaxScore <= 0) return 0;
    return ((cholesterolScore / cholesterolMaxScore) * 100).round();
  }

  int get overallPercentage {
    if (customOverallRiskScore != null) {
      return customOverallRiskScore!;
    }
    return ((fattyLiverPercentage + cholesterolPercentage) / 2).round();
  }

  RiskLevel get overallRisk {
    if (customOverallRisk != null) {
      return customOverallRisk!;
    }
    final score = overallPercentage;
    if (score < 34) {
      return RiskLevel.low;
    } else if (score < 67) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.high;
    }
  }

  factory AssessmentResult.fromMap(Map<String, dynamic> map) {
    final fattyScore = (map['fattyLiverScore'] as num?)?.toInt() ?? 0;
    final fattyMax = (map['fattyLiverMaxScore'] as num?)?.toInt() ?? 0;
    final chScore = (map['cholesterolScore'] as num?)?.toInt() ?? 0;
    final chMax = (map['cholesterolMaxScore'] as num?)?.toInt() ?? 0;

    final fattyRisk = RiskLevel.fromString(map['fattyLiverRisk'] as String?);
    final chRisk = RiskLevel.fromString(map['cholesterolRisk'] as String?);

    int? overallScore = (map['overallScore'] as num?)?.toInt() ??
        (map['overallRiskScore'] as num?)?.toInt() ??
        (map['overallPercentage'] as num?)?.toInt();

    RiskLevel? overallRisk = map['overallRisk'] != null
        ? RiskLevel.fromString(map['overallRisk'] as String?)
        : null;

    DateTime? completedAt;
    if (map['completedAt'] != null) {
      final dynamic ts = map['completedAt'];
      if (ts is DateTime) {
        completedAt = ts;
      } else if (ts is String) {
        completedAt = DateTime.tryParse(ts);
      } else {
        try {
          completedAt = ts.toDate();
        } catch (_) {}
      }
    }

    return AssessmentResult(
      fattyLiverScore: fattyScore,
      fattyLiverMaxScore: fattyMax,
      cholesterolScore: chScore,
      cholesterolMaxScore: chMax,
      fattyLiverRisk: fattyRisk,
      cholesterolRisk: chRisk,
      customOverallRiskScore: overallScore,
      customOverallRisk: overallRisk,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fattyLiverScore': fattyLiverScore,
      'fattyLiverMaxScore': fattyLiverMaxScore,
      'fattyLiverRisk': fattyLiverRisk.name,
      'fattyLiverPercentage': fattyLiverPercentage,
      'cholesterolScore': cholesterolScore,
      'cholesterolMaxScore': cholesterolMaxScore,
      'cholesterolRisk': cholesterolRisk.name,
      'cholesterolPercentage': cholesterolPercentage,
      'overallRiskScore': overallPercentage,
      'overallRisk': overallRisk.name,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
