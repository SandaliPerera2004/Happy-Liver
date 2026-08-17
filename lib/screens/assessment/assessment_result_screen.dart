import 'package:flutter/material.dart';

import '../../models/risk_level.dart';

class AssessmentResultScreen extends StatelessWidget {
  final RiskLevel fattyLiverRisk;
  final RiskLevel cholesterolRisk;
  final int fattyLiverScore;
  final int cholesterolScore;

  const AssessmentResultScreen({
    super.key,
    required this.fattyLiverRisk,
    required this.cholesterolRisk,
    required this.fattyLiverScore,
    required this.cholesterolScore,
  });

  String _riskText(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Low Risk';

      case RiskLevel.moderate:
        return 'Moderate Risk';

      case RiskLevel.high:
        return 'High Risk';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Text(
                  'Your Assessment Result',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                _resultCard(
                  title: 'Fatty Liver Risk',
                  score: '$fattyLiverScore',
                  risk: _riskText(fattyLiverRisk),
                ),

                const SizedBox(height: 20),

                _resultCard(
                  title: 'Cholesterol Risk',
                  score: '$cholesterolScore',
                  risk: _riskText(cholesterolRisk),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultCard({
    required String title,
    required String score,
    required String risk,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFFE0F3D7),
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            risk,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C5A3C),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Score: $score',
          ),
        ],
      ),
    );
  }
}