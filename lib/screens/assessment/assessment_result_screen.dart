import 'package:flutter/material.dart';
import '../../models/risk_level.dart';
import '../../widgets/custom_header.dart';




class AssessmentResultScreen extends StatelessWidget {


  final RiskLevel fattyLiverRisk;

  final RiskLevel cholesterolRisk;


  final int fattyLiverScore;

  final int cholesterolScore;





  const AssessmentResultScreen({


    super.key,


    required this.fattyLiverRisk,


    required this.cholesterolRisk,


    required this.fattyLiverScore,


    required this.cholesterolScore,


  });









  String getRiskText(RiskLevel risk){


    switch(risk){


      case RiskLevel.low:

        return "LOW RISK";


      case RiskLevel.moderate:

        return "MODERATE RISK";


      case RiskLevel.high:

        return "HIGH RISK";


    }


  }









  Color getRiskColor(RiskLevel risk){


    switch(risk){


      case RiskLevel.low:

        return Colors.green;


      case RiskLevel.moderate:

        return Colors.orange;


      case RiskLevel.high:

        return Colors.red;


    }


  }









  Widget riskCard(

      String title,

      RiskLevel risk,

      int score

      ){



    return Container(



      width: double.infinity,



      padding:
      const EdgeInsets.all(20),




      margin:
      const EdgeInsets.only(bottom:20),





      decoration: BoxDecoration(


        color:
        Colors.white,


        borderRadius:
        BorderRadius.circular(20),



        boxShadow: [


          BoxShadow(


            color:
            Colors.grey.shade300,


            blurRadius:10,


            offset:
            const Offset(0,5),


          )

        ],


      ),






      child: Column(



        children: [



          Text(



            title,



            style:
            const TextStyle(



              fontSize:20,


              fontWeight:
              FontWeight.bold,


            ),



          ),






          const SizedBox(height:15),






          Container(



            padding:
            const EdgeInsets.symmetric(


              horizontal:25,


              vertical:12,


            ),



            decoration: BoxDecoration(


              color:
              getRiskColor(risk)
                  .withOpacity(0.15),



              borderRadius:
              BorderRadius.circular(30),


            ),



            child: Text(



              getRiskText(risk),




              style: TextStyle(



                color:
                getRiskColor(risk),



                fontSize:18,


                fontWeight:
                FontWeight.bold,


              ),



            ),



          ),






          const SizedBox(height:15),






          Text(


            "Score: $score",



            style:
            const TextStyle(



              fontSize:16,



            ),



          ),



        ],


      ),



    );


  }









  @override
  Widget build(BuildContext context) {



    return Scaffold(



      backgroundColor:
      Colors.grey.shade100,




      appBar: const CustomHeader(title: 'Assessment Result'),










      body: SingleChildScrollView(



        padding:
        const EdgeInsets.all(20),





        child: Column(



          children: [





            const SizedBox(height:20),





            const Text(



              "Your Health Risk Assessment",



              style: TextStyle(



                fontSize:24,


                fontWeight:
                FontWeight.bold,


              ),



            ),






            const SizedBox(height:30),







            riskCard(



              "Fatty Liver Risk",



              fattyLiverRisk,



              fattyLiverScore,


            ),






            riskCard(



              "Cholesterol Risk",



              cholesterolRisk,



              cholesterolScore,


            ),







            const SizedBox(height:20),







            ElevatedButton(



              onPressed: (){



                Navigator.popUntil(


                  context,


                      (route)=>route.isFirst,


                );



              },



              style:
              ElevatedButton.styleFrom(



                backgroundColor:
                Colors.green,



                padding:
                const EdgeInsets.symmetric(



                  horizontal:50,


                  vertical:15,


                ),



                shape:
                RoundedRectangleBorder(



                  borderRadius:
                  BorderRadius.circular(30),


                ),



              ),





              child:
              const Text(



                "Back to Home",



                style: TextStyle(



                  color:
                  Colors.white,


                  fontSize:16,


                ),



              ),



            )





          ],


        ),



      ),



    );


  }



}