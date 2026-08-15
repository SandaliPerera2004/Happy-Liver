import 'package:flutter/material.dart';

import 'assessment_question_screen.dart';

class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({super.key});

  static const Color backgroundColor = Color(0xFFF8FBF7);
  static const Color darkGreen = Color(0xFF195F17);
  static const Color borderGreen = Color(0xFF8DB88A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 38,
          ),
          child: Column(
            children: [
              const SizedBox(height: 150),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFCFB),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: borderGreen,
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.50,
                      ),
                      blurRadius: 7,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      'Welcome to the Health\nAssessment !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: Color(0xFF292D29),
                      ),
                    ),

                    SizedBox(height: 25),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 35,
                          color: Color(0xFF444A44),
                        ),

                        SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            "You're about to complete a\n"
                                'short assessment designed to\n'
                                'evaluate your risk of fatty liver\n'
                                'disease and high cholesterol.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF343A34),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 43),

              SizedBox(
                width: 138,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const AssessmentQuestionScreen(
                          questionIndex: 0,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ).copyWith(
                    shadowColor: WidgetStateProperty.all(
                      Colors.black.withValues(alpha: 0.35),
                    ),
                    elevation: WidgetStateProperty.all(5),
                  ),
                  child: const Text(
                    "Let's Begin",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}