import 'package:flutter/material.dart';
import '../../widgets/custom_header.dart';
import '../../models/question_model.dart';
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



  final List<QuestionModel> questions =
  AssessmentService.getQuestions();



  int currentQuestionIndex = 0;



  Map<int, dynamic> answers = {};



  final TextEditingController heightController =
  TextEditingController();



  final TextEditingController weightController =
  TextEditingController();







  @override
  Widget build(BuildContext context) {


    QuestionModel question =
    questions[currentQuestionIndex];



    return Scaffold(


      backgroundColor: Colors.white,



        appBar: CustomHeader(title: 'Question ${currentQuestionIndex + 1}/14', showBack:true),




      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children: [



            Text(

              question.question,

              style: const TextStyle(

                fontSize:24,

                fontWeight:FontWeight.bold,

              ),

            ),



            const SizedBox(height:25),




            Expanded(

              child: buildAnswerWidget(question),

            ),






            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,


              children: [




                if(currentQuestionIndex > 0)

                  ElevatedButton(

                    onPressed:
                    previousQuestion,


                    child:
                    const Text("Previous"),

                  ),





                ElevatedButton(

                  onPressed:
                  nextQuestion,


                  child: Text(

                    currentQuestionIndex ==
                        questions.length - 1

                        ? "Submit"

                        : "Next",

                  ),

                ),


              ],

            )


          ],

        ),

      ),


    );


  }









  Widget buildAnswerWidget(
      QuestionModel question
      ) {



    // RADIO QUESTIONS

    if(question.type ==
        QuestionType.singleChoice){



      return ListView(

        children:

        question.options.map((option){


          return RadioListTile<String>(
            title: Text(
              option,
              style: const TextStyle(
                fontSize: 19,
              ),
            ),
            value: option,



            groupValue:
            answers[currentQuestionIndex],



            activeColor:
            Colors.green,



            onChanged:(value){


              setState((){


                answers[currentQuestionIndex]
                = value;


              });


            },


          );


        }).toList(),

      );


    }







    // CHECKBOX QUESTIONS


    if(question.type ==
        QuestionType.multipleChoice){



      List selectedAnswers =
          answers[currentQuestionIndex] ?? [];



      return ListView(

        children:

        question.options.map((option){


          return CheckboxListTile(


            title:
            Text(option),



            value:
            selectedAnswers.contains(option),



            activeColor:
            Colors.green,



            onChanged:(value){


              setState((){


                if(value == true){

                  selectedAnswers.add(option);

                }

                else{

                  selectedAnswers.remove(option);

                }



                answers[currentQuestionIndex]
                = selectedAnswers;


              });


            },


          );


        }).toList(),

      );


    }







    // BMI QUESTION


    if(question.type ==
        QuestionType.bmi){



      return Column(

        children: [



          TextField(

            controller:
            heightController,


            keyboardType:
            TextInputType.number,


            decoration:
            const InputDecoration(

              labelText:
              "Height (cm)",


              border:
              OutlineInputBorder(),

            ),

          ),





          const SizedBox(height:30),





          TextField(

            controller:
            weightController,


            keyboardType:
            TextInputType.number,


            decoration:
            const InputDecoration(

              labelText:
              "Weight (kg)",


              border:
              OutlineInputBorder(),

            ),

          ),



        ],

      );


    }




    return const SizedBox();


  }









  bool validateCurrentQuestion(){



    QuestionModel question =
    questions[currentQuestionIndex];



    if(question.type ==
        QuestionType.singleChoice){


      return answers.containsKey(
          currentQuestionIndex
      );


    }




    if(question.type ==
        QuestionType.multipleChoice){


      if(!answers.containsKey(
          currentQuestionIndex
      )){


        return false;


      }



      return answers[currentQuestionIndex]
          .isNotEmpty;


    }




    if(question.type ==
        QuestionType.bmi){


      return heightController.text
          .trim()
          .isNotEmpty &&

          weightController.text
              .trim()
              .isNotEmpty;


    }



    return false;


  }









  void nextQuestion(){



    if(!validateCurrentQuestion()){



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
              "Please answer this question first"
          ),

        ),

      );


      return;

    }




    saveBMI();




    if(currentQuestionIndex <
        questions.length - 1){



      setState((){


        currentQuestionIndex++;


      });



    }

    else{


      calculateResult();


    }



  }









  void previousQuestion(){


    setState((){


      currentQuestionIndex--;


    });


  }









  void saveBMI(){



    if(currentQuestionIndex == 9){



      double height =
          double.tryParse(
              heightController.text
          ) ?? 0;




      double weight =
          double.tryParse(
              weightController.text
          ) ?? 0;





      if(height > 0 && weight > 0){



        double bmi =
        AssessmentService.calculateBMI(
            height,
            weight
        );



        answers[9] = bmi;


      }


    }


  }









  void calculateResult(){



    double bmiScore = 0;



    if(answers[9] != null){


      bmiScore =

          AssessmentService
              .calculateBMIScore(
              answers[9]
          )
              .toDouble();


    }







    int fattyLiverScore =

    AssessmentService.calculateFattyLiverScore(

        answers,

        bmiScore

    );







    int cholesterolScore =

    AssessmentService.calculateCholesterolScore(

        answers

    );







    Navigator.pushReplacement(

      context,


      MaterialPageRoute(

        builder:(context)=>

            AssessmentResultLoadingScreen(

              fattyLiverScore:
              fattyLiverScore,


              cholesterolScore:
              cholesterolScore,


            ),

      ),


    );


  }









  @override
  void dispose(){


    heightController.dispose();

    weightController.dispose();


    super.dispose();


  }



}