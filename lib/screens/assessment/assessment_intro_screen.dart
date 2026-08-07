import 'package:flutter/material.dart';
import 'package:happy_liver/screens/assessment/assessment_question_screen.dart';

import '../../widgets/custom_header.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const CustomHeader(title: '', showBack: true),



      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  "Welcome to the Health\nAssessment",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 42,
                      color: Colors.black87,
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: const Text(
                        "You're about to complete a short assessment designed to evaluate your risk of fatty liver disease and high cholesterol.",
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 70),

                SizedBox(
                  width: 180,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssessmentQuestionScreen(questionIndex: 0,)
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: const Text(
                      "Let's Begin",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}