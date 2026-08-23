import 'package:flutter/material.dart';

class SendFeedback extends StatefulWidget {
  const SendFeedback({super.key});

  @override
  State<SendFeedback> createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  int selectedRating = 4;

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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 38),

              // Send Feedback title
              Row(
                children: const [

                  Icon(
                    Icons.chat_bubble_outline,
                    size: 29,
                    color: Colors.black,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Send Feedback",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Question
              const Text(
                "What do you think about this app?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              // Feedback text box
              Container(
                width: double.infinity,
                height: 115,
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(0),
                ),

                child: const TextField(
                  maxLines: 5,

                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Tell us what you think...",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 38),

              // Rating question
              const Text(
                "How would you rate your\nexperience?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              // Stars
              Row(
                children: List.generate(
                  5,
                      (index) {
                    final starNumber = index + 1;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = starNumber;
                        });
                      },

                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 3,
                        ),

                        child: Icon(
                          starNumber <= selectedRating
                              ? Icons.star
                              : Icons.star_border,

                          size: 32,

                          color: starNumber <= selectedRating
                              ? const Color(0xFFFFB800)
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 65),

              // Submit button
              Center(
                child: SizedBox(
                  width: 203,
                  height: 30,

                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Thank you for your feedback!",
                          ),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A000),
                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),

                      padding: EdgeInsets.zero,
                    ),

                    child: const Text(
                      "Submit Feedback",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}