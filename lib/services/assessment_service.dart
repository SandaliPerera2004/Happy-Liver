import '../models/question_model.dart';
import '../models/risk_level.dart';



class AssessmentService {



  // =====================================================
  // 14 ASSESSMENT QUESTIONS
  // =====================================================


  static List<QuestionModel> getQuestions(){


    return [



      QuestionModel(

        question:
        "Have you ever been diagnosed with fatty liver disease or cholesterol by a doctor?",

        type: QuestionType.singleChoice,

        options:[

          "Fatty liver",

          "Cholesterol",

          "Both",

          "None"

        ],


        scores:[

          5,

          5,

          6,

          0

        ],


      ),






      QuestionModel(

        question:
        "Do you have a family history of any of the following?",

        type: QuestionType.multipleChoice,


        options:[

          "Liver disease",

          "Heart disease",

          "Cholesterol",

          "Diabetes",

          "None"

        ],


        scores:[

          3,

          3,

          3,

          3,

          0

        ],


      ),







      QuestionModel(

        question:
        "Have you been diagnosed with any of these conditions?",

        type: QuestionType.singleChoice,


        options:[

          "Diabetes",

          "High blood pressure",

          "Both",

          "None"

        ],


        scores:[

          4,

          3,

          5,

          0

        ],


      ),







      QuestionModel(

        question:
        "How often do you eat fried or fast food?",

        type: QuestionType.singleChoice,


        options:[

          "Never",

          "1-2 times a week",

          "3-4 times a week",

          "5 or more times a week"

        ],


        scores:[

          0,

          1,

          2,

          3

        ],


      ),







      QuestionModel(

        question:
        "How many servings of fruits and vegetables do you eat each day?",

        type: QuestionType.singleChoice,


        options:[

          "None",

          "1-2 servings",

          "3-4 servings",

          "5 or more servings"

        ],


        scores:[

          3,

          2,

          1,

          0

        ],


      ),







      QuestionModel(

        question:
        "How often do you drink sugary beverages?",

        type: QuestionType.singleChoice,


        options:[

          "Never",

          "Occasionally",

          "3-4 times a week",

          "Daily"

        ],


        scores:[

          0,

          1,

          2,

          3

        ],


      ),







      QuestionModel(

        question:
        "How many days each week do you exercise for at least 30 minutes?",

        type: QuestionType.singleChoice,


        options:[

          "Never",

          "1-2 days",

          "3-5 days",

          "Every day"

        ],


        scores:[

          3,

          2,

          1,

          0

        ],


      ),







      QuestionModel(

        question:
        "How long do you usually spend sitting each day?",

        type: QuestionType.singleChoice,


        options:[

          "Less than 4 hours",

          "4-6 hours",

          "6-8 hours",

          "More than 8 hours"

        ],


        scores:[

          0,

          1,

          2,

          3

        ],


      ),







      QuestionModel(

        question:
        "Do you smoke or consume alcohol?",

        type: QuestionType.singleChoice,


        options:[

          "Neither",

          "Smoke only",

          "Alcohol only",

          "Both"

        ],


        scores:[

          0,

          2,

          2,

          4

        ],


      ),







      QuestionModel(

        question:
        "Enter height and weight to calculate BMI",

        type: QuestionType.bmi,


        options:[],


        scores:[],


      ),







      QuestionModel(

        question:
        "How often do you have a medical checkup or blood test?",

        type: QuestionType.singleChoice,


        options:[

          "Every 6 months",

          "Once a year",

          "Every few years",

          "Never"

        ],


        scores:[

          0,

          1,

          2,

          3

        ],


      ),







      QuestionModel(

        question:
        "Are you currently taking medication for any of these following?",


        type: QuestionType.multipleChoice,


        options:[

          "Cholesterol",

          "Diabetes",

          "Liver disease",

          "None"

        ],


        scores:[

          3,

          3,

          3,

          0

        ],


      ),







      QuestionModel(

        question:
        "Have you experienced any of these symptoms recently?",


        type: QuestionType.multipleChoice,


        options:[

          "Fatigue",

          "Abdominal discomfort",

          "Weight gain",

          "None"

        ],


        scores:[

          2,

          3,

          2,

          0

        ],


      ),







      QuestionModel(

        question:
        "How would you describe your overall lifestyle?",


        type: QuestionType.singleChoice,


        options:[

          "Healthy",

          "Moderately healthy",

          "Unhealthy"

        ],


        scores:[

          0,

          2,

          4

        ],


      ),



    ];


  }







  // =====================================================
  // BMI CALCULATION
  // =====================================================


  static double calculateBMI(

      double heightCm,

      double weightKg

      ){


    double heightMeter =
        heightCm / 100;


    return weightKg /
        (heightMeter * heightMeter);


  }







  static int calculateBMIScore(double bmi){


    if(bmi < 18.5){

      return 1;

    }

    else if(bmi < 25){

      return 0;

    }

    else if(bmi < 30){

      return 2;

    }

    else{

      return 3;

    }

  }







  // =====================================================
  // FATTY LIVER SCORE
  // =====================================================


  static int calculateFattyLiverScore(

      Map<int,dynamic> answers,

      double bmiScore

      ){



    return calculateScore(
        answers,
        bmiScore,
        true
    );


  }







  // =====================================================
  // CHOLESTEROL SCORE
  // =====================================================


  static int calculateCholesterolScore(

      Map<int,dynamic> answers

      ){


    return calculateScore(

        answers,

        0,

        false

    );


  }








  static int calculateScore(

      Map<int,dynamic> answers,

      double bmiScore,

      bool fattyLiver

      ){


    int totalScore = 0;


    List<QuestionModel> questions =
    getQuestions();




    answers.forEach((index,value){



      QuestionModel question =
      questions[index];



      if(question.type ==
          QuestionType.singleChoice){



        int optionIndex =
        question.options.indexOf(value);



        if(optionIndex >= 0){


          totalScore +=
          question.scores[optionIndex];


        }


      }





      else if(question.type ==
          QuestionType.multipleChoice){



        for(String answer in value){



          int optionIndex =
          question.options.indexOf(answer);



          if(optionIndex >= 0){


            totalScore +=
            question.scores[optionIndex];


          }


        }


      }



    });





    if(fattyLiver){

      totalScore +=
          bmiScore.toInt();

    }



    return totalScore;


  }








  // =====================================================
  // RISK LEVEL
  // =====================================================


  static RiskLevel getRiskLevel(int score){



    if(score <= 10){


      return RiskLevel.low;


    }


    else if(score <= 20){


      return RiskLevel.moderate;


    }


    else{


      return RiskLevel.high;


    }



  }



}