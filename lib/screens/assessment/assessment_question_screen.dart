import 'package:flutter/material.dart';

import '../../models/question_model.dart';
import '../../models/risk_level.dart';
import '../../services/assessment_service.dart';
import 'assessment_result_loading_screen.dart';

class AssessmentQuestionScreen extends StatefulWidget {
  const AssessmentQuestionScreen({
    super.key,
    required int questionIndex,
  });

  @override
  State<AssessmentQuestionScreen> createState() =>
      _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState
    extends State<AssessmentQuestionScreen> {
  static const Color _backgroundColor = Color(0xFFF9FAF9);

  static const Color _darkGreen = Color(0xFF1C5A3C);
  static const Color _mediumGreen = Color(0xFF2E7D32);

  static const Color _lightGreen = Color(0xFFE0F3D7);
  static const Color _questionBorder = Color(0xFF83A68D);

  static const Color _optionGreen = Color(0xFFDDF2D3);
  static const Color _optionBorder = Color(0xFFB7DBAF);

  int _currentQuestionIndex = 0;

  final Map<int, List<int>> _answers = {};

  List<AssessmentQuestion> get _questions =>
      AssessmentService.questions;

  AssessmentQuestion get _currentQuestion =>
      _questions[_currentQuestionIndex];

  bool get _isAnswered {
    final answers = _answers[_currentQuestion.id];

    return answers != null && answers.isNotEmpty;
  }

  // =========================================================
  // PROGRESS STEP
  // =========================================================

  int _getProgressStep() {
    if (_currentQuestionIndex <= 2) {
      return 1;
    }

    if (_currentQuestionIndex <= 9) {
      return 2;
    }

    if (_currentQuestionIndex <= 11) {
      return 3;
    }

    return 4;
  }

  // =========================================================
  // SELECT ANSWER
  // =========================================================

  void _selectAnswer(int optionIndex) {
    final question = _currentQuestion;

    setState(() {
      // Single choice questions
      if (!question.isMultipleChoice) {
        _answers[question.id] = [optionIndex];
        return;
      }

      // Multiple choice questions
      final currentAnswers =
      List<int>.from(_answers[question.id] ?? []);

      final selectedOption =
      question.options[optionIndex];

      // If "None" is selected, remove all other answers
      if (selectedOption.isNone) {
        _answers[question.id] = [optionIndex];
        return;
      }

      // Remove "None" if another answer is selected
      currentAnswers.removeWhere(
            (index) => question.options[index].isNone,
      );

      // Toggle selected answer
      if (currentAnswers.contains(optionIndex)) {
        currentAnswers.remove(optionIndex);
      } else {
        currentAnswers.add(optionIndex);
      }

      _answers[question.id] = currentAnswers;
    });
  }

  // =========================================================
  // NEXT QUESTION
  // =========================================================

  void _goNext() {
    if (!_isAnswered) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitAssessment();
    }
  }

  // =========================================================
  // PREVIOUS QUESTION
  // =========================================================

  void _goPrevious() {
    if (_currentQuestionIndex == 0) return;

    setState(() {
      _currentQuestionIndex--;
    });
  }

  // =========================================================
  // SUBMIT ASSESSMENT
  // =========================================================

  void _submitAssessment() {
    final AssessmentResult result =
    AssessmentService.calculateResult(_answers);

    try {
      debugPrint('========================================');
      debugPrint('Starting assessment save...');
      debugPrint('Number of answered questions: ${_answers.length}');
      debugPrint('Answers: $_answers');

      await AssessmentFirestoreService.saveAssessment(
        answers: _answers,
        result: result,
      );

      debugPrint('Assessment saved successfully!');
      debugPrint('========================================');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AssessmentResultLoadingScreen(
                result: result,
              ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('ASSESSMENT SAVE ERROR');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('========================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Save error: $e',
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  // =========================================================
  // MAIN SCREEN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;

    return Scaffold(
      backgroundColor: _backgroundColor,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // =====================================================
                  // PROGRESS INDICATOR
                  // =====================================================

                  _buildProgressIndicator(),

                  const SizedBox(height: 35),

                  // =====================================================
                  // SECTION TITLE
                  // =====================================================

                  Text(
                    '${question.sectionIcon} ${question.section}',
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF314337),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // =====================================================
                  // QUESTION NUMBER
                  // =====================================================

                  Text(
                    'Question ${question.id}/15',

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3D4140),
                    ),
                  ),

                  const SizedBox(height: 23),

                  // =====================================================
                  // QUESTION CARD
                  // =====================================================

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildQuestionCard(question),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // =====================================================
                  // PREVIOUS / NEXT / SUBMIT
                  // =====================================================

                  _buildNavigationButtons(),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PROGRESS INDICATOR
  // =========================================================

  Widget _buildProgressIndicator() {
    final activeStep = _getProgressStep();

    return SizedBox(
      height: 42,

      child: Stack(
        alignment: Alignment.center,

        children: [
          Container(
            height: 3,

            margin: const EdgeInsets.symmetric(
              horizontal: 22,
            ),

            color: const Color(0xFFB6CDBA),
          ),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: List.generate(4, (index) {
              final step = index + 1;

              final isCompleted =
                  step <= activeStep;

              return Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: isCompleted
                      ? _darkGreen
                      : const Color(0xFFC9DDC9),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                alignment: Alignment.center,

                child: Text(
                  '$step',

                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,

                    color: isCompleted
                        ? Colors.white
                        : const Color(0xFF507057),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BIG QUESTION CARD
  // =========================================================

  Widget _buildQuestionCard(
      AssessmentQuestion question,
      ) {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(
        minHeight: 330,
      ),

      padding: const EdgeInsets.fromLTRB(
        22,
        26,
        22,
        26,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: _questionBorder,
          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.50),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          // =================================================
          // QUESTION TEXT
          // =================================================

          Text(
            question.question,
            textAlign: TextAlign.left,

            style: const TextStyle(
              fontSize: 22,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Color(0xFF45554A),
            ),
          ),

          const SizedBox(height: 30),

          // =================================================
          // ANSWER OPTIONS
          // =================================================

          ...List.generate(
            question.options.length,
                (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),

                child: _buildAnswerOption(
                  question,
                  index,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BIG ANSWER BUTTON
  // =========================================================

  Widget _buildAnswerOption(
      AssessmentQuestion question,
      int optionIndex,
      ) {
    final selected =
    (_answers[question.id] ?? [])
        .contains(optionIndex);

    final option =
    question.options[optionIndex];

    return GestureDetector(
      onTap: () {
        _selectAnswer(optionIndex);
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 150,
        ),

        width: double.infinity,

        constraints: const BoxConstraints(
          minHeight: 68,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFB8E4B1)
              : _optionGreen,

          borderRadius: BorderRadius.circular(10),

          border: Border.all(
            color: selected
                ? _mediumGreen
                : _optionBorder,

            width: selected ? 2 : 1.3,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            // =============================================
            // CHECKBOX FOR MULTIPLE CHOICE QUESTIONS
            // =============================================

            if (question.isMultipleChoice) ...[
              Container(
                width: 26,
                height: 26,

                decoration: BoxDecoration(
                  color: selected
                      ? _darkGreen
                      : Colors.transparent,

                  borderRadius:
                  BorderRadius.circular(4),

                  border: Border.all(
                    color: const Color(0xFF6D8D74),
                    width: 2,
                  ),
                ),

                child: selected
                    ? const Icon(
                  Icons.check,
                  size: 21,
                  color: Colors.white,
                )
                    : null,
              ),

              const SizedBox(width: 16),
            ],

            // =============================================
            // ANSWER TEXT
            // =============================================

            Expanded(
              child: Text(
                option.text,

                textAlign:
                question.isMultipleChoice
                    ? TextAlign.left
                    : TextAlign.center,

                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF46634A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // NAVIGATION BUTTONS
  // =========================================================

  Widget _buildNavigationButtons() {
    final isFirstQuestion =
        _currentQuestionIndex == 0;

    final isLastQuestion =
        _currentQuestionIndex ==
            _questions.length - 1;

    return Row(
      children: [
        if (!isFirstQuestion)
          Expanded(
            child: _buildNavigationButton(
              text: 'Previous',
              onPressed: _goPrevious,
              isPrimary: false,
            ),
          ),

        if (!isFirstQuestion)
          const SizedBox(width: 18),

        Expanded(
          child: _buildNavigationButton(
            text: isLastQuestion
                ? 'Submit'
                : 'Next',

            onPressed: _isAnswered
                ? _goNext
                : null,

            isPrimary: true,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BIG NAVIGATION BUTTON
  // =========================================================

  Widget _buildNavigationButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 58,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          elevation: 4,

          backgroundColor: isPrimary
              ? _darkGreen
              : const Color(0xFFE3E5E5),

          disabledBackgroundColor:
          const Color(0xFFE0E4E1),

          foregroundColor: isPrimary
              ? Colors.white
              : const Color(0xFF414847),

          disabledForegroundColor:
          const Color(0xFF9AA19D),

          shadowColor:
          Colors.black.withOpacity(0.20),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        child: Text(
          text,

          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}