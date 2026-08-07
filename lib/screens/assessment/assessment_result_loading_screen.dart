import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/risk_level.dart';
import '../../services/assessment_service.dart';
import 'assessment_result_screen.dart';



class AssessmentResultLoadingScreen extends StatefulWidget {


  final int fattyLiverScore;

  final int cholesterolScore;




  const AssessmentResultLoadingScreen({

    super.key,

    required this.fattyLiverScore,

    required this.cholesterolScore,

  });





  @override
  State<AssessmentResultLoadingScreen> createState() =>
      _AssessmentResultLoadingScreenState();

}






class _AssessmentResultLoadingScreenState
    extends State<AssessmentResultLoadingScreen> {





  @override
  void initState() {

    super.initState();


    calculateRisk();


  }







  void calculateRisk(){



    RiskLevel fattyLiverRisk =

    AssessmentService.getRiskLevel(

        widget.fattyLiverScore

    );






    RiskLevel cholesterolRisk =

    AssessmentService.getRiskLevel(

        widget.cholesterolScore

    );







    Timer(

      const Duration(seconds: 3),


          (){


        Navigator.pushReplacement(

          context,


          MaterialPageRoute(

            builder:(context)=>

                AssessmentResultScreen(

                  fattyLiverRisk:
                  fattyLiverRisk,


                  cholesterolRisk:
                  cholesterolRisk,


                  fattyLiverScore:
                  widget.fattyLiverScore,


                  cholesterolScore:
                  widget.cholesterolScore,


                ),


          ),


        );


      },

    );



  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(



      backgroundColor:
      Colors.white,



      body: Center(



        child: Column(



          mainAxisAlignment:
          MainAxisAlignment.center,



          children: [




            const CircularProgressIndicator(

              color: Colors.green,

            ),





            const SizedBox(height:30),






            const Text(

              "Analyzing your health risks...",


              style: TextStyle(

                fontSize:18,

                fontWeight:
                FontWeight.w600,

              ),


            )





          ],


        ),


      ),



    );


  }



}