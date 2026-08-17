class AnswerOption {
  final String text;
  final int fattyLiverPoints;
  final int cholesterolPoints;
  final bool isNone;

  const AnswerOption({
    required this.text,
    this.fattyLiverPoints = 0,
    this.cholesterolPoints = 0,
    this.isNone = false,
  });
}

class AssessmentQuestion {
  final int id;
  final String section;
  final String sectionIcon;
  final String question;
  final List<AnswerOption> options;
  final bool isMultipleChoice;

  const AssessmentQuestion({
    required this.id,
    required this.section,
    required this.sectionIcon,
    required this.question,
    required this.options,
    this.isMultipleChoice = false,
  });
}