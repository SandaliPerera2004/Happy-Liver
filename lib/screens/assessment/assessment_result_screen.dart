import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/risk_level.dart';
import '../../services/assessment_firestore_service.dart';
import 'package:happy_liver/widgets/custom_header.dart';
import 'package:happy_liver/widgets/bottom_navigation_bar.dart';
import '../recommendations/recommendations_screen.dart';

class AssessmentResultScreen extends StatelessWidget {
  final AssessmentResult result;
  final bool isDarkMode;
  final Future<void> Function(bool) onThemeChanged;

  const AssessmentResultScreen({
    super.key,
    required this.result,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  // ============================================================
  // LIGHT MODE COLORS
  // ============================================================

  static const Color pageBg = Color(0xFFF5FAF6);
  static const Color darkGreen = Color(0xFF146B0B);
  static const Color green = Color(0xFF23943A);
  static const Color paleGreen = Color(0xFFEAF7E7);
  static const Color orange = Color(0xFFE65100);
  static const Color red = Color(0xFFC62828);
  static const Color textDark = Color(0xFF18321F);
  static const Color mutedText = Color(0xFF5A665D);

  // ============================================================
  // DARK MODE COLORS
  // ============================================================

  static const Color darkPageBg = Color(0xFF0F1712);
  static const Color darkCard = Color(0xFF18231C);
  static const Color darkCardSecondary = Color(0xFF1E2C23);
  static const Color darkBorder = Color(0xFF2D3B31);
  static const Color darkText = Color(0xFFF1F7F2);
  static const Color darkMutedText = Color(0xFFB7C4BA);
  static const Color darkPaleGreen = Color(0xFF1D3424);
  static const Color darkGreeting = Color(0xFF183222);
  static const Color darkAnswerBg = Color(0xFF1E2C23);
  static const Color darkGaugeTrack = Color(0xFF334137);

  // ============================================================
  // DYNAMIC COLORS
  // ============================================================

  Color get backgroundColor =>
      isDarkMode ? darkPageBg : pageBg;

  Color get cardColor =>
      isDarkMode ? darkCard : Colors.white;

  Color get secondaryCardColor =>
      isDarkMode ? darkCardSecondary : Colors.white;

  Color get primaryTextColor =>
      isDarkMode ? darkText : textDark;

  Color get secondaryTextColor =>
      isDarkMode ? darkMutedText : mutedText;

  Color get borderColor =>
      isDarkMode ? darkBorder : const Color(0xFFDCEFD9);

  Color get softGreenColor =>
      isDarkMode ? darkPaleGreen : paleGreen;

  Color get greetingColor =>
      isDarkMode ? darkGreeting : const Color(0xFFCFF7D3);

  Color get answerBackgroundColor =>
      isDarkMode ? darkAnswerBg : const Color(0xFFF1FAF0);

  Color get gaugeTrackColor =>
      isDarkMode ? darkGaugeTrack : const Color(0xFFE4F3DD);

  // ============================================================
  // RISK HELPERS
  // ============================================================

  String _riskName(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return 'Low Risk';

      case RiskLevel.moderate:
        return 'Moderate Risk';

      case RiskLevel.high:
        return 'High Risk';
    }
  }

  Color _riskColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return green;

      case RiskLevel.moderate:
        return orange;

      case RiskLevel.high:
        return red;
    }
  }

  Color _riskBackground(RiskLevel risk) {
    if (isDarkMode) {
      switch (risk) {
        case RiskLevel.low:
          return const Color(0xFF193523);

        case RiskLevel.moderate:
          return const Color(0xFF3A2A18);

        case RiskLevel.high:
          return const Color(0xFF3A2023);
      }
    }

    switch (risk) {
      case RiskLevel.low:
        return const Color(0xFFE8F5E9);

      case RiskLevel.moderate:
        return const Color(0xFFFFF3E0);

      case RiskLevel.high:
        return const Color(0xFFFFEBEE);
    }
  }

  List<Color> _riskGradient(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return const [
          Color(0xFF66BB6A),
          Color(0xFF2E7D32),
        ];

      case RiskLevel.moderate:
        return const [
          Color(0xFFFF9800),
          Color(0xFFE65100),
        ];

      case RiskLevel.high:
        return const [
          Color(0xFFEF5350),
          Color(0xFFC62828),
        ];
    }
  }

  // ============================================================
  // SCORE TO PERCENTAGE
  // ============================================================

  int _percentage(int score, int maxScore) {
    if (maxScore <= 0) {
      return 0;
    }

    return ((score / maxScore) * 100).clamp(0, 100).round();
  }

  // ============================================================
  // OVERALL PERCENTAGE
  // ============================================================

  int _overallPercentage() {
    final fattyPercentage = _percentage(
      result.fattyLiverScore,
      result.fattyLiverMaxScore,
    );

    final cholesterolPercentage = _percentage(
      result.cholesterolScore,
      result.cholesterolMaxScore,
    );

    return ((fattyPercentage + cholesterolPercentage) / 2).round();
  }

  // ============================================================
  // OVERALL RISK
  // ============================================================

  RiskLevel _overallRisk() {
    final fattyRisk = result.fattyLiverRisk;
    final cholesterolRisk = result.cholesterolRisk;

    if (fattyRisk == RiskLevel.high ||
        cholesterolRisk == RiskLevel.high) {
      return RiskLevel.high;
    }

    if (fattyRisk == RiskLevel.moderate ||
        cholesterolRisk == RiskLevel.moderate) {
      return RiskLevel.moderate;
    }

    return RiskLevel.low;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final overallPercentage = _overallPercentage();
    final overallRisk = _overallRisk();

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // CUSTOM HEADER
      // ========================================================

      appBar: const CustomHeader(
        title: 'Assessment Results',
        showBack: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 2),

              // Greeting
              _buildGreeting(),

              const SizedBox(height: 12),

              // Overall Risk
              _buildOverallRisk(
                overallPercentage,
                overallRisk,
              ),

              const SizedBox(height: 10),

              // Fatty Liver + Cholesterol
              _buildRiskCardsRow(),

              const SizedBox(height: 10),

              // Overall Insight
              _buildInsightCard(),

              const SizedBox(height: 14),

              // View Last Assessment
              _buildHistoryButton(context),

              const SizedBox(height: 12),

              // Recommendations
              _buildRecommendationsButton(context),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: HappyLiverBottomNavBar(
        selectedIndex: 0,
        isDarkMode: isDarkMode,
        onThemeChanged: onThemeChanged,
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        10,
      ),
      decoration: BoxDecoration(
        color: greetingColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? darkBorder
              : const Color(0xFFD4EBD1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great job! 🎉',
                  style: TextStyle(
                    color: isDarkMode
                        ? const Color(0xFF72D66F)
                        : darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "You've completed your Happy Liver health assessment.",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 3),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF22362A)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/liver.png',
                fit: BoxFit.contain,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Icon(
                    Icons.favorite_rounded,
                    color: isDarkMode
                        ? const Color(0xFF72D66F)
                        : darkGreen,
                    size: 36,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERALL RISK
  // ============================================================

  Widget _buildOverallRisk(
      int score,
      RiskLevel risk,
      ) {
    String subtext1;
    String subtext2;

    switch (risk) {
      case RiskLevel.low:
        subtext1 = 'Great work! Your liver habits';
        subtext2 = 'are on a healthy track.';
        break;

      case RiskLevel.moderate:
        subtext1 = 'Keep going! Lifestyle choices';
        subtext2 = 'make a big impact.';
        break;

      case RiskLevel.high:
        subtext1 = 'Action advised! Lifestyle & medical';
        subtext2 = 'support are recommended.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        15,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              isDarkMode ? 35 : 10,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'OVERALL RISK',
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF72D66F)
                    : darkGreen,
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
                gradientColors: _riskGradient(risk),
                indicatorColor: _riskColor(risk),
                trackColor: gaugeTrackColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 30),

                  Text(
                    '$score%',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 1),

                  Text(
                    _riskName(risk),
                    style: TextStyle(
                      color: _riskColor(risk),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtext1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12.5,
                    ),
                  ),

                  Text(
                    subtext2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryTextColor,
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

  // ============================================================
  // RISK CARDS
  // ============================================================

  Widget _buildRiskCardsRow() {
    final fattyScore = _percentage(
      result.fattyLiverScore,
      result.fattyLiverMaxScore,
    );

    final cholesterolScore = _percentage(
      result.cholesterolScore,
      result.cholesterolMaxScore,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DonutRiskTile(
            title: 'FATTY LIVER RISK',
            score: fattyScore,
            status: _riskName(
              result.fattyLiverRisk,
            ),
            description:
            'Your fatty liver risk score is ${_riskName(result.fattyLiverRisk).toLowerCase()}.',
            gradientColors:
            _riskGradient(result.fattyLiverRisk),
            statusColor:
            _riskColor(result.fattyLiverRisk),
            statusBgColor:
            _riskBackground(result.fattyLiverRisk),
            isDarkMode: isDarkMode,
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: _DonutRiskTile(
            title: 'CHOLESTEROL RISK',
            score: cholesterolScore,
            status: _riskName(
              result.cholesterolRisk,
            ),
            description:
            'Your cholesterol risk score is ${_riskName(result.cholesterolRisk).toLowerCase()}.',
            gradientColors:
            _riskGradient(result.cholesterolRisk),
            statusColor:
            _riskColor(result.cholesterolRisk),
            statusBgColor:
            _riskBackground(result.cholesterolRisk),
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INSIGHT CARD
  // ============================================================

  Widget _buildInsightCard() {
    final fattyRisk = result.fattyLiverRisk;
    final cholesterolRisk = result.cholesterolRisk;

    String insight;

    if (fattyRisk == RiskLevel.low &&
        cholesterolRisk == RiskLevel.low) {
      insight =
      'Great work! Continue maintaining healthy lifestyle habits.';
    } else if (fattyRisk == RiskLevel.high ||
        cholesterolRisk == RiskLevel.high) {
      insight =
      'Paying attention to healthy lifestyle habits and discussing your results with a healthcare professional may be helpful.';
    } else {
      insight =
      'Improving your daily lifestyle and maintaining healthy eating and activity habits can help reduce your overall risk.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              isDarkMode ? 30 : 10,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: softGreenColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: isDarkMode
                  ? const Color(0xFF72D66F)
                  : darkGreen,
              size: 24,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL INSIGHT',
                  style: TextStyle(
                    color: isDarkMode
                        ? const Color(0xFF72D66F)
                        : darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  insight,
                  style: TextStyle(
                    color: secondaryTextColor,
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

  // ============================================================
  // VIEW LAST ASSESSMENT BUTTON
  // ============================================================

  Widget _buildHistoryButton(
      BuildContext context,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          _showLatestAssessmentDialog(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: isDarkMode
              ? const Color(0xFF72D66F)
              : darkGreen,
          side: BorderSide(
            color: isDarkMode
                ? const Color(0xFF72D66F)
                : darkGreen,
            width: 1.5,
          ),
          backgroundColor: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 22,
              color: isDarkMode
                  ? const Color(0xFF72D66F)
                  : darkGreen,
            ),
            const SizedBox(width: 8),
            Text(
              'View Last Assessment',
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF72D66F)
                    : darkGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECOMMENDATIONS BUTTON
  // ============================================================

  Widget _buildRecommendationsButton(
      BuildContext context,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RecommendationsScreen(
                    isDarkMode: isDarkMode,
                    onThemeChanged: onThemeChanged,
                  ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode
              ? const Color(0xFF23851A)
              : darkGreen,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: darkGreen.withAlpha(76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              'View Recommendations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHOW LATEST ASSESSMENT
  // ============================================================

  Future<void> _showLatestAssessmentDialog(
      BuildContext context,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _LatestAssessmentDialog(
          isDarkMode: isDarkMode,
        );
      },
    );
  }
}

// ============================================================
// LATEST ASSESSMENT DIALOG
// ============================================================

class _LatestAssessmentDialog
    extends StatefulWidget {
  final bool isDarkMode;

  const _LatestAssessmentDialog({
    required this.isDarkMode,
  });

  @override
  State<_LatestAssessmentDialog> createState() =>
      _LatestAssessmentDialogState();
}

class _LatestAssessmentDialogState
    extends State<_LatestAssessmentDialog> {
  late Future<
      DocumentSnapshot<Map<String, dynamic>>?>
  _assessmentFuture;

  // ============================================================
  // DYNAMIC COLORS
  // ============================================================

  Color get backgroundColor =>
      widget.isDarkMode
          ? AssessmentResultScreen.darkPageBg
          : AssessmentResultScreen.pageBg;

  Color get cardColor =>
      widget.isDarkMode
          ? AssessmentResultScreen.darkCard
          : Colors.white;

  Color get primaryTextColor =>
      widget.isDarkMode
          ? AssessmentResultScreen.darkText
          : AssessmentResultScreen.textDark;

  Color get secondaryTextColor =>
      widget.isDarkMode
          ? AssessmentResultScreen.darkMutedText
          : AssessmentResultScreen.mutedText;

  Color get borderColor =>
      widget.isDarkMode
          ? AssessmentResultScreen.darkBorder
          : const Color(0xFFDCEFD9);

  Color get softGreenColor =>
      widget.isDarkMode
          ? AssessmentResultScreen.darkPaleGreen
          : AssessmentResultScreen.paleGreen;

  @override
  void initState() {
    super.initState();

    _assessmentFuture =
        AssessmentFirestoreService
            .getLatestAssessment();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 680,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                widget.isDarkMode ? 70 : 35,
              ),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FutureBuilder<
            DocumentSnapshot<Map<String, dynamic>>?>(
          future: _assessmentFuture,
          builder: (context, snapshot) {
            // ==================================================
            // LOADING
            // ==================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(
                    color: widget.isDarkMode
                        ? const Color(0xFF72D66F)
                        : AssessmentResultScreen.darkGreen,
                  ),
                ),
              );
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (snapshot.hasError) {
              return _buildError();
            }

            final document = snapshot.data;

            // ==================================================
            // NO ASSESSMENT
            // ==================================================

            if (document == null ||
                !document.exists) {
              return _buildNoAssessment();
            }

            final data = document.data();

            if (data == null) {
              return _buildNoAssessment();
            }

            return _buildAssessmentContent(data);
          },
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDialogHeader(),

        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            'Unable to load your assessment history.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NO ASSESSMENT
  // ============================================================

  Widget _buildNoAssessment() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDialogHeader(),

        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: widget.isDarkMode
                    ? const Color(0xFF72D66F)
                    : AssessmentResultScreen.darkGreen,
                size: 50,
              ),

              const SizedBox(height: 12),

              Text(
                'No completed assessment found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIALOG HEADER
  // ============================================================

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        10,
        16,
      ),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF145A0D)
            : AssessmentResultScreen.darkGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Last Assessment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSESSMENT CONTENT
  // ============================================================

  Widget _buildAssessmentContent(
      Map<String, dynamic> data,
      ) {
    final answers =
        data['answers'] as Map<String, dynamic>? ?? {};

    final fattyRisk = _riskFromString(
      data['fattyLiverRisk'],
    );

    final cholesterolRisk = _riskFromString(
      data['cholesterolRisk'],
    );

    final completedAt =
    _getCompletedDate(data['completedAt']);

    return Column(
      children: [
        _buildDialogHeader(),

        // ======================================================
        // ONLY THIS PART SCROLLS
        // ======================================================

        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  // =================================================
                  // COMPLETED TIME
                  // =================================================

                  _buildCompletedTime(
                    completedAt,
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // RISK SUMMARY
                  // =================================================

                  _buildRiskSummary(
                    fattyRisk,
                    cholesterolRisk,
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // QUESTIONS
                  // =================================================

                  Text(
                    'Questions & Answers',
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? const Color(0xFF72D66F)
                          : AssessmentResultScreen.darkGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (answers.isEmpty)
                    _buildNoAnswers()
                  else
                    ..._buildQuestionCards(answers),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COMPLETED TIME
  // ============================================================

  Widget _buildCompletedTime(
      DateTime? completedAt,
      ) {
    String dateText = 'Date unavailable';
    String timeText = '';

    if (completedAt != null) {
      dateText = _formatDate(completedAt);
      timeText = _formatTime(completedAt);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: softGreenColor,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: widget.isDarkMode
                  ? const Color(0xFF72D66F)
                  : AssessmentResultScreen.darkGreen,
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  timeText.isEmpty
                      ? dateText
                      : '$dateText • $timeText',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RISK SUMMARY
  // ============================================================

  Widget _buildRiskSummary(
      RiskLevel fattyRisk,
      RiskLevel cholesterolRisk,
      ) {
    return Row(
      children: [
        Expanded(
          child: _HistoryRiskCard(
            title: 'Fatty Liver',
            risk: fattyRisk,
            isDarkMode: widget.isDarkMode,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _HistoryRiskCard(
            title: 'Cholesterol',
            risk: cholesterolRisk,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NO ANSWERS
  // ============================================================

  Widget _buildNoAnswers() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Text(
        'No answer details are available for this assessment.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // QUESTION CARDS
  // ============================================================

  List<Widget> _buildQuestionCards(
      Map<String, dynamic> answers,
      ) {
    final entries = answers.entries.toList();

    entries.sort((a, b) {
      final aNumber =
          int.tryParse(
            a.key.replaceAll('Q', ''),
          ) ??
              0;

      final bNumber =
          int.tryParse(
            b.key.replaceAll('Q', ''),
          ) ??
              0;

      return aNumber.compareTo(bNumber);
    });

    return entries.map((entry) {
      final value =
          entry.value as Map<String, dynamic>? ?? {};

      final question =
          value['question']?.toString() ??
              'Question unavailable';

      final section =
          value['section']?.toString() ?? '';

      final answersList =
      _convertAnswers(value['answers']);

      return _QuestionAnswerCard(
        questionNumber: entry.key,
        section: section,
        question: question,
        answers: answersList,
        isDarkMode: widget.isDarkMode,
      );
    }).toList();
  }

  // ============================================================
  // CONVERT ANSWERS
  // ============================================================

  List<String> _convertAnswers(
      dynamic value,
      ) {
    if (value is List) {
      return value
          .map(
            (item) => item.toString(),
      )
          .toList();
    }

    if (value is String &&
        value.trim().isNotEmpty) {
      return [value];
    }

    return [];
  }

  // ============================================================
  // FIRESTORE TIMESTAMP → DATETIME
  // ============================================================

  DateTime? _getCompletedDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
      DateTime date,
      ) {
    int hour = date.hour;

    final minute =
    date.minute.toString().padLeft(2, '0');

    final period =
    hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '$hour:$minute $period';
  }

  // ============================================================
  // RISK FROM STRING
  // ============================================================

  RiskLevel _riskFromString(
      dynamic value,
      ) {
    final text =
    value?.toString().toLowerCase().trim();

    switch (text) {
      case 'high':
        return RiskLevel.high;

      case 'moderate':
        return RiskLevel.moderate;

      case 'low':
      default:
        return RiskLevel.low;
    }
  }
}

// ============================================================
// HISTORY RISK CARD
// ============================================================

class _HistoryRiskCard extends StatelessWidget {
  final String title;
  final RiskLevel risk;
  final bool isDarkMode;

  const _HistoryRiskCard({
    required this.title,
    required this.risk,
    required this.isDarkMode,
  });

  Color _riskColor() {
    switch (risk) {
      case RiskLevel.low:
        return AssessmentResultScreen.green;

      case RiskLevel.moderate:
        return AssessmentResultScreen.orange;

      case RiskLevel.high:
        return AssessmentResultScreen.red;
    }
  }

  Color _riskBackground() {
    if (isDarkMode) {
      switch (risk) {
        case RiskLevel.low:
          return const Color(0xFF193523);

        case RiskLevel.moderate:
          return const Color(0xFF3A2A18);

        case RiskLevel.high:
          return const Color(0xFF3A2023);
      }
    }

    switch (risk) {
      case RiskLevel.low:
        return const Color(0xFFE8F5E9);

      case RiskLevel.moderate:
        return const Color(0xFFFFF3E0);

      case RiskLevel.high:
        return const Color(0xFFFFEBEE);
    }
  }

  String _riskName() {
    switch (risk) {
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AssessmentResultScreen.darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AssessmentResultScreen.darkBorder
              : const Color(0xFFDCEFD9),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDarkMode
                  ? AssessmentResultScreen.darkText
                  : AssessmentResultScreen.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: _riskBackground(),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Text(
              _riskName(),
              style: TextStyle(
                color: _riskColor(),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUESTION + ANSWER CARD
// ============================================================

class _QuestionAnswerCard
    extends StatelessWidget {
  final String questionNumber;
  final String section;
  final String question;
  final List<String> answers;
  final bool isDarkMode;

  const _QuestionAnswerCard({
    required this.questionNumber,
    required this.section,
    required this.question,
    required this.answers,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode
        ? AssessmentResultScreen.darkCard
        : Colors.white;

    final primaryTextColor = isDarkMode
        ? AssessmentResultScreen.darkText
        : AssessmentResultScreen.textDark;

    final secondaryTextColor = isDarkMode
        ? AssessmentResultScreen.darkMutedText
        : AssessmentResultScreen.mutedText;

    final borderColor = isDarkMode
        ? AssessmentResultScreen.darkBorder
        : const Color(0xFFE0ECE1);

    final softGreenColor = isDarkMode
        ? AssessmentResultScreen.darkPaleGreen
        : AssessmentResultScreen.paleGreen;

    final answerBackgroundColor = isDarkMode
        ? AssessmentResultScreen.darkAnswerBg
        : const Color(0xFFF1FAF0);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              isDarkMode ? 30 : 7,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ====================================================
          // QUESTION NUMBER + SECTION
          // ====================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: softGreenColor,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Text(
                  questionNumber.replaceAll(
                    'Q',
                    '',
                  ),
                  style: TextStyle(
                    color: isDarkMode
                        ? const Color(0xFF72D66F)
                        : AssessmentResultScreen.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    if (section.isNotEmpty)
                      Text(
                        section,
                        style: TextStyle(
                          color: isDarkMode
                              ? const Color(0xFF72D66F)
                              : AssessmentResultScreen.green,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                    const SizedBox(height: 3),

                    Text(
                      question,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ====================================================
          // ANSWERS
          // ====================================================

          Text(
            'Your answer:',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          if (answers.isEmpty)
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AssessmentResultScreen.darkCardSecondary
                    : AssessmentResultScreen.pageBg,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Text(
                'No answer recorded',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                  fontStyle:
                  FontStyle.italic,
                ),
              ),
            )
          else
            ...answers.map(
                  (answer) {
                return Container(
                  width: double.infinity,
                  margin:
                  const EdgeInsets.only(
                    bottom: 5,
                  ),
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: answerBackgroundColor,
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                      color: isDarkMode
                          ? AssessmentResultScreen.darkBorder
                          : const Color(0xFFDCEFD9),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Icon(
                          Icons
                              .check_circle_rounded,
                          color:
                          AssessmentResultScreen.green,
                          size: 16,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Text(
                          answer,
                          style: TextStyle(
                            color:
                            primaryTextColor,
                            fontSize: 12.5,
                            height: 1.3,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ============================================================
// DONUT RISK TILE
// ============================================================

class _DonutRiskTile
    extends StatelessWidget {
  final String title;
  final int score;
  final String status;
  final String description;
  final List<Color> gradientColors;
  final Color statusColor;
  final Color statusBgColor;
  final bool isDarkMode;

  const _DonutRiskTile({
    required this.title,
    required this.score,
    required this.status,
    required this.description,
    required this.gradientColors,
    required this.statusColor,
    required this.statusBgColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AssessmentResultScreen.darkCard
            : Colors.white,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: isDarkMode
              ? AssessmentResultScreen.darkBorder
              : const Color(0xFFE2EDE3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              isDarkMode ? 30 : 8,
            ),
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
            style: TextStyle(
              color: isDarkMode
                  ? const Color(0xFF72D66F)
                  : AssessmentResultScreen.darkGreen,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),

          const SizedBox(height: 5),

          SizedBox(
            height: 124,
            width: 115,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  left: 7.5,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter:
                      _GradientDonutPainter(
                        score: score,
                        gradientColors:
                        gradientColors,
                      ),
                      child: Center(
                        child: Text(
                          '$score%',
                          style: TextStyle(
                            color: isDarkMode
                                ? AssessmentResultScreen.darkText
                                : AssessmentResultScreen.textDark,
                            fontSize: 25,
                            fontWeight:
                            FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 23,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius:
                      BorderRadius.circular(16),
                      border: Border.all(
                        color:
                        statusColor.withAlpha(50),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w800,
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
            style: TextStyle(
              color: isDarkMode
                  ? AssessmentResultScreen.darkMutedText
                  : AssessmentResultScreen.mutedText,
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
// OVERALL GAUGE PAINTER
// ============================================================

class _GradientGaugePainter
    extends CustomPainter {
  final int score;
  final List<Color> gradientColors;
  final Color indicatorColor;
  final Color trackColor;

  const _GradientGaugePainter({
    required this.score,
    required this.gradientColors,
    required this.indicatorColor,
    required this.trackColor,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
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

    // ========================================================
    // BACKGROUND TRACK
    // ========================================================

    final background = Paint()
      ..color = trackColor
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

    // ========================================================
    // GRADIENT
    // ========================================================

    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: math.pi * 2,
      colors: gradientColors,
    );

    final progress = Paint()
      ..shader =
      gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final progressSweep =
        math.pi *
            (score.clamp(0, 100) / 100);

    canvas.drawArc(
      rect,
      math.pi,
      progressSweep,
      false,
      progress,
    );

    // ========================================================
    // INDICATOR
    // ========================================================

    final angle =
        math.pi + progressSweep;

    final point = Offset(
      center.dx +
          math.cos(angle) * radius,
      center.dy +
          math.sin(angle) * radius,
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
      Paint()
        ..color = indicatorColor,
    );
  }

  @override
  bool shouldRepaint(
      covariant _GradientGaugePainter
      oldDelegate,
      ) {
    return oldDelegate.score != score ||
        oldDelegate.gradientColors !=
            gradientColors ||
        oldDelegate.indicatorColor !=
            indicatorColor ||
        oldDelegate.trackColor !=
            trackColor;
  }
}

// ============================================================
// DONUT PAINTER
// ============================================================

class _GradientDonutPainter
    extends CustomPainter {
  final int score;
  final List<Color> gradientColors;

  const _GradientDonutPainter({
    required this.score,
    required this.gradientColors,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width / 2 - 8;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    const startAngle =
        2 * math.pi / 3;

    const totalSweep =
        5 * math.pi / 3;

    // ========================================================
    // BACKGROUND DONUT
    // ========================================================

    final background = Paint()
      ..color =
      gradientColors.first.withAlpha(30)
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

    // ========================================================
    // GRADIENT
    // ========================================================

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle:
      startAngle + totalSweep,
      colors: gradientColors,
    );

    final progress = Paint()
      ..shader =
      gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final progressSweep =
        totalSweep *
            (score.clamp(0, 100) / 100);

    canvas.drawArc(
      rect,
      startAngle,
      progressSweep,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(
      covariant _GradientDonutPainter
      oldDelegate,
      ) {
    return oldDelegate.score != score ||
        oldDelegate.gradientColors !=
            gradientColors;
  }
}