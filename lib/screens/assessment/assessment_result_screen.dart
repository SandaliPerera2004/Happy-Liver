import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/risk_level.dart';
import '../../services/assessment_firestore_service.dart';
import '../../services/personalized_recommendation_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../dashboard/daily%20routine/daily_routine_screen.dart';
import '../dashboard/profile_screen.dart';
import '../settings/settings.dart';
import 'recommendations_screen.dart';

/// Compatibility alias
class AssessmentResults extends StatelessWidget {
  const AssessmentResults({super.key});

  @override
  Widget build(BuildContext context) {
    return const AssessmentResultScreen();
  }
}

/// Compatibility alias
class AssessmentResultPage extends StatelessWidget {
  final bool isHome;

  const AssessmentResultPage({super.key, this.isHome = true});

  @override
  Widget build(BuildContext context) {
    return AssessmentResultScreen(isHome: isHome);
  }
}

class AssessmentResultScreen extends StatefulWidget {
  final RiskLevel? fattyLiverRisk;
  final RiskLevel? cholesterolRisk;
  final int fattyLiverScore;
  final int cholesterolScore;
  final int? overallRisk;
  final bool isHome;

  const AssessmentResultScreen({
    super.key,
    this.fattyLiverRisk,
    this.cholesterolRisk,
    this.fattyLiverScore = 0,
    this.cholesterolScore = 0,
    this.overallRisk,
    this.isHome = true,
  });

  static const Color pageBg = Color(0xFFF5FAF6);
  static const Color darkGreen = Color(0xFF146B0B);
  static const Color green = Color(0xFF23943A);
  static const Color paleGreen = Color(0xFFEAF7E7);
  static const Color orange = Color(0xFFE65100);
  static const Color textDark = Color(0xFF18321F);
  static const Color mutedText = Color(0xFF5A665D);

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  String _username = '';
  late int _fattyLiverScore;
  late int _cholesterolScore;

  static int _toPercentage(int score, RiskLevel? riskLevel) {
    if (score <= 25 && riskLevel != null && score > 0) {
      return ((score / 25) * 100).round().clamp(0, 100);
    }
    return score.clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _fattyLiverScore = _toPercentage(widget.fattyLiverScore, widget.fattyLiverRisk);
    _cholesterolScore = _toPercentage(widget.cholesterolScore, widget.cholesterolRisk);
    _fetchUsername();
    _fetchLatestAssessment();
  }

  @override
  void didUpdateWidget(covariant AssessmentResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fattyLiverScore != widget.fattyLiverScore ||
        oldWidget.cholesterolScore != widget.cholesterolScore) {
      setState(() {
        _fattyLiverScore = _toPercentage(widget.fattyLiverScore, widget.fattyLiverRisk);
        _cholesterolScore = _toPercentage(widget.cholesterolScore, widget.cholesterolRisk);
      });
    }
  }

  Future<void> _fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final name = data['username'] as String?;
          if (name != null && name.trim().isNotEmpty) {
            if (mounted) {
              setState(() {
                _username = name.trim();
              });
            }
            return;
          }
        }

        if (mounted) {
          setState(() {
            _username = user.displayName ?? 'User';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _username = 'User';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _username = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
        });
      }
    }
  }

  Future<void> _fetchLatestAssessment() async {
    try {
      final doc = await AssessmentFirestoreService.getLatestAssessment();
      if (doc != null && doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final flScore = (data['fattyLiverScore'] as num?)?.toInt();
        final chScore = (data['cholesterolScore'] as num?)?.toInt();
        final flMax = (data['fattyLiverMaxScore'] as num?)?.toInt();
        final chMax = (data['cholesterolMaxScore'] as num?)?.toInt();

        int? finalFl = flScore;
        if (flScore != null && flMax != null && flMax > 0 && flScore <= flMax) {
          finalFl = ((flScore / flMax) * 100).round();
        }

        int? finalCh = chScore;
        if (chScore != null && chMax != null && chMax > 0 && chScore <= chMax) {
          finalCh = ((chScore / chMax) * 100).round();
        }

        if (mounted) {
          setState(() {
            if (finalFl != null) _fattyLiverScore = finalFl;
            if (finalCh != null) _cholesterolScore = finalCh;
          });
        }
      }
    } catch (_) {
      // Keep existing scores if Firestore fetch fails
    }
  }

  String get fattyLiverStatus {
    if (widget.fattyLiverRisk != null) {
      switch (widget.fattyLiverRisk!) {
        case RiskLevel.low:
          return 'Low';
        case RiskLevel.moderate:
          return 'Moderate';
        case RiskLevel.high:
          return 'High';
      }
    }
    if (_fattyLiverScore < 35) return 'Low';
    if (_fattyLiverScore < 70) return 'Moderate';
    return 'High';
  }

  String get cholesterolStatus {
    if (widget.cholesterolRisk != null) {
      switch (widget.cholesterolRisk!) {
        case RiskLevel.low:
          return 'Low';
        case RiskLevel.moderate:
          return 'Moderate';
        case RiskLevel.high:
          return 'High';
      }
    }
    if (_cholesterolScore < 35) return 'Low';
    if (_cholesterolScore < 70) return 'Moderate';
    return 'High';
  }

  int get displayOverallRisk {
    if (widget.overallRisk != null) return widget.overallRisk!.clamp(0, 100);
    return ((_fattyLiverScore + _cholesterolScore) / 2)
        .round()
        .clamp(0, 100);
  }

  String get overallRiskStatus {
    final score = displayOverallRisk;
    if (score < 35) return 'Low Risk';
    if (score < 70) return 'Moderate Risk';
    return 'High Risk';
  }

  Color get overallRiskStatusColor {
    final score = displayOverallRisk;
    if (score < 35) return AssessmentResultScreen.green;
    if (score < 70) return AssessmentResultScreen.orange;
    return const Color(0xFFD84315);
  }

  List<Color> _getGradient(String status) {
    switch (status) {
      case 'Low':
        return const [Color(0xFF66BB6A), Color(0xFF2E7D32)];
      case 'Moderate':
        return const [Color(0xFFFF9800), Color(0xFFE65100)];
      case 'High':
      default:
        return const [Color(0xFFEF5350), Color(0xFFC62828)];
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Low':
        return const Color(0xFF2E7D32);
      case 'Moderate':
        return const Color(0xFFE65100);
      case 'High':
      default:
        return const Color(0xFFC62828);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Low':
        return const Color(0xFFE8F5E9);
      case 'Moderate':
        return const Color(0xFFFFF3E0);
      case 'High':
      default:
        return const Color(0xFFFFEBEE);
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) return; // Already on Home (AssessmentResultScreen)

    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DailyRoutineScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flStatus = fattyLiverStatus;
    final chStatus = cholesterolStatus;
    final flScore = _fattyLiverScore;
    final chScore = _cholesterolScore;

    return Scaffold(
      backgroundColor: AssessmentResultScreen.pageBg,
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
                            score: flScore,
                            status: flStatus,
                            description:
                                'your fatty liver risk score is on $flStatus.',
                            gradientColors: _getGradient(flStatus),
                            statusColor: _getStatusColor(flStatus),
                            statusBgColor: _getStatusBgColor(flStatus),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DonutRiskTile(
                            title: 'CHOLESTEROL RISK',
                            score: chScore,
                            status: chStatus,
                            description:
                                'Your cholesterol risk score is on $chStatus.',
                            gradientColors: _getGradient(chStatus),
                            statusColor: _getStatusColor(chStatus),
                            statusBgColor: _getStatusBgColor(chStatus),
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE5F8D8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          Text(
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
    final displayName = _username.isNotEmpty ? _username : 'User';

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
                  'Great job $displayName! 🎉',
                  style: const TextStyle(
                    color: AssessmentResultScreen.darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  "You've completed your Happy Liver health assessment.",
                  style: TextStyle(
                    color: AssessmentResultScreen.mutedText,
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
                  color: AssessmentResultScreen.darkGreen,
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
    final score = displayOverallRisk;
    final statusText = overallRiskStatus;
    final statusColor = overallRiskStatusColor;

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
                color: AssessmentResultScreen.darkGreen,
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
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 35),
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: AssessmentResultScreen.textDark,
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Keep going! Lifestyle choices',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AssessmentResultScreen.mutedText,
                      fontSize: 12.5,
                    ),
                  ),
                  const Text(
                    'make a big impact.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AssessmentResultScreen.mutedText,
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
    final flStatus = fattyLiverStatus;
    final chStatus = cholesterolStatus;
    final overallStatus = overallRiskStatus;
    final overallScore = displayOverallRisk;

    final insight = PersonalizedRecommendationService.getOverallInsight(
      fattyLiverStatus: flStatus,
      cholesterolStatus: chStatus,
      overallRiskStatus: overallStatus,
      fattyLiverScore: _fattyLiverScore,
      cholesterolScore: _cholesterolScore,
      overallScore: overallScore,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: insight.badgeBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  insight.icon,
                  size: 20,
                  color: insight.badgeColor,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'OVERALL INSIGHT',
                  style: TextStyle(
                    color: AssessmentResultScreen.darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: insight.badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: insight.badgeColor.withAlpha(60),
                  ),
                ),
                child: Text(
                  insight.badgeText,
                  style: TextStyle(
                    color: insight.badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight.title,
            style: const TextStyle(
              color: AssessmentResultScreen.textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            insight.message,
            style: const TextStyle(
              color: AssessmentResultScreen.mutedText,
              fontSize: 12.5,
              height: 1.45,
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
              builder: (context) => RecommendationsScreen(
                fattyLiverScore: _fattyLiverScore,
                cholesterolScore: _cholesterolScore,
                fattyLiverStatus: fattyLiverStatus,
                cholesterolStatus: cholesterolStatus,
                overallRiskScore: displayOverallRisk,
                overallRiskStatus: overallRiskStatus,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AssessmentResultScreen.darkGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AssessmentResultScreen.darkGreen.withAlpha(76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'See Personalized Recommendation',
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
              color: AssessmentResultScreen.darkGreen,
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
                            color: AssessmentResultScreen.textDark,
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
                      border: Border.all(
                        color: statusColor.withAlpha(50),
                        width: 1.5,
                      ),
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
              color: AssessmentResultScreen.mutedText,
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
      Paint()..color = Colors.white,
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