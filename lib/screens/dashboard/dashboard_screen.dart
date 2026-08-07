import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:happy_liver/screens/educational_video/educational_screen.dart';
import 'package:happy_liver/screens/assessment/assessment_intro_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 40),

              const Text(
                "Hello Shehani!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 17),

              const Text(
                "Where would you like to begin?",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 60),

              DashboardCard(
                imagePath: "assets/images/book.png",
                title: "Learn about Fatty Liver\n& Cholesterol",
                description:
                "👌 Recommended for new users.",
                buttonText: "Explore Learning",
                buttonIcon: "assets/icons/arrow.svg",
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EducationalScreen(),
                    ),
                  );

                },
              ),

              const SizedBox(height: 35),

              DashboardCard(
                imagePath: "assets/images/bulb.png",
                title: "Already familiar with\nFatty Liver & Cholesterol?",
                description:
                "🔎 Let's assess your risk level.",
                buttonText: "Start Assessment",
                buttonIcon: "assets/icons/arrow.svg",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AssessmentScreen(),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {

  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final String buttonIcon;
  final VoidCallback onPressed;

  const DashboardCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Image.asset(
                imagePath,
                width: 45,
                height: 45,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),

            ],
          ),

          const SizedBox(height: 15),

          Text(
            description,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(

              onPressed: onPressed,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(width: 10),

                  SvgPicture.asset(
                    buttonIcon,
                    width: 20,
                    height: 20,
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}