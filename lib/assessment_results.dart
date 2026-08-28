import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'recommendations.dart';

/// Compatibility wrapper for navigation
class AssessmentResults extends StatelessWidget {
  const AssessmentResults({super.key});

  @override
  Widget build(BuildContext context) {
    return const AssessmentResultPage();
  }
}

class AssessmentResultPage extends StatelessWidget {
  final bool isHome;

  const AssessmentResultPage({super.key, this.isHome = true});

  // Risk scores calculated from the assessment questions
  static const int overallRisk = 70;
  static const int fattyLiverRisk = 65;
  static const int cholesterolRisk = 25;

  static const Color pageBg = Color(0xFFF5FAF6);
  static const Color darkGreen = Color(0xFF146B0B);
  static const Color green = Color(0xFF23943A);
  static const Color paleGreen = Color(0xFFEAF7E7);
  static const Color orange = Color(0xFFE65100);
  static const Color textDark = Color(0xFF18321F);
  static const Color mutedText = Color(0xFF5A665D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header area is ONLY colored below phone notification area
            Container(
              color: const Color(0xFFE5F8D8),
              child: _buildAppBar(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    _buildGreeting(),
                    const SizedBox(height: 15),

                    // Main overall result gauge with vibrant gradient arc
                    _buildOverallRisk(),
                    const SizedBox(height: 10),
                    // Side-by-side Fatty Liver Risk & Cholesterol Risk Cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _DonutRiskTile(
                            title: 'FATTY LIVER RISK',
                            score: fattyLiverRisk,
                            status: 'Moderate',
                            description:
                                'your fatty liver risk score is on Moderate.',
                            gradientColors: const [
                              Color(0xFFFF9800),
                              Color(0xFFE65100),
                            ],
                            statusColor: const Color(0xFFE65100),
                            statusBgColor: const Color(0xFFFFF3E0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DonutRiskTile(
                            title: 'CHOLESTEROL RISK',
                            score: cholesterolRisk,
                            status: 'Low',
                            description:
                                'Your cholesterol risk score is on Low.',
                            gradientColors: const [
                              Color(0xFF66BB6A),
                              Color(0xFF2E7D32),
                            ],
                            statusColor: const Color(0xFF2E7D32),
                            statusBgColor: const Color(0xFFE8F5E9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Overall insight card
                    _buildInsightCard(),
                    const SizedBox(height: 15),
                    // Navigation to personalized plan
                    _buildPersonalizedPlanButton(context),
                    const SizedBox(height: 15),
                    _buildDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    return Container(
      color: const Color(0xFFE5F8D8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text(
            "Assessment Results",
            style: TextStyle(
              color: Color(0xFF18321F),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFCFF7D3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4EBD1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great job Shehani! 🎉',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "You've completed your Happy Liver health assessment.",
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/liver.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.favorite_rounded,
                  color: darkGreen,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRisk() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDCEFD9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'OVERALL RISK',
              style: TextStyle(
                color: darkGreen,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _GradientGaugePainter(
                score: overallRisk,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  SizedBox(height: 35),
                  Text(
                    '$overallRisk%',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Moderate Risk',
                    style: TextStyle(
                      color: orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Keep going! Lifestyle choices',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    'make a big impact.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDCEFD9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(9),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL INSIGHT',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Focus on improving your lifestyle to reduce fatty liver risk and maintain low cholesterol !',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedPlanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecommendationsScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: darkGreen.withAlpha(76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'See Personalized Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      'This assessment evaluates general liver health habits and is for informational purposes only. This is not professional medical diagnosis.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black.withAlpha(107),
        fontSize: 11,
        height: 1.3,
      ),
    );
  }
}

// ============================================================
// DONUT RISK TILE WITH FLOATING FORWARD BADGE OVERLAY
// ============================================================
class _DonutRiskTile extends StatelessWidget {
  final String title;
  final int score;
  final String status;
  final String description;
  final List<Color> gradientColors;
  final Color statusColor;
  final Color statusBgColor;

  const _DonutRiskTile({
    required this.title,
    required this.score,
    required this.status,
    required this.description,
    required this.gradientColors,
    required this.statusColor,
    required this.statusBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2EDE3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AssessmentResultPage.darkGreen,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 5),

          // Donut Gauge Stack with Forward Floating Modern Status Badge at the bottom
          SizedBox(
            height: 124,
            width: 115,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Gradient Donut Painter
                Positioned(
                  top: 0,
                  left: 7.5,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: _GradientDonutPainter(
                        score: score,
                        gradientColors: gradientColors,
                      ),
                      child: Center(
                        child: Text(
                          '$score%',
                          style: const TextStyle(
                            color: AssessmentResultPage.textDark,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating Status Pill Overlay positioned at bottom in front (forward z-index)
                Positioned(
                  bottom: 23,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withAlpha(50), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withAlpha(40),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AssessmentResultPage.mutedText,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GRADIENT OVERALL GAUGE PAINTER
// ============================================================
class _GradientGaugePainter extends CustomPainter {
  final int score;

  const _GradientGaugePainter({
    required this.score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height - 25,
    );

    final radius = math.min(
      size.width * .35,
      size.height * .80,
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    // Background track
    final background = Paint()
      ..color = const Color(0xFFE4F3DD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      background,
    );

    // Gradient Risk Arc Progress
    const gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: math.pi * 2,
      colors: [
        Color(0xFFFFB74D), // Soft Orange
        Color(0xFFF57C00), // Deep Orange
        Color(0xFFD84315), // Red-Orange Accent
      ],
    );

    final progress = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi * (score / 100),
      false,
      progress,
    );

    // Indicator dot
    final angle = math.pi + math.pi * (score / 100);

    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    canvas.drawCircle(
      point,
      7,
      Paint()
        ..color = Colors.white,
    );
    canvas.drawCircle(
      point,
      4,
      Paint()..color = const Color(0xFFF19049),
    );
  }

  @override
  bool shouldRepaint(covariant _GradientGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

// ============================================================
// GRADIENT DONUT PAINTER
// ============================================================
class _GradientDonutPainter extends CustomPainter {
  final int score;
  final List<Color> gradientColors;

  const _GradientDonutPainter({
    required this.score,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 8;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    // 7 o'clock = 120 degrees (2 * pi / 3), 5 o'clock = 60 degrees (via 300 degree sweep)
    const startAngle = 2 * math.pi / 3;
    const totalSweep = 5 * math.pi / 3;

    // Background track
    final background = Paint()
      ..color = gradientColors.first.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      totalSweep,
      false,
      background,
    );

    // Gradient Progress Arc
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + totalSweep,
      colors: gradientColors,
    );

    final progress = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      totalSweep * (score / 100),
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientDonutPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
