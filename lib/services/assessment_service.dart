import '../models/question_model.dart';
import '../models/risk_level.dart';

class AssessmentService {
  // =========================================================
  // ALL ASSESSMENT QUESTIONS
  // =========================================================

  static final List<AssessmentQuestion> questions = [
    // =========================================================
    // LIFESTYLE & WORK
    // =========================================================

    AssessmentQuestion(
      id: 1,
      section: 'Lifestyle & Work',
      sectionIcon: '👨‍💼',
      question: 'What type of work do you do?',
      options: [
        AnswerOption(
          text: 'Active\n(moving/standing)',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Mixed\n(some sitting, some moving)',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Sedentary\n(mostly sitting)',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 2,
      section: 'Lifestyle & Work',
      sectionIcon: '👨‍💼',
      question:
      'How often do you exercise or engage in physical activity?',
      options: [
        AnswerOption(
          text: '5 or more days/week',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–4 days/week',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: '1 or fewer days/week',
          fattyLiverPoints: 3,
          cholesterolPoints: 2,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 3,
      section: 'Lifestyle & Work',
      sectionIcon: '👨‍💼',
      question:
      'How many hours of sleep do you usually get per night?',
      options: [
        AnswerOption(
          text: '7–9 hours',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '5–6 hours',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Less than 5 hours',
          fattyLiverPoints: 2,
          cholesterolPoints: 1,
        ),
      ],
    ),

    // =========================================================
    // DIET & EATING HABITS
    // =========================================================

    AssessmentQuestion(
      id: 4,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽️',
      question: 'How often do you eat restaurant or fast food?',
      options: [
        AnswerOption(
          text: 'Rarely',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '1–2 times/week',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: '3 or more times/week',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 5,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽️',
      question:
      'How often do you eat fried or oily foods per week?',
      options: [
        AnswerOption(
          text: '0–1 times',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–3 times',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: '4 or more times',
          fattyLiverPoints: 3,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 6,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽️',
      question:
      'How often do you eat red meat (beef, pork, mutton)?',
      options: [
        AnswerOption(
          text: 'Rarely\n(0–1 time/week)',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Sometimes\n(2–3 times/week)',
          fattyLiverPoints: 1,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: 'Often\n(4 or more times/week)',
          fattyLiverPoints: 2,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 7,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽️',
      question:
      'How often do you choose fish or lean protein such as chicken, pulses or beans?',
      options: [
        AnswerOption(
          text: 'Daily or most days',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–3 times/week',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Rarely/Never',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 8,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽️',
      question:
      'How many servings of fruits and vegetables do you eat daily?',
      options: [
        AnswerOption(
          text: '5 or more servings',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–4 servings',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: '1 or fewer servings',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 9,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽️',
      question:
      'How often do you reuse cooking oil for frying?',
      options: [
        AnswerOption(
          text: 'Never/Rarely',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Sometimes',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Frequently',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 10,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽️',
      question:
      'How often do you eat processed or packaged foods such as chips, biscuits or instant noodles?',
      options: [
        AnswerOption(
          text: 'Rarely',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Sometimes',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Frequently',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
      ],
    ),

    // =========================================================
    // LIFESTYLE CHOICES
    // =========================================================

    AssessmentQuestion(
      id: 11,
      section: 'Lifestyle Choices',
      sectionIcon: '🥤',
      question:
      'How often do you consume alcoholic drinks?',
      options: [
        AnswerOption(
          text: 'Never',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Occasionally',
          fattyLiverPoints: 1,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Frequently',
          fattyLiverPoints: 3,
          cholesterolPoints: 0,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 12,
      section: 'Lifestyle Choices',
      sectionIcon: '🥤',
      question:
      'How often do you drink sugar-sweetened beverages such as soft drinks, sweetened juices or energy drinks?',
      options: [
        AnswerOption(
          text: 'Rarely/Never',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '1–3 times/week',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Daily',
          fattyLiverPoints: 3,
          cholesterolPoints: 2,
        ),
      ],
    ),

    // =========================================================
    // MEDICAL & FAMILY HISTORY
    // MULTIPLE CHOICE
    // =========================================================

    AssessmentQuestion(
      id: 13,
      section: 'Medical & Family History',
      sectionIcon: '🖊️',
      question:
      'Do you have a family history of any of the following?',
      isMultipleChoice: true,
      options: [
        AnswerOption(
          text: 'Fatty Liver',
          fattyLiverPoints: 3,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'High Cholesterol',
          fattyLiverPoints: 0,
          cholesterolPoints: 3,
        ),
        AnswerOption(
          text: 'Heart Disease',
          fattyLiverPoints: 0,
          cholesterolPoints: 3,
        ),
        AnswerOption(
          text: 'None',
          isNone: true,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 14,
      section: 'Medical & Family History',
      sectionIcon: '🖊️',
      question:
      'Have you ever been diagnosed with any of the following?',
      isMultipleChoice: true,
      options: [
        AnswerOption(
          text: 'Diabetes',
          fattyLiverPoints: 3,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: 'Hypertension\n(High Blood Pressure)',
          fattyLiverPoints: 2,
          cholesterolPoints: 3,
        ),
        AnswerOption(
          text: 'Metabolic Syndrome',
          fattyLiverPoints: 3,
          cholesterolPoints: 3,
        ),
        AnswerOption(
          text: 'None',
          isNone: true,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 15,
      section: 'Medical & Family History',
      sectionIcon: '🖊️',
      question:
      'Have you ever been told by a healthcare professional that you have any of the following?',
      isMultipleChoice: true,
      options: [
        AnswerOption(
          text: 'Overweight or obesity',
          fattyLiverPoints: 3,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: 'High triglycerides',
          fattyLiverPoints: 2,
          cholesterolPoints: 3,
        ),
        AnswerOption(
          text: 'Low HDL ("good" cholesterol)',
          fattyLiverPoints: 2,
          cholesterolPoints: 3,
        ),
        AnswerOption(
          text: 'None',
          isNone: true,
        ),
      ],
    ),
  ];

  // =========================================================
  // CALCULATE FINAL RESULT
  // =========================================================

  static AssessmentResult calculateResult(
      Map<int, List<int>> answers,
      ) {
    int fattyLiverScore = 0;
    int cholesterolScore = 0;

    int fattyLiverMaxScore = 0;
    int cholesterolMaxScore = 0;

    for (final question in questions) {
      final selectedIndexes =
          answers[question.id] ?? [];

      // Calculate selected answer scores
      for (final index in selectedIndexes) {
        if (index < 0 || index >= question.options.length) {
          continue;
        }

        final option = question.options[index];

        fattyLiverScore += option.fattyLiverPoints;
        cholesterolScore += option.cholesterolPoints;
      }

      // Calculate maximum possible score
      if (question.isMultipleChoice) {
        fattyLiverMaxScore += question.options
            .where((option) => !option.isNone)
            .fold<int>(
          0,
              (sum, option) =>
          sum + option.fattyLiverPoints,
        );

        cholesterolMaxScore += question.options
            .where((option) => !option.isNone)
            .fold<int>(
          0,
              (sum, option) =>
          sum + option.cholesterolPoints,
        );
      } else {
        final fattyPoints = question.options
            .map((option) => option.fattyLiverPoints);

        final cholesterolPoints = question.options
            .map((option) => option.cholesterolPoints);

        fattyLiverMaxScore += fattyPoints.reduce(
              (a, b) => a > b ? a : b,
        );

        cholesterolMaxScore += cholesterolPoints.reduce(
              (a, b) => a > b ? a : b,
        );
      }
    }

    return AssessmentResult(
      fattyLiverScore: fattyLiverScore,
      fattyLiverMaxScore: fattyLiverMaxScore,
      cholesterolScore: cholesterolScore,
      cholesterolMaxScore: cholesterolMaxScore,
      fattyLiverRisk: _getRiskLevel(
        fattyLiverScore,
        fattyLiverMaxScore,
      ),
      cholesterolRisk: _getRiskLevel(
        cholesterolScore,
        cholesterolMaxScore,
      ),
    );
  }

  // =========================================================
  // DETERMINE RISK LEVEL
  // =========================================================

  static RiskLevel _getRiskLevel(
      int score,
      int maxScore,
      ) {
    if (maxScore == 0) {
      return RiskLevel.low;
    }

    final percentage =
        (score / maxScore) * 100;

    if (percentage < 34) {
      return RiskLevel.low;
    } else if (percentage < 67) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.high;
    }
  }

  // =========================================================
  // BUILD READABLE ANSWER SUMMARY
  // =========================================================

  static Map<String, dynamic> buildAnswerSummary(
      Map<int, List<int>> answers,
      ) {
    final Map<String, dynamic> result = {};

    for (final question in questions) {
      final selectedIndexes =
          answers[question.id] ?? [];

      final selectedAnswers = <String>[];

      for (final index in selectedIndexes) {
        if (index < 0 ||
            index >= question.options.length) {
          continue;
        }

        selectedAnswers.add(
          question.options[index].text,
        );
      }

      result['Q${question.id}'] = {
        'question': question.question,
        'section': question.section,
        'answers': selectedAnswers,
      };
    }

    return result;
  }
}