class QuestionModel {


  final String question;


  final QuestionType type;


  final List<String> options;


  final List<int> scores;



  QuestionModel({

    required this.question,

    required this.type,

    required this.options,

    required this.scores,

  });


}





enum QuestionType {


  singleChoice,


  multipleChoice,


  bmi,


}