enum RiskLevel {
  low,
  moderate,
  high,
}

class AssessmentResult {
  final int fattyLiverScore;
  final int fattyLiverMaxScore;
  final int cholesterolScore;
  final int cholesterolMaxScore;

  final RiskLevel fattyLiverRisk;
  final RiskLevel cholesterolRisk;

  const AssessmentResult({
    required this.fattyLiverScore,
    required this.fattyLiverMaxScore,
    required this.cholesterolScore,
    required this.cholesterolMaxScore,
    required this.fattyLiverRisk,
    required this.cholesterolRisk,
  });
}