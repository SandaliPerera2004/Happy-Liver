import '../models/question_model.dart';
import '../models/risk_level.dart';

class AssessmentService {
  static const List<AssessmentQuestion> questions = [

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
          fattyLiverPoints: 3,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 2,
      section: 'Lifestyle & Work',
      sectionIcon: '👨‍💼',
      question: 'How often do you exercise or engage in physical activity?',
      options: [
        AnswerOption(
          text: '5 or more than days/week',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–4 days/week',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: '1 or less than day/week',
          fattyLiverPoints: 3,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 3,
      section: 'Lifestyle & Work',
      sectionIcon: '👨‍💼',
      question: 'How many hours of sleep do you usually get per night?',
      options: [
        AnswerOption(
          text: '7–8 hours',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '5–6 hours',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: '4 or less than hours',
          fattyLiverPoints: 2,
          cholesterolPoints: 2,
        ),
      ],
    ),

    // =========================================================
    // DIET & EATING HABITS
    // =========================================================

    AssessmentQuestion(
      id: 4,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽',
      question: 'Do you prefer home-cooked meals or restaurant/fast food?',
      options: [
        AnswerOption(
          text: 'Mostly home-cooked',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Mixed',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Mostly restaurant/fast food',
          fattyLiverPoints: 3,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 5,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽',
      question: 'How often do you eat fried or oily foods per week?',
      options: [
        AnswerOption(
          text: '0–1 times',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–3 times',
          fattyLiverPoints: 1,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: '4 or more than times',
          fattyLiverPoints: 3,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 6,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽',
      question: 'How often do you eat red meat (beef, pork, mutton)?',
      options: [
        AnswerOption(
          text: 'Rarely\n(1 or less than time/week)',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Sometimes\n(2–3 times/week)',
          fattyLiverPoints: 1,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: 'Often\n(4 or more than times/week)',
          fattyLiverPoints: 2,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 7,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽',
      question: 'Do you regularly eat fish or lean protein (chicken, pulses, beans)?',
      options: [
        AnswerOption(
          text: 'Daily',
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
      question: 'How many servings of fruits and vegetables do you eat daily?',
      options: [
        AnswerOption(
          text: '5 or more than servings',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–4 servings',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: '1 or less than serving',
          fattyLiverPoints: 3,
          cholesterolPoints: 2,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 9,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽',
      question: 'What type of cooking oil do you mostly use at home?',
      options: [
        AnswerOption(
          text: 'Olive/coconut oil\n(moderate use)',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Sunflower/canola oil',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Palm oil/reused fried oil',
          fattyLiverPoints: 3,
          cholesterolPoints: 3,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 10,
      section: 'Diet & Eating Habits',
      sectionIcon: '🍽',
      question: 'Do you often eat processed/packaged foods (chips, biscuits, instant noodles)?',
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
          fattyLiverPoints: 3,
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
      question: 'Do you consume alcohol?',
      options: [
        AnswerOption(
          text: 'Yes',
          fattyLiverPoints: 3,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'No',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
      ],
    ),

    AssessmentQuestion(
      id: 12,
      section: 'Lifestyle Choices',
      sectionIcon: '🥤',
      question: 'Do you drink tea, coffee, or sugary drinks daily?',
      options: [
        AnswerOption(
          text: '0–1 cups',
          fattyLiverPoints: 0,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: '2–3 cups',
          fattyLiverPoints: 1,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: '4 or more than cups',
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
      sectionIcon: '🖊',
      question: 'Do you have a family history of these diseases?',
      isMultipleChoice: true,
      options: [
        AnswerOption(
          text: 'Fatty Liver',
          fattyLiverPoints: 2,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'High Cholesterol',
          fattyLiverPoints: 0,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: 'Heart Disease',
          fattyLiverPoints: 1,
          cholesterolPoints: 2,
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
      sectionIcon: '🖊',
      question: 'Have you ever been diagnosed with diabetes, hypertension or metabolic syndrome?',
      isMultipleChoice: true,
      options: [
        AnswerOption(
          text: 'Diabetes',
          fattyLiverPoints: 3,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: 'Hypertension\n(High Blood Pressure)',
          fattyLiverPoints: 1,
          cholesterolPoints: 3,
        ),
        AnswerOption(
          text: 'Metabolic Syndrome\n(combo of BP, sugar & fat)',
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
      sectionIcon: '🖊',
      question: 'Which of the following do you experience?',
      isMultipleChoice: true,
      options: [
        AnswerOption(
          text: 'Frequent fatigue',
          fattyLiverPoints: 2,
          cholesterolPoints: 1,
        ),
        AnswerOption(
          text: 'Abdominal discomfort',
          fattyLiverPoints: 2,
          cholesterolPoints: 0,
        ),
        AnswerOption(
          text: 'Unexplained weight gain',
          fattyLiverPoints: 3,
          cholesterolPoints: 2,
        ),
        AnswerOption(
          text: 'None',
          isNone: true,
        ),
      ],
    ),
  ];

  static AssessmentResult calculateResult(
      Map<int, List<int>> answers,
      ) {
    int fattyLiverScore = 0;
    int cholesterolScore = 0;

    int fattyLiverMaxScore = 0;
    int cholesterolMaxScore = 0;

    for (final question in questions) {
      final selectedIndexes = answers[question.id] ?? [];

      // Calculate selected answer scores
      for (final index in selectedIndexes) {
        final option = question.options[index];

        fattyLiverScore += option.fattyLiverPoints;
        cholesterolScore += option.cholesterolPoints;
      }

      // Calculate maximum possible score for normalization.
      if (question.isMultipleChoice) {
        fattyLiverMaxScore += question.options
            .where((option) => !option.isNone)
            .fold(
          0,
              (sum, option) => sum + option.fattyLiverPoints,
        );

        cholesterolMaxScore += question.options
            .where((option) => !option.isNone)
            .fold(
          0,
              (sum, option) => sum + option.cholesterolPoints,
        );
      } else {
        fattyLiverMaxScore += question.options
            .map((option) => option.fattyLiverPoints)
            .reduce((a, b) => a > b ? a : b);

        cholesterolMaxScore += question.options
            .map((option) => option.cholesterolPoints)
            .reduce((a, b) => a > b ? a : b);
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

  static RiskLevel _getRiskLevel(
      int score,
      int maxScore,
      ) {
    if (maxScore == 0) return RiskLevel.low;

    final percentage = (score / maxScore) * 100;

    if (percentage < 34) {
      return RiskLevel.low;
    } else if (percentage < 67) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.high;
    }
  }
}