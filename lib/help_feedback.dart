import 'package:flutter/material.dart';
import 'send_feedback.dart';
import 'report_problem.dart';

class HelpFeedback extends StatelessWidget {
  const HelpFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Top Help & Feedback bar
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F8D8),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Help & Feedback",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 55),

            // How can we help you?
            const Text(
              "How can we help you?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // Send feedback
            helpItem(
              title: "Send feedback",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SendFeedback()),
                );
              },
            ),

            const SizedBox(height: 12),

            // Report a problem
            helpItem(
              title: "Report a problem",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportProblem()),
                );
              },
            ),

            const Spacer(),

            // Still need help?
            const Text(
              "Still need help?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 28),

            // Contact us
            const Text(
              "Contact us",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Email
            const Text(
              "support@happyliver.com",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6FA8DC),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 115),
          ],
        ),
      ),
    );
  }

  Widget helpItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),

        child: Row(
          children: [

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}