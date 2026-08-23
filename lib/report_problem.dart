import 'package:flutter/material.dart';

class ReportProblem extends StatefulWidget {
  const ReportProblem({super.key});

  @override
  State<ReportProblem> createState() => _ReportProblemState();
}

class _ReportProblemState extends State<ReportProblem> {
  final TextEditingController problemController =
  TextEditingController();

  @override
  void dispose() {
    problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
          horizontal: 20,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 38),

            // Report a problem title
            Row(
              children: const [

                Icon(
                  Icons.help_outline,
                  size: 30,
                  color: Colors.black,
                ),

                SizedBox(width: 10),

                Text(
                  "Report a problem",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // What went wrong?
            const Text(
              "What went wrong?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 26),

            // Problem text box
            Container(
              width: double.infinity,
              height: 116,

              padding: const EdgeInsets.all(12),

              color: const Color(0xFFE0E0E0),

              child: TextField(
                controller: problemController,
                maxLines: 5,

                decoration: const InputDecoration(
                  border: InputBorder.none,

                  hintText: "Describe the problem...",

                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Submit Report button
            Center(
              child: SizedBox(
                width: 137,
                height: 30,

                child: ElevatedButton(
                  onPressed: () {
                    if (problemController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please describe the problem.",
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Your report has been submitted.",
                          ),
                        ),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A000),
                    foregroundColor: Colors.white,

                    elevation: 0,

                    padding: EdgeInsets.zero,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  child: const Text(
                    "Submit Report",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}