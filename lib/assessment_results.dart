import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'models/risk_level.dart';
import 'assessment_firestore_service.dart';
import 'recommendations.dart';

/// Compatibility wrapper for navigation
class AssessmentResults extends StatelessWidget {
  final AssessmentResult? result;

  const AssessmentResults({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    return AssessmentResultPage(initialResult: result);
  }
}

class AssessmentResultPage extends StatefulWidget {
  final bool isHome;
  final AssessmentResult? initialResult;

  const AssessmentResultPage({
    super.key,
    this.isHome = true,
    this.initialResult,
  });

  // Color constants matching the design system
  static const Color pageBg = Color(0xFFF5FAF6);
  static const Color darkGreen = Color(0xFF146B0B);
  static const Color green = Color(0xFF23943A);
  static const Color paleGreen = Color(0xFFEAF7E7);
  static const Color orange = Color(0xFFE65100);
  static const Color red = Color(0xFFC62828);
  static const Color textDark = Color(0xFF18321F);
  static const Color mutedText = Color(0xFF5A665D);

  @override
  State<AssessmentResultPage> createState() => _AssessmentResultPageState();
}

class _AssessmentResultPageState extends State<AssessmentResultPage> {
  AssessmentResult? _result;
  String _userName = 'Shehani';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialResult != null) {
      _result = widget.initialResult;
      _isLoading = false;
      _loadUserNameOnly();
    } else {
      _loadAssessmentData();
    }
  }

  Future<void> _loadUserNameOnly() async {
    final name = await AssessmentFirestoreService.getUserDisplayName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadAssessmentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = await AssessmentFirestoreService.getUserDisplayName();
      final result = await AssessmentFirestoreService.getLatestAssessment();

      if (mounted) {
        setState(() {
          _userName = name;
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to connect to assessment service.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentResultPage.pageBg,
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
              child: _isLoading
                  ? _buildLoadingState()
                  : RefreshIndicator(
                      color: AssessmentResultPage.darkGreen,
                      backgroundColor: Colors.white,
                      onRefresh: _loadAssessmentData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                        child: Column(
                          children: [
                            if (_errorMessage != null) _buildErrorBanner(),
                            const SizedBox(height: 5),
                            _buildGreeting(),
                            const SizedBox(height: 15),

                            // Main overall result gauge with dynamic gradient arc
                            _buildOverallRisk(),
                            const SizedBox(height: 10),

                            // Side-by-side Fatty Liver Risk & Cholesterol Risk Cards
                            _buildRiskCardsRow(),
                            const SizedBox(height: 10),

                            // Overall insight card dynamically generated from backend result
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AssessmentResultPage.darkGreen),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your health assessment...',
            style: TextStyle(
              color: AssessmentResultPage.mutedText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFFE5F8D8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Assessment Results",
            style: TextStyle(
              color: Color(0xFF18321F),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AssessmentResultPage.darkGreen,
            ),
            tooltip: 'Refresh Results',
            onPressed: _loadAssessmentData,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEEBA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(
                color: Color(0xFF856404),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF856404)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great job $_userName! 🎉',
                  style: const TextStyle(
                    color: AssessmentResultPage.darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  "You've completed your Happy Liver health assessment.",
                  style: TextStyle(
                    color: AssessmentResultPage.mutedText,
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
                  color: AssessmentResultPage.darkGreen,
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
    final res = _result;
    final int score = res?.overallPercentage ?? 70;
    final RiskLevel risk = res?.overallRisk ?? RiskLevel.moderate;

    String riskTitle = 'Moderate Risk';
    Color riskColor = AssessmentResultPage.orange;
    List<Color> gradientColors = const [
      Color(0xFFFFB74D), // Soft Orange
      Color(0xFFF57C00), // Deep Orange
      Color(0xFFD84315), // Red-Orange Accent
    ];
    String subtext1 = 'Keep going! Lifestyle choices';
    String subtext2 = 'make a big impact.';

    if (risk == RiskLevel.low) {
      riskTitle = 'Low Risk';
      riskColor = AssessmentResultPage.green;
      gradientColors = const [
        Color(0xFF81C784),
        Color(0xFF388E3C),
        Color(0xFF1B5E20),
      ];
      subtext1 = 'Great work! Your liver habits';
      subtext2 = 'are on a healthy track.';
    } else if (risk == RiskLevel.high) {
      riskTitle = 'High Risk';
      riskColor = AssessmentResultPage.red;
      gradientColors = const [
        Color(0xFFEF9A9A),
        Color(0xFFE53935),
        Color(0xFFB71C1C),
      ];
      subtext1 = 'Action advised! Lifestyle & medical';
      subtext2 = 'support are recommended.';
    }

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
                color: AssessmentResultPage.darkGreen,
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
                score: score,
                gradientColors: gradientColors,
                indicatorColor: riskColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 35),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: AssessmentResultPage.textDark,
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    riskTitle,
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtext1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AssessmentResultPage.mutedText,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    subtext2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AssessmentResultPage.mutedText,
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

  Widget _buildRiskCardsRow() {
    final res = _result;

    final int flScore = res?.fattyLiverPercentage ?? 65;
    final RiskLevel flRisk = res?.fattyLiverRisk ?? RiskLevel.moderate;

    final int chScore = res?.cholesterolPercentage ?? 25;
    final RiskLevel chRisk = res?.cholesterolRisk ?? RiskLevel.low;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DonutRiskTile(
            title: 'FATTY LIVER RISK',
            score: flScore,
            status: flRisk.displayName,
            description: 'Your fatty liver risk score is on ${flRisk.displayName}.',
            gradientColors: _getRiskGradients(flRisk),
            statusColor: _getRiskStatusColor(flRisk),
            statusBgColor: _getRiskBgColor(flRisk),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DonutRiskTile(
            title: 'CHOLESTEROL RISK',
            score: chScore,
            status: chRisk.displayName,
            description: 'Your cholesterol risk score is on ${chRisk.displayName}.',
            gradientColors: _getRiskGradients(chRisk),
            statusColor: _getRiskStatusColor(chRisk),
            statusBgColor: _getRiskBgColor(chRisk),
          ),
        ),
      ],
    );
  }

  List<Color> _getRiskGradients(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return const [Color(0xFF66BB6A), Color(0xFF2E7D32)];
      case RiskLevel.moderate:
        return const [Color(0xFFFF9800), Color(0xFFE65100)];
      case RiskLevel.high:
        return const [Color(0xFFEF5350), Color(0xFFC62828)];
    }
  }

  Color _getRiskStatusColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return const Color(0xFF2E7D32);
      case RiskLevel.moderate:
        return const Color(0xFFE65100);
      case RiskLevel.high:
        return const Color(0xFFC62828);
    }
  }

  Color _getRiskBgColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return const Color(0xFFE8F5E9);
      case RiskLevel.moderate:
        return const Color(0xFFFFF3E0);
      case RiskLevel.high:
        return const Color(0xFFFFEBEE);
    }
  }

  Widget _buildInsightCard() {
    final String insightText = _result != null
        ? AssessmentFirestoreService.generateInsight(_result!)
        : 'Focus on improving your lifestyle to reduce fatty liver risk and maintain low cholesterol!';

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
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OVERALL INSIGHT',
                  style: TextStyle(
                    color: AssessmentResultPage.darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insightText,
                  style: const TextStyle(
                    color: AssessmentResultPage.mutedText,
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
              builder: (context) => RecommendationsScreen(result: _result),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AssessmentResultPage.darkGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AssessmentResultPage.darkGreen.withAlpha(76),
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
  final List<Color> gradientColors;
  final Color indicatorColor;

  const _GradientGaugePainter({
    required this.score,
    this.gradientColors = const [
      Color(0xFFFFB74D), // Soft Orange
      Color(0xFFF57C00), // Deep Orange
      Color(0xFFD84315), // Red-Orange Accent
    ],
    this.indicatorColor = const Color(0xFFF19049),
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
    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: math.pi * 2,
      colors: gradientColors,
    );

    final progress = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final progressSweep = math.pi * (score.clamp(0, 100) / 100);

    canvas.drawArc(
      rect,
      math.pi,
      progressSweep,
      false,
      progress,
    );

    // Indicator dot
    final angle = math.pi + progressSweep;

    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    canvas.drawCircle(
      point,
      7,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      point,
      4,
      Paint()..color = indicatorColor,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientGaugePainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.indicatorColor != indicatorColor;
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

    final progressSweep = totalSweep * (score.clamp(0, 100) / 100);

    canvas.drawArc(
      rect,
      startAngle,
      progressSweep,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientDonutPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.gradientColors != gradientColors;
  }
}
