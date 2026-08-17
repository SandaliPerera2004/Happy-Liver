import 'package:flutter/material.dart';

import '../../models/question_model.dart';
import '../../models/risk_level.dart';
import '../../services/assessment_service.dart';
import 'assessment_result_loading_screen.dart';

class AssessmentQuestionScreen extends StatefulWidget {
  const AssessmentQuestionScreen({super.key, required int questionIndex});

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

  /// Example:
  ///
  /// {
  ///   1: [0],
  ///   13: [0, 2],
  /// }
  final Map<int, List<int>> _answers = {};

  List<AssessmentQuestion> get _questions =>
      AssessmentService.questions;

  AssessmentQuestion get _currentQuestion =>
      _questions[_currentQuestionIndex];

  bool get _isAnswered {
    final answers = _answers[_currentQuestion.id];

    return answers != null && answers.isNotEmpty;
  }

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

  void _selectAnswer(int optionIndex) {
    final question = _currentQuestion;

    setState(() {
      if (!question.isMultipleChoice) {
        _answers[question.id] = [optionIndex];
        return;
      }

      final currentAnswers =
      List<int>.from(_answers[question.id] ?? []);

      final selectedOption =
      question.options[optionIndex];

      // If "None" is selected, remove all other answers.
      if (selectedOption.isNone) {
        _answers[question.id] = [optionIndex];
        return;
      }

      // Remove "None" if another option is selected.
      currentAnswers.removeWhere(
            (index) => question.options[index].isNone,
      );

      if (currentAnswers.contains(optionIndex)) {
        currentAnswers.remove(optionIndex);
      } else {
        currentAnswers.add(optionIndex);
      }

      _answers[question.id] = currentAnswers;
    });
  }

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

  void _goPrevious() {
    if (_currentQuestionIndex == 0) return;

    setState(() {
      _currentQuestionIndex--;
    });
  }

  void _submitAssessment() {
    final AssessmentResult result =
    AssessmentService.calculateResult(_answers);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AssessmentResultLoadingScreen(
              result: result,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;

    return Scaffold(
      backgroundColor: _backgroundColor,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
              ),

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // =====================================================
                  // PROGRESS INDICATOR
                  // =====================================================

                  _buildProgressIndicator(),

                  const SizedBox(height: 22),

                  // =====================================================
                  // SECTION TITLE
                  // =====================================================

                  Text(
                    '${question.sectionIcon} ${question.section}',
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF314337),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // QUESTION NUMBER
                  // =====================================================

                  Text(
                    'Question ${question.id}/15',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3D4140),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =====================================================
                  // QUESTION CARD
                  // =====================================================

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildQuestionCard(question),

                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ),

                  // =====================================================
                  // PREVIOUS / NEXT / SUBMIT
                  // =====================================================

                  _buildNavigationButtons(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final activeStep = _getProgressStep();

    return SizedBox(
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(
              horizontal: 18,
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
                width: 20,
                height: 20,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: isCompleted
                      ? _darkGreen
                      : const Color(0xFFC9DDC9),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),

                alignment: Alignment.center,

                child: Text(
                  '$step',

                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildQuestionCard(
      AssessmentQuestion question,
      ) {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(
        minHeight: 180,
      ),

      padding: const EdgeInsets.fromLTRB(
        14,
        16,
        14,
        18,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: _questionBorder,
          width: 1.3,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            question.question,
            textAlign: TextAlign.left,

            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: Color(0xFF45554A),
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(
            question.options.length,
                (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
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
          minHeight: 42,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFB8E4B1)
              : _optionGreen,

          borderRadius: BorderRadius.circular(6),

          border: Border.all(
            color: selected
                ? _mediumGreen
                : _optionBorder,

            width: selected ? 1.5 : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            // =================================================
            // CHECKBOX ONLY FOR MULTIPLE-CHOICE QUESTIONS
            // =================================================

            if (question.isMultipleChoice) ...[
              Container(
                width: 15,
                height: 15,

                decoration: BoxDecoration(
                  color: selected
                      ? _darkGreen
                      : Colors.transparent,

                  borderRadius:
                  BorderRadius.circular(2),

                  border: Border.all(
                    color: const Color(0xFF6D8D74),
                    width: 1.3,
                  ),
                ),

                child: selected
                    ? const Icon(
                  Icons.check,
                  size: 15,
                  color: Colors.white,
                )
                    : null,
              ),

              const SizedBox(width: 12),
            ],

            Expanded(
              child: Text(
                option.text,

                textAlign:
                question.isMultipleChoice
                    ? TextAlign.left
                    : TextAlign.center,

                style: const TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF46634A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          const SizedBox(width: 14),

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

  Widget _buildNavigationButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 34,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          elevation: 3,

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
            borderRadius: BorderRadius.circular(5),
          ),
        ),

        child: Text(
          text,

          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}