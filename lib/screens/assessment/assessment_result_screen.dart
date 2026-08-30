import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/risk_level.dart';
import 'package:happy_liver/widgets/custom_header.dart';
import 'package:happy_liver/widgets/custom_bottom_nav_bar.dart';
import '../recommendations/recommendations_screen.dart';

class AssessmentResultScreen extends StatelessWidget {
  final AssessmentResult result;

  const AssessmentResultScreen({super.key, required this.result});

  // ============================================================
  // COLORS
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
        return const [Color(0xFF66BB6A), Color(0xFF2E7D32)];

      case RiskLevel.moderate:
        return const [Color(0xFFFF9800), Color(0xFFE65100)];

      case RiskLevel.high:
        return const [Color(0xFFEF5350), Color(0xFFC62828)];
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

    if (fattyRisk == RiskLevel.high || cholesterolRisk == RiskLevel.high) {
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
      backgroundColor: pageBg,

      // ========================================================
      // YOUR CUSTOM HEADER
      // ========================================================
      appBar: const CustomHeader(title: 'Assessment Results', showBack: true),

      // ========================================================
      // MAIN CONTENT
      // ========================================================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        child: Column(
          children: [
            const SizedBox(height: 2),

            // Greeting
            _buildGreeting(),

            const SizedBox(height: 12),

            // Overall Risk
            _buildOverallRisk(overallPercentage, overallRisk),

            const SizedBox(height: 7),

            // Fatty Liver + Cholesterol
            _buildRiskCardsRow(),

            const SizedBox(height: 7),

            // Overall Insight
            _buildInsightCard(),

            const SizedBox(height: 12),

            // Back to Dashboard
            _buildBackButton(context),

            const SizedBox(height: 12),

          ],
        ),
      ),

      // ========================================================
      // REUSABLE BOTTOM NAVIGATION BAR
      // ========================================================
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 0),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

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
                  'Great job! 🎉',
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

          const SizedBox(width: 3),

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
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.favorite_rounded,
                    color: darkGreen,
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

  Widget _buildOverallRisk(int score, RiskLevel risk) {
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
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCEFD9)),
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
                score: score,
                gradientColors: _riskGradient(risk),
                indicatorColor: _riskColor(risk),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 30),

                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: textDark,
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
                    style: const TextStyle(color: mutedText, fontSize: 12.5),
                  ),

                  Text(
                    subtext2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: mutedText, fontSize: 12.5),
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
            status: _riskName(result.fattyLiverRisk),
            description:
                'Your fatty liver risk score is ${_riskName(result.fattyLiverRisk).toLowerCase()}.',
            gradientColors: _riskGradient(result.fattyLiverRisk),
            statusColor: _riskColor(result.fattyLiverRisk),
            statusBgColor: _riskBackground(result.fattyLiverRisk),
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: _DonutRiskTile(
            title: 'CHOLESTEROL RISK',
            score: cholesterolScore,
            status: _riskName(result.cholesterolRisk),
            description:
                'Your cholesterol risk score is ${_riskName(result.cholesterolRisk).toLowerCase()}.',
            gradientColors: _riskGradient(result.cholesterolRisk),
            statusColor: _riskColor(result.cholesterolRisk),
            statusBgColor: _riskBackground(result.cholesterolRisk),
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

    if (fattyRisk == RiskLevel.low && cholesterolRisk == RiskLevel.low) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCEFD9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
              color: paleGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: darkGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OVERALL INSIGHT',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  insight,
                  style: const TextStyle(
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

  // ============================================================
// SEE PERSONALIZED RECOMMENDATIONS BUTTON
// ============================================================

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendationsScreen(
                result: result,
              ),
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
              'View Recommendations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
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
              return const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(
                    color:
                    AssessmentResultScreen.darkGreen,
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

            return _buildAssessmentContent(
              data,
            );
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

        const Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'Unable to load your assessment history.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
              AssessmentResultScreen.mutedText,
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

        const Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                color:
                AssessmentResultScreen.darkGreen,
                size: 50,
              ),
              SizedBox(height: 12),
              Text(
                'No completed assessment found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                  AssessmentResultScreen.mutedText,
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
      decoration: const BoxDecoration(
        color:
        AssessmentResultScreen.darkGreen,
        borderRadius: BorderRadius.only(
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
        // IMPORTANT:
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

                  const Text(
                    'Questions & Answers',
                    style: TextStyle(
                      color:
                      AssessmentResultScreen.darkGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (answers.isEmpty)
                    _buildNoAnswers()
                  else
                    ..._buildQuestionCards(
                      answers,
                    ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCEFD9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
              AssessmentResultScreen.paleGreen,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color:
              AssessmentResultScreen.darkGreen,
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completed',
                  style: TextStyle(
                    color:
                    AssessmentResultScreen.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  timeText.isEmpty
                      ? dateText
                      : '$dateText • $timeText',
                  style: const TextStyle(
                    color:
                    AssessmentResultScreen.textDark,
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
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _HistoryRiskCard(
            title: 'Cholesterol',
            risk: cholesterolRisk,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'No answer details are available for this assessment.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color:
          AssessmentResultScreen.mutedText,
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
          value['section']?.toString() ??
              '';

      final answersList =
      _convertAnswers(value['answers']);

      return _QuestionAnswerCard(
        questionNumber: entry.key,
        section: section,
        question: question,
        answers: answersList,
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

class _HistoryRiskCard
    extends StatelessWidget {
  final String title;
  final RiskLevel risk;

  const _HistoryRiskCard({
    required this.title,
    required this.risk,
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
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDCEFD9),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color:
              AssessmentResultScreen.textDark,
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

  const _QuestionAnswerCard({
    required this.questionNumber,
    required this.section,
    required this.question,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE0ECE1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
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
                  color:
                  AssessmentResultScreen.paleGreen,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Text(
                  questionNumber.replaceAll(
                    'Q',
                    '',
                  ),
                  style: const TextStyle(
                    color:
                    AssessmentResultScreen.darkGreen,
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
                        style: const TextStyle(
                          color:
                          AssessmentResultScreen.green,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                    const SizedBox(height: 3),

                    Text(
                      question,
                      style: const TextStyle(
                        color:
                        AssessmentResultScreen.textDark,
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

          const Text(
            'Your answer:',
            style: TextStyle(
              color:
              AssessmentResultScreen.mutedText,
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
                color:
                AssessmentResultScreen.pageBg,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: const Text(
                'No answer recorded',
                style: TextStyle(
                  color:
                  AssessmentResultScreen.mutedText,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
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
                    color:
                    const Color(0xFFF1FAF0),
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                      color:
                      const Color(0xFFDCEFD9),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                        EdgeInsets.only(
                          top: 2,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color:
                          AssessmentResultScreen.green,
                          size: 16,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Text(
                          answer,
                          style:
                          const TextStyle(
                            color:
                            AssessmentResultScreen.textDark,
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
        border: Border.all(color: const Color(0xFFE2EDE3)),
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

          SizedBox(
            height: 124,
            width: 115,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // DONUT
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

                // STATUS BADGE
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
// OVERALL GAUGE PAINTER
// ============================================================

class _GradientGaugePainter extends CustomPainter {
  final int score;
  final List<Color> gradientColors;
  final Color indicatorColor;

  const _GradientGaugePainter({
    required this.score,
    required this.gradientColors,
    required this.indicatorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 25);

    final radius = math.min(size.width * .35, size.height * .80);

    final rect = Rect.fromCircle(center: center, radius: radius);

    // BACKGROUND TRACK

    final background = Paint()
      ..color = const Color(0xFFE4F3DD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, background);

    // GRADIENT PROGRESS

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

    canvas.drawArc(rect, math.pi, progressSweep, false, progress);

    // INDICATOR

    final angle = math.pi + progressSweep;

    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    canvas.drawCircle(point, 7, Paint()..color = Colors.white);

    canvas.drawCircle(point, 4, Paint()..color = indicatorColor);
  }

  @override
  bool shouldRepaint(covariant _GradientGaugePainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.indicatorColor != indicatorColor;
  }
}

// ============================================================
// DONUT PAINTER
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
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width / 2 - 8;

    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = 2 * math.pi / 3;

    const totalSweep = 5 * math.pi / 3;

    // BACKGROUND TRACK

    final background = Paint()
      ..color = gradientColors.first.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, totalSweep, false, background);

    // GRADIENT PROGRESS

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

    canvas.drawArc(rect, startAngle, progressSweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _GradientDonutPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.gradientColors != gradientColors;
  }
}
